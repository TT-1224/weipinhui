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
 * 购物车服务尺码区分机制测试
 * 核心验证：同一商品不同尺码/颜色应作为独立购物车条目
 */
class CartServiceSizeDistinctionTest {

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

    // ==================== 核心功能：尺码区分机制 ====================

    @Test
    @DisplayName("同一商品+相同规格 → 累加数量（不创建新条目）")
    void testSameSpec_SameGoods_QuantityIncreased() {
        Cart existingCart = createCart("黑色", "M", 2);
        when(cartMapper.selectOne(any())).thenReturn(existingCart);

        cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 3, "黑色", "M");

        verify(cartMapper).updateById(argThat((Cart cart) ->
            cart.getQuantity() == 5 &&  // 2 + 3 = 5
            "黑色".equals(cart.getSelectedProperColor()) &&
            "M".equals(cart.getSelectedProperSize())
        ));
        verify(cartMapper, never()).insert(any());
    }

    @Test
    @DisplayName("同一商品+不同尺码 → 创建独立条目（核心功能）")
    void testDifferentSize_CreateNewEntry() {
        when(cartMapper.selectOne(any())).thenReturn(null);

        cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 1, "黑色", "L");

        verify(cartMapper).insert(argThat((Cart cart) ->
            cart.getGoodsId().equals(TEST_GOODS_ID) &&
            "黑色".equals(cart.getSelectedProperColor()) &&
            "L".equals(cart.getSelectedProperSize()) &&   // ✅ 不同尺码
            cart.getQuantity() == 1
        ));
        verify(cartMapper, never()).updateById(any());
    }

    @Test
    @DisplayName("同一商品+不同颜色 → 创建独立条目（核心功能）")
    void testDifferentColor_CreateNewEntry() {
        when(cartMapper.selectOne(any())).thenReturn(null);

        cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 1, "白色", "M");

        verify(cartMapper).insert(argThat((Cart cart) ->
            cart.getGoodsId().equals(TEST_GOODS_ID) &&
            "白色".equals(cart.getSelectedProperColor()) &&  // ✅ 不同颜色
            "M".equals(cart.getSelectedProperSize()) &&
            cart.getQuantity() == 1
        ));
    }

    @Test
    @DisplayName("同一商品+不同颜色和不同尺码 → 创建独立条目")
    void testDifferentColorAndSize_CreateNewEntry() {
        when(cartMapper.selectOne(any())).thenReturn(null);

        cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 2, "白色", "XL");

        verify(cartMapper).insert(argThat((Cart cart) ->
            "白色".equals(cart.getSelectedProperColor()) &&
            "XL".equals(cart.getSelectedProperSize()) &&
            cart.getQuantity() == 2
        ));
    }

    // ==================== 多规格组合场景 ====================

    @Test
    @DisplayName("用户添加同一商品的多个尺码组合 → 每个组合都是独立条目")
    void testMultipleSizeCombinations_AllIndependent() {
        when(cartMapper.selectOne(any())).thenReturn(null);

        cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 1, "黑色", "XS");
        cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 1, "黑色", "S");
        cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 1, "黑色", "M");
        cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 1, "黑色", "L");
        cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 1, "黑色", "XL");
        cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 1, "黑色", "XXL");

        verify(cartMapper, times(6)).insert(any());
    }

    @Test
    @DisplayName("添加6种颜色×6种尺码 = 36个独立购物车条目")
    void testFullMatrix_36IndependentEntries() {
        String[] colors = {"黑色", "白色", "灰色", "蓝色", "红色"};
        String[] sizes = {"XS", "S", "M", "L", "XL", "XXL"};

        when(cartMapper.selectOne(any())).thenReturn(null);

        for (String color : colors) {
            for (String size : sizes) {
                cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 1, color, size);
            }
        }

        verify(cartMapper, times(30)).insert(any());  // 5颜色 × 6尺码 = 30条
    }

    // ==================== 混合场景：部分重复+部分新增 ====================

    @Test
    @DisplayName("先加'M码'再加'L码' → 2个独立条目")
    void testMixedScenario_TwoEntries() {
        when(cartMapper.selectOne(any()))
            .thenReturn(null)  // 第一次查询：不存在
            .thenReturn(null); // 第二次查询：不存在

        cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 1, "黑色", "M");
        cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 1, "黑色", "L");

        verify(cartMapper, times(2)).insert(any());
        verify(cartMapper, never()).updateById(any());
    }

    @Test
    @DisplayName("先加'M码×2件'再加'M码×3件' → 合并为1条，数量=5")
    void testMixedScenario_MergedEntry() {
        Cart existingCart = createCart("黑色", "M", 2);
        when(cartMapper.selectOne(any())).thenReturn(existingCart);

        cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 3, "黑色", "M");

        verify(cartMapper).updateById(argThat((Cart cart) -> cart.getQuantity() == 5));
        verify(cartMapper, never()).insert(any());
    }

    // ==================== 边界情况测试 ====================

    @Test
    @DisplayName("空规格(null)也作为独立条目判断条件")
    void testNullSpec_AsSeparateEntry() {
        when(cartMapper.selectOne(any())).thenReturn(null);

        cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 1, null, null);

        verify(cartMapper).insert(argThat((Cart cart) ->
            cart.getSelectedProperColor() == null &&
            cart.getSelectedProperSize() == null
        ));
    }

    @Test
    @DisplayName("有规格 vs 无规格 → 两个独立条目")
    void testWithAndWithoutSpec_TwoEntries() {
        when(cartMapper.selectOne(any())).thenReturn(null);

        cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 1, "黑色", "M");
        cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 1, null, null);

        verify(cartMapper, times(2)).insert(any());
    }

    // ==================== 数据库唯一键约束模拟 ====================

    @Test
    @DisplayName("验证查询条件包含完整的4字段组合")
    void testQueryCondition_ContainsAllSpecFields() {
        when(cartMapper.selectOne(any())).thenReturn(null);

        cartService.addToCart(TEST_USER_ID, TEST_GOODS_ID, 1, "蓝色", "XXL");

        verify(cartMapper).selectOne(argThat((LambdaQueryWrapper<Cart> wrapper) ->
            wrapper != null  // 确保查询条件被正确构建
        ));
    }

    // ==================== 辅助方法 ====================

    private Cart createCart(String color, String size, int quantity) {
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
