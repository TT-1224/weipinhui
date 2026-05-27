package com.example.vipserver.controller;

import com.example.vipserver.common.JwtUtil;
import com.example.vipserver.common.Result;
import com.example.vipserver.pojo.Goods;
import com.example.vipserver.pojo.OrderInfo;
import com.example.vipserver.service.GoodsService;
import com.example.vipserver.service.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/order")
public class OrderController {

    @Autowired
    private OrderService orderService;

    @Autowired
    private GoodsService goodsService;

    @Autowired
    private JwtUtil jwtUtil;

    /**
     * 从Token中提取用户ID
     */
    private Long getUserIdFromToken(String authHeader) {
        String token = authHeader.replace("Bearer ", "");
        return jwtUtil.getUserIdFromToken(token);
    }

    /**
     * 创建订单（从购物车结算）
     * 新增addressId参数用于关联收货地址
     */
    @PostMapping("/create")
    public Result<OrderInfo> createOrder(@RequestHeader("Authorization") String authHeader,
                                          @RequestBody Map<String, Object> params) {
        try {
            Long userId = getUserIdFromToken(authHeader);

            // 解析购物车ID列表
            @SuppressWarnings("unchecked")
            List<Integer> cartIds = (List<Integer>) params.get("cartIds");
            List<Long> cartIdLongs = null;
            if (cartIds != null) {
                cartIdLongs = new java.util.ArrayList<>();
                for (Integer id : cartIds) {
                    cartIdLongs.add(id.longValue());
                }
            }

            // 解析收货地址ID（新增必填参数）
            Long addressId = null;
            if (params.get("addressId") != null) {
                addressId = Long.valueOf(params.get("addressId").toString());
            }

            String remark = params.get("remark") != null ? params.get("remark").toString() : "";

            OrderInfo order = orderService.createOrderFromCart(userId, cartIdLongs, addressId, remark);
            return Result.success(order);
        } catch (RuntimeException e) {
            return Result.error(e.getMessage());
        } catch (Exception e) {
            return Result.error(500, "创建订单失败: " + e.getMessage());
        }
    }

    /**
     * 创建订单（立即购买）
     * 新增addressId参数用于关联收货地址
     */
    @PostMapping("/direct")
    public Result<OrderInfo> createDirectOrder(@RequestHeader("Authorization") String authHeader,
                                                @RequestBody Map<String, Object> params) {
        try {
            Long userId = getUserIdFromToken(authHeader);

            Long goodsId = Long.valueOf(params.get("goodsId").toString());
            Integer quantity = Integer.valueOf(params.get("quantity").toString());
            String properColor = params.get("properColor") != null ? params.get("properColor").toString() : "";
            String properSize = params.get("properSize") != null ? params.get("properSize").toString() : "";

            // 解析收货地址ID（新增必填参数）
            Long addressId = null;
            if (params.get("addressId") != null) {
                addressId = Long.valueOf(params.get("addressId").toString());
            }

            Goods goods = goodsService.getGoodsDetail(goodsId);

            OrderInfo order = orderService.createDirectOrder(
                userId, goodsId, quantity, properColor, properSize, addressId, goods
            );

            return Result.success(order);
        } catch (RuntimeException e) {
            return Result.error(e.getMessage());
        } catch (Exception e) {
            return Result.error(500, "创建订单失败: " + e.getMessage());
        }
    }

    /**
     * 获取用户订单列表
     */
    @GetMapping("/list")
    public Result<List<OrderInfo>> getOrderList(@RequestHeader("Authorization") String authHeader,
                                                  @RequestParam(defaultValue = "-1") Integer status) {
        try {
            Long userId = getUserIdFromToken(authHeader);

            List<OrderInfo> orders;
            if (status == -1) {
                orders = orderService.getUserOrders(userId, null);
            } else {
                orders = orderService.getUserOrders(userId, status);
            }

            return Result.success(orders);
        } catch (Exception e) {
            return Result.error(500, "获取订单列表失败");
        }
    }

    /**
     * 获取订单详情（修复权限控制：只能查看自己的订单）
     */
    @GetMapping("/detail/{orderId}")
    public Result<Map<String, Object>> getOrderDetail(@PathVariable Long orderId,
                                                       @RequestHeader("Authorization") String authHeader) {
        try {
            Long userId = getUserIdFromToken(authHeader);
            
            // 传入userId进行权限校验，防止越权访问他人订单
            Map<String, Object> detail = orderService.getOrderDetail(orderId, userId);
            return Result.success(detail);
        } catch (RuntimeException e) {
            return Result.error(e.getMessage());
        } catch (Exception e) {
            return Result.error(404, e.getMessage());
        }
    }

    /**
     * 更新订单状态（增加状态流转校验）
     */
    @PutMapping("/status/{orderId}")
    public Result<Boolean> updateStatus(
            @PathVariable Long orderId,
            @RequestHeader("Authorization") String authHeader,
            @RequestBody Map<String, Integer> params) {
        try {
            Integer status = params.get("status");
            boolean success = orderService.updateOrderStatus(orderId, status);
            if (success) {
                return Result.success(true);
            } else {
                return Result.error(400, "更新失败");
            }
        } catch (RuntimeException e) {
            return Result.error(e.getMessage());
        } catch (Exception e) {
            return Result.error(500, "更新失败: " + e.getMessage());
        }
    }

    /**
     * 删除订单（完善状态校验+库存恢复）
     */
    @DeleteMapping("/{orderId}")
    public Result<Boolean> deleteOrder(@PathVariable Long orderId,
                                        @RequestHeader("Authorization") String authHeader) {
        try {
            Long userId = getUserIdFromToken(authHeader);
            
            // 传入userId进行权限校验和状态检查
            boolean success = orderService.deleteOrder(orderId, userId);
            if (success) {
                return Result.success(true);
            } else {
                return Result.error(400, "删除失败");
            }
        } catch (RuntimeException e) {
            return Result.error(e.getMessage());
        } catch (Exception e) {
            return Result.error(500, "删除失败: " + e.getMessage());
        }
    }

    /**
     * 更新订单收货地址（用于待支付订单修改地址）
     */
    @PutMapping("/updateAddress/{orderId}")
    public Result<Boolean> updateOrderAddress(@PathVariable Long orderId,
                                                @RequestHeader("Authorization") String authHeader,
                                                @RequestBody Map<String, Long> params) {
        try {
            Long userId = getUserIdFromToken(authHeader);
            Long addressId = params.get("addressId");
            
            if (addressId == null || addressId <= 0) {
                return Result.error(400, "地址ID无效");
            }
            
            boolean success = orderService.updateOrderAddress(orderId, userId, addressId);
            if (success) {
                return Result.success(true);
            } else {
                return Result.error(400, "更新失败");
            }
        } catch (RuntimeException e) {
            return Result.error(e.getMessage());
        } catch (Exception e) {
            return Result.error(500, "更新失败: " + e.getMessage());
        }
    }

    /**
     * 获取各状态订单数量统计
     */
    @GetMapping("/count")
    public Result<Map<Integer, Long>> getOrderCount(@RequestHeader("Authorization") String authHeader) {
        try {
            Long userId = getUserIdFromToken(authHeader);
            Map<Integer, Long> countMap = orderService.getOrderCountByStatus(userId);
            return Result.success(countMap);
        } catch (Exception e) {
            return Result.error(500, "获取统计信息失败");
        }
    }
}
