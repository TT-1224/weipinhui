package com.example.vipserver.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.vipserver.mapper.CartMapper;
import com.example.vipserver.mapper.GoodsMapper;
import com.example.vipserver.pojo.Cart;
import com.example.vipserver.pojo.Goods;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class CartService {

    @Autowired
    private CartMapper cartMapper;

    @Autowired
    private GoodsMapper goodsMapper;

    // 获取购物车列表（含商品信息）
    public List<Cart> getCartList(Long userId) {
        LambdaQueryWrapper<Cart> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Cart::getUserId, userId);
        List<Cart> cartList = cartMapper.selectList(wrapper);

        if (cartList == null || cartList.isEmpty()) {
            return new ArrayList<>();
        }

        // 批量查询所有关联的商品信息
        Set<Long> goodsIds = cartList.stream()
                .map(Cart::getGoodsId)
                .collect(Collectors.toSet());

        if (!goodsIds.isEmpty()) {
            LambdaQueryWrapper<Goods> goodsWrapper = new LambdaQueryWrapper<>();
            goodsWrapper.in(Goods::getId, goodsIds);
            List<Goods> goodsList = goodsMapper.selectList(goodsWrapper);

            // 构建商品ID到商品的映射
            Map<Long, Goods> goodsMap = goodsList.stream()
                    .collect(Collectors.toMap(Goods::getId, Function.identity()));

            // 将商品信息设置到购物车项中
            for (Cart cart : cartList) {
                cart.setGoods(goodsMap.get(cart.getGoodsId()));
            }
        }

        return cartList;
    }

    // 加入购物车（支持同一商品不同规格作为独立条目）
    @Transactional
    public void addToCart(Long userId, Long goodsId, Integer quantity,
                          String properColor, String properSize) {
        // 检查是否已存在相同商品+相同规格的记录
        LambdaQueryWrapper<Cart> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Cart::getUserId, userId)
            .eq(Cart::getGoodsId, goodsId)
            .eq(Cart::getSelectedProperColor, properColor)
            .eq(Cart::getSelectedProperSize, properSize);
        Cart existingCart = cartMapper.selectOne(wrapper);

        if (existingCart != null) {
            // 已存在相同商品+相同规格则累加数量
            existingCart.setQuantity(existingCart.getQuantity() + quantity);
            cartMapper.updateById(existingCart);
        } else {
            // 不存在（包括不同规格）则新增独立条目
            Cart cart = new Cart();
            cart.setUserId(userId);
            cart.setGoodsId(goodsId);
            cart.setQuantity(quantity);
            cart.setChecked(1);
            cart.setSelectedProperColor(properColor);
            cart.setSelectedProperSize(properSize);
            cartMapper.insert(cart);
        }
    }

    // 更新数量/选中状态
    public void updateCartItem(Long userId, Long cartId, Integer quantity, Integer checked) {
        Cart cart = cartMapper.selectById(cartId);
        if (cart == null || !cart.getUserId().equals(userId)) {
            throw new RuntimeException("购物车项不存在");
        }
        if (quantity != null) cart.setQuantity(quantity);
        if (checked != null) cart.setChecked(checked);
        cartMapper.updateById(cart);
    }

    // 删除购物车项
    public void removeCartItem(Long userId, Long cartId) {
        Cart cart = cartMapper.selectById(cartId);
        if (cart == null || !cart.getUserId().equals(userId)) {
            throw new RuntimeException("购物车项不存在");
        }
        cartMapper.deleteById(cartId);
    }

    // 获取选中商品总金额和数量
    public CartSummary getCartSummary(List<Cart> cartList) {
        int totalCount = 0;
        double totalAmount = 0.0;

        for (Cart cart : cartList) {
            if (cart.getChecked() == 1 && cart.getGoods() != null) {
                totalCount += cart.getQuantity();
                totalAmount += cart.getGoods().getPrice().doubleValue() * cart.getQuantity();
            }
        }

        CartSummary summary = new CartSummary();
        summary.setTotalCount(totalCount);
        summary.setTotalAmount(totalAmount);
        return summary;
    }

    // 购物车汇总数据类
    public static class CartSummary {
        private int totalCount;
        private double totalAmount;

        public int getTotalCount() { return totalCount; }
        public void setTotalCount(int totalCount) { this.totalCount = totalCount; }
        public double getTotalAmount() { return totalAmount; }
        public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }
    }
}
