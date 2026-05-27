package com.example.vipserver.service;

import com.example.vipserver.mapper.CartMapper;
import com.example.vipserver.mapper.GoodsMapper;
import com.example.vipserver.pojo.Cart;
import com.example.vipserver.pojo.Goods;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * 购物车服务规格数据准确性测试
 * 测试场景：验证不同规格组合下的购物车数据存储和更新
 */
class CartServiceSpecificationTest {

    @Mock
    private CartMapper cartMapper;

    @Mock
    private GoodsMapper goodsMapper;

    @InjectMocks
    private CartService cartService;

    private static final Long TEST_USER_ID = 1L;
    private static final Long TEST_GOODS_ID = 1L;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    @DisplayName("首次添加商品 - 规格信息正确保存")
    void testAddToCart_FirstTime_SpecificationSaved() {
        when(cartMapper.selectOne(any())).thenReturn(null);

        cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 1, "黑色", "M码");

        verify(cartMapper).insert(argThat((Cart cart) ->
            cart.getUserId().equals(TEST_USER_ID) &&
            cart.getGoodsId().equals(TEST_GOODS_ID) &&
            cart.getQuantity() == 1 &&
            cart.getChecked() == 1 &&
            "黑色".equals(cart.getSelectedProperColor()) &&
            "M码".equals(cart.getSelectedProperSize())
        ));
    }

    @Test
    @DisplayName("重复添加相同规格 - 数量累加，规格保持不变")
    void testAddToCart_SameSpec_QuantityIncreased() {
        Cart existingCart = createExistingCart("黑色", "M码", 2);
        when(cartMapper.selectOne(any())).thenReturn(existingCart);

        cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 1, "黑色", "M码");

        verify(cartMapper).updateById(argThat((Cart cart) ->
            cart.getQuantity() == 3 &&
            "黑色".equals(cart.getSelectedProperColor()) &&
            "M码".equals(cart.getSelectedProperSize())
        ));
    }

    @Test
    @DisplayName("重复添加不同颜色 - 规格更新为最新选择（核心修复验证）")
    void testAddToCart_DifferentColor_SpecificationUpdated() {
        Cart existingCart = createExistingCart("黑色", "M码", 1);
        when(cartMapper.selectOne(any())).thenReturn(existingCart);

        cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 1, "白色", "M码");

        verify(cartMapper).updateById(argThat((Cart cart) ->
            cart.getQuantity() == 2 &&
            "白色".equals(cart.getSelectedProperColor()) &&  // ✅ 颜色已更新
            "M码".equals(cart.getSelectedProperSize())
        ));
    }

    @Test
    @DisplayName("重复添加不同尺码 - 规格更新为最新选择（核心修复验证）")
    void testAddToCart_DifferentSize_SpecificationUpdated() {
        Cart existingCart = createExistingCart("黑色", "M码", 1);
        when(cartMapper.selectOne(any())).thenReturn(existingCart);

        cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 1, "黑色", "L码");

        verify(cartMapper).updateById(argThat((Cart cart) ->
            cart.getQuantity() == 2 &&
            "黑色".equals(cart.getSelectedProperColor()) &&
            "L码".equals(cart.getSelectedProperSize())  // ✅ 尺码已更新
        ));
    }

    @Test
    @DisplayName("重复添加不同颜色和尺码 - 所有规格都更新为最新选择")
    void testAddToCart_DifferentColorAndSize_AllSpecificationsUpdated() {
        Cart existingCart = createExistingCart("黑色", "M码", 1);
        when(cartMapper.selectOne(any())).thenReturn(existingCart);

        cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 2, "白色", "XL码");

        verify(cartMapper).updateById(argThat((Cart cart) ->
            cart.getQuantity() == 3 &&
            "白色".equals(cart.getSelectedProperColor()) &&   // ✅ 颜色已更新
            "XL码".equals(cart.getSelectedProperSize())       // ✅ 尺码已更新
        ));
    }

    @Test
    @DisplayName("添加空规格 - 规格字段应为null或空字符串")
    void testAddToCart_EmptySpec_NullValues() {
        when(cartMapper.selectOne(any())).thenReturn(null);

        cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 1, null, null);

        verify(cartMapper).insert(argThat((Cart cart) ->
            cart.getSelectedProperColor() == null &&
            cart.getSelectedProperSize() == null
        ));
    }

    @Test
    @DisplayName("多次连续添加不同规格 - 最终保留最后一次的规格")
    void testAddToCart_MultipleTimes_LastSpecWins() {
        Cart existingCart = createExistingCart("红色", "S码", 3);
        when(cartMapper.selectOne(any())).thenReturn(existingCart);

        cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 1, "蓝色", "XXL码");

        verify(cartMapper).updateById(argThat((Cart cart) ->
            cart.getQuantity() == 4 &&
            "蓝色".equals(cart.getSelectedProperColor()) &&    // ✅ 最终是蓝色
            "XXL码".equals(cart.getSelectedProperSize())       // ✅ 最终是XXL码
        ));
    }

    @Test
    @DisplayName("批量添加场景 - 模拟用户快速点击加购按钮")
    void testAddToCart_RapidClicks_SpecificationConsistent() {
        Cart existingCart = createExistingCart("黑色", "均码", 5);
        when(cartMapper.selectOne(any())).thenReturn(existingCart);

        for (int i = 0; i < 10; i++) {
            cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 1, "白色", "L码");
        }

        verify(cartMapper, times(10)).updateById(argThat((Cart cart) ->
            "白色".equals(cart.getSelectedProperColor()) &&
            "L码".equals(cart.getSelectedProperSize())
        ));
    }

    /**
     * 创建已存在的购物车项
     */
    private Cart createExistingCart(String color, String size, int quantity) {
        Cart cart = new Cart();
        cart.setId(100L);
        cart.setUserId(TEST_USER_ID);
        cart.setGoodsId(TEST_GOODS_ID);
        cart.setQuantity(quantity);
        cart.setChecked(1);
        cart.setSelectedProperColor(color);
        cart.setSelectedProperSize(size);
        return cart;
    }
}
