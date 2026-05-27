package com.example.vipserver.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper;
import com.example.vipserver.mapper.AddressMapper;
import com.example.vipserver.mapper.CartMapper;
import com.example.vipserver.mapper.OrderItemMapper;
import com.example.vipserver.mapper.OrderMapper;
import com.example.vipserver.pojo.Address;
import com.example.vipserver.pojo.Cart;
import com.example.vipserver.pojo.Goods;
import com.example.vipserver.pojo.OrderInfo;
import com.example.vipserver.pojo.OrderItem;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class OrderService {

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Autowired
    private CartMapper cartMapper;

    @Autowired
    private GoodsService goodsService;

    @Autowired
    private AddressMapper addressMapper;

    /**
     * 创建订单（从购物车结算）
     * 增加地址校验、库存扣减逻辑
     */
    @Transactional
    public OrderInfo createOrderFromCart(Long userId, List<Long> cartIds, Long addressId, String remark) {
        // 1. 校验收货地址
        Address address = validateAndGetAddress(addressId, userId);

        // 2. 查询购物车中选中的商品
        QueryWrapper<Cart> cartQuery = new QueryWrapper<>();
        cartQuery.eq("user_id", userId)
                .eq("checked", 1)
                .in(cartIds != null && !cartIds.isEmpty(), "id", cartIds);
        List<Cart> cartList = cartMapper.selectList(cartQuery);

        if (cartList == null || cartList.isEmpty()) {
            throw new RuntimeException("没有选中的商品");
        }

        // 3. 批量查询商品信息（优化N+1问题）
        List<Long> goodsIds = cartList.stream()
                .map(Cart::getGoodsId)
                .collect(Collectors.toList());
        
        Map<Long, Goods> goodsMap = batchGetGoodsMap(goodsIds);

        // 4. 校验库存并计算总金额
        BigDecimal totalAmount = validateStockAndCalculateTotal(cartList, goodsMap);

        // 5. 创建订单（关联地址）
        OrderInfo order = new OrderInfo();
        order.setOrderNo(generateOrderNo());
        order.setUserId(userId);
        order.setAddressId(addressId);
        order.setTotalAmount(totalAmount);
        order.setStatus(0); // 待付款
        order.setRemark(remark);
        orderMapper.insert(order);

        // 6. 创建订单明细并扣减库存，同时清空购物车已结算商品
        for (Cart cart : cartList) {
            Goods goods = goodsMap.get(cart.getGoodsId());

            // 扣减库存
            deductStock(goods, cart.getQuantity());

            // 创建订单明细
            OrderItem item = new OrderItem();
            item.setOrderId(order.getId());
            item.setGoodsId(cart.getGoodsId());
            if (goods != null) {
                item.setGoodsName(goods.getName());
                item.setGoodsImage(goods.getCover());
                item.setGoodsPrice(goods.getPrice());
            } else {
                item.setGoodsName("未知商品");
                item.setGoodsPrice(BigDecimal.ZERO);
            }
            item.setQuantity(cart.getQuantity());
            item.setProperColor(cart.getSelectedProperColor());
            item.setProperSize(cart.getSelectedProperSize());
            orderItemMapper.insert(item);

            // 删除购物车中的商品
            cartMapper.deleteById(cart.getId());
        }

        return order;
    }

    /**
     * 创建订单（立即购买）
     */
    @Transactional
    public OrderInfo createDirectOrder(Long userId, Long goodsId, Integer quantity,
                                       String properColor, String properSize,
                                       Long addressId, Goods goods) {
        // 1. 校验收货地址
        Address address = validateAndGetAddress(addressId, userId);

        // 2. 校验库存
        if (goods.getStock() < quantity) {
            throw new RuntimeException(goods.getName() + " 库存不足，当前库存: " + goods.getStock());
        }

        // 3. 计算总金额
        BigDecimal totalAmount = goods.getPrice().multiply(new BigDecimal(quantity));

        // 4. 扣减库存
        deductStock(goods, quantity);

        // 5. 创建订单（关联地址）
        OrderInfo order = new OrderInfo();
        order.setOrderNo(generateOrderNo());
        order.setUserId(userId);
        order.setAddressId(addressId);
        order.setTotalAmount(totalAmount);
        order.setStatus(0); // 待付款
        order.setRemark("立即购买");
        orderMapper.insert(order);

        // 6. 创建订单明细
        OrderItem item = new OrderItem();
        item.setOrderId(order.getId());
        item.setGoodsId(goodsId);
        item.setGoodsName(goods.getName());
        item.setGoodsImage(goods.getCover());
        item.setGoodsPrice(goods.getPrice());
        item.setQuantity(quantity);
        item.setProperColor(properColor);
        item.setProperSize(properSize);
        orderItemMapper.insert(item);

        return order;
    }

    /**
     * 获取用户订单列表（按状态筛选）
     */
    public List<OrderInfo> getUserOrders(Long userId, Integer status) {
        QueryWrapper<OrderInfo> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId);
        if (status != null && status >= 0) {
            queryWrapper.eq("status", status);
        }
        queryWrapper.orderByDesc("create_time");
        return orderMapper.selectList(queryWrapper);
    }

    /**
     * 获取订单详情（包含商品明细）- 增加权限校验
     */
    public Map<String, Object> getOrderDetail(Long orderId, Long userId) {
        QueryWrapper<OrderInfo> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("id", orderId).eq("user_id", userId); // 权限校验：只能查看自己的订单
        OrderInfo order = orderMapper.selectOne(queryWrapper);
        
        if (order == null) {
            throw new RuntimeException("订单不存在或无权访问");
        }

        QueryWrapper<OrderItem> itemQueryWrapper = new QueryWrapper<>();
        itemQueryWrapper.eq("order_id", orderId);
        List<OrderItem> items = orderItemMapper.selectList(itemQueryWrapper);

        Map<String, Object> result = new HashMap<>();
        result.put("order", order);
        result.put("items", items);
        return result;
    }

    /**
     * 更新订单状态（增加状态流转校验）
     */
    public boolean updateOrderStatus(Long orderId, Integer newStatus) {
        OrderInfo order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }

        // 状态流转校验
        Integer currentStatus = order.getStatus();
        if (!isValidStatusTransition(currentStatus, newStatus)) {
            throw new RuntimeException("不允许从状态 " + getStatusName(currentStatus) 
                    + " 变更为 " + getStatusName(newStatus));
        }

        UpdateWrapper<OrderInfo> updateWrapper = new UpdateWrapper<>();
        updateWrapper.eq("id", orderId).set("status", newStatus);
        return orderMapper.update(null, updateWrapper) > 0;
    }

    /**
     * 删除订单（完善状态校验）
     * 只有待付款或已取消的订单可以删除
     */
    public boolean deleteOrder(Long orderId, Long userId) {
        QueryWrapper<OrderInfo> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("id", orderId).eq("user_id", userId);
        OrderInfo order = orderMapper.selectOne(queryWrapper);
        
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }

        // 状态校验：只有待付款(0)和已取消(4)可以删除
        if (order.getStatus() == 1 || order.getStatus() == 2) {
            throw new RuntimeException("进行中的订单无法删除");
        }
        if (order.getStatus() == 3) {
            throw new RuntimeException("已完成的订单无法删除，请联系客服");
        }

        // 如果是待付款订单被删除，需要恢复库存
        if (order.getStatus() == 0) {
            restoreStockForOrder(orderId);
        }

        UpdateWrapper<OrderInfo> updateWrapper = new UpdateWrapper<>();
        updateWrapper.eq("id", orderId).set("status", 4); // 标记为已取消
        return orderMapper.update(null, updateWrapper) > 0;
    }

    /**
     * 获取各状态订单数量统计（优化为单次查询）
     */
    public Map<Integer, Long> getOrderCountByStatus(Long userId) {
        Map<Integer, Long> countMap = new HashMap<>();

        // 使用GROUP BY一次查询所有状态的数量
        QueryWrapper<OrderInfo> queryWrapper = new QueryWrapper<>();
        queryWrapper.select("status, COUNT(*) as count")
                   .eq("user_id", userId)
                   .in("status", Arrays.asList(0, 1, 2)) // 待付款、待发货、待收货
                   .groupBy("status");

        List<Map<String, Object>> results = orderMapper.selectMaps(queryWrapper);
        
        // 初始化默认值
        countMap.put(0, 0L);
        countMap.put(1, 0L);
        countMap.put(2, 0L);

        // 填充实际值
        for (Map<String, Object> result : results) {
            Integer status = ((Number) result.get("status")).intValue();
            Long count = ((Number) result.get("count")).longValue();
            countMap.put(status, count);
        }

        return countMap;
    }

    // ==================== 私有辅助方法 ====================

    /**
     * 校验并获取收货地址
     */
    private Address validateAndGetAddress(Long addressId, Long userId) {
        if (addressId == null) {
            throw new RuntimeException("请选择收货地址");
        }

        QueryWrapper<Address> wrapper = new QueryWrapper<>();
        wrapper.eq("id", addressId).eq("user_id", userId);
        Address address = addressMapper.selectOne(wrapper);

        if (address == null) {
            throw new RuntimeException("收货地址不存在或不属于当前用户");
        }

        return address;
    }

    /**
     * 批量获取商品信息并构建Map（解决N+1查询问题）
     */
    private Map<Long, Goods> batchGetGoodsMap(List<Long> goodsIds) {
        if (goodsIds == null || goodsIds.isEmpty()) {
            return new HashMap<>();
        }

        List<Goods> goodsList = goodsService.listByIds(goodsIds);
        return goodsList.stream()
                .collect(Collectors.toMap(Goods::getId, g -> g, (existing, replacement) -> existing));
    }

    /**
     * 校验库存并计算总金额
     */
    private BigDecimal validateStockAndCalculateTotal(List<Cart> cartList, Map<Long, Goods> goodsMap) {
        BigDecimal totalAmount = BigDecimal.ZERO;

        for (Cart cart : cartList) {
            Goods goods = goodsMap.get(cart.getGoodsId());
            
            if (goods == null) {
                throw new RuntimeException("商品(ID:" + cart.getGoodsId() + ")不存在或已下架");
            }

            // 库存校验
            if (goods.getStock() < cart.getQuantity()) {
                throw new RuntimeException(goods.getName() + " 库存不足，当前库存: " + goods.getStock());
            }

            totalAmount = totalAmount.add(
                goods.getPrice().multiply(new BigDecimal(cart.getQuantity()))
            );
        }

        return totalAmount;
    }

    /**
     * 扣减库存
     */
    private void deductStock(Goods goods, int quantity) {
        int newStock = goods.getStock() - quantity;
        if (newStock < 0) {
            throw new RuntimeException(goods.getName() + " 库存不足");
        }
        goods.setStock(newStock);
        goodsService.updateById(goods);
    }

    /**
     * 恢复库存（用于取消待付款订单时）
     */
    private void restoreStockForOrder(Long orderId) {
        QueryWrapper<OrderItem> wrapper = new QueryWrapper<>();
        wrapper.eq("order_id", orderId);
        List<OrderItem> items = orderItemMapper.selectList(wrapper);

        for (OrderItem item : items) {
            Goods goods = goodsService.getById(item.getGoodsId());
            if (goods != null) {
                goods.setStock(goods.getStock() + item.getQuantity());
                goodsService.updateById(goods);
            }
        }
    }

    /**
     * 校验状态流转是否合法
     */
    private boolean isValidStatusTransition(Integer fromStatus, Integer toStatus) {
        switch (fromStatus) {
            case 0: // 待付款 → 可变为: 已取消
                return toStatus == 4;
            case 1: // 待发货 → 可变为: 已完成（模拟直接完成）
                return toStatus == 3;
            case 2: // 待收货 → 可变为: 已完成
                return toStatus == 3;
            default:
                return false;
        }
    }

    /**
     * 获取状态名称
     */
    private String getStatusName(Integer status) {
        switch (status) {
            case 0: return "待付款";
            case 1: return "待发货";
            case 2: return "待收货";
            case 3: return "已完成";
            case 4: return "已取消";
            default: return "未知";
        }
    }

    /**
     * 生成订单号
     */
    private String generateOrderNo() {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
        String dateStr = sdf.format(new Date());
        String uuid = UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        return "VIP" + dateStr + uuid;
    }

    /**
     * 更新订单收货地址（用于待支付订单修改地址）
     */
    public boolean updateOrderAddress(Long orderId, Long userId, Long newAddressId) {
        // 1. 校验订单存在且属于该用户
        QueryWrapper<OrderInfo> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("id", orderId).eq("user_id", userId);
        OrderInfo order = orderMapper.selectOne(queryWrapper);

        if (order == null) {
            throw new RuntimeException("订单不存在或无权操作");
        }

        // 2. 只有待付款订单可以修改地址
        if (order.getStatus() != 0) {
            throw new RuntimeException("只有待付款订单可以修改收货地址");
        }

        // 3. 校验新地址存在且属于该用户
        Address address = validateAndGetAddress(newAddressId, userId);

        // 4. 更新订单的addressId
        UpdateWrapper<OrderInfo> updateWrapper = new UpdateWrapper<>();
        updateWrapper.eq("id", orderId)
                     .set("address_id", newAddressId);
        
        return orderMapper.update(null, updateWrapper) > 0;
    }
}
