package com.example.vipserver.controller;

import com.example.vipserver.common.JwtUtil;
import com.example.vipserver.common.Result;
import com.example.vipserver.pojo.Cart;
import com.example.vipserver.service.CartService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/cart")
public class CartController {

    @Autowired
    private CartService cartService;

    @Autowired
    private JwtUtil jwtUtil;

    // 从Token中获取用户ID
    private Long getUserIdFromToken(String authHeader) {
        String token = authHeader.replace("Bearer ", "");
        return jwtUtil.getUserIdFromToken(token);
    }

    // 购物车列表 - 对应Shop.ets
    @GetMapping("/list")
    public Result<Map<String, Object>> getCartList(@RequestHeader("Authorization") String authHeader) {
        try {
            Long userId = getUserIdFromToken(authHeader);
            List<Cart> cartList = cartService.getCartList(userId);

            // 计算汇总信息
            CartService.CartSummary summary = cartService.getCartSummary(cartList);

            Map<String, Object> data = new HashMap<>();
            data.put("list", cartList);
            data.put("totalCount", summary.getTotalCount());
            data.put("totalAmount", summary.getTotalAmount());

            return Result.success(data);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    // 加入购物车 - 对应CardDetailPage.ets加购按钮
    @PostMapping("/add")
    public Result<String> addToCart(@RequestHeader("Authorization") String authHeader,
                                    @RequestBody Map<String, Object> params) {
        try {
            Long userId = getUserIdFromToken(authHeader);
            Long goodsId = Long.valueOf(params.get("goodsId").toString());
            Integer quantity = Integer.valueOf(params.get("quantity").toString());
            String properColor = (String) params.get("properColor");
            String properSize = (String) params.get("properSize");

            cartService.addToCart(userId, goodsId, quantity, properColor, properSize);
            return Result.success("添加成功", null);
        } catch (NumberFormatException e) {
            return Result.error("参数格式错误");
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    // 更新购物车项 - 对应Shop.ets数量修改/选中状态切换
    @PutMapping("/update")
    public Result<String> updateCartItem(@RequestHeader("Authorization") String authHeader,
                                        @RequestBody Map<String, Object> params) {
        try {
            Long userId = getUserIdFromToken(authHeader);
            Long cartId = Long.valueOf(params.get("cartId").toString());
            Integer quantity = params.containsKey("quantity") ?
                    Integer.valueOf(params.get("quantity").toString()) : null;
            Integer checked = params.containsKey("checked") ?
                    Integer.valueOf(params.get("checked").toString()) : null;

            cartService.updateCartItem(userId, cartId, quantity, checked);
            return Result.success("更新成功", null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    // 删除购物车项 - 对应Shop.ets删除功能
    @DeleteMapping("/remove")
    public Result<String> removeCartItem(@RequestHeader("Authorization") String authHeader,
                                       @RequestBody Map<String, Object> params) {
        try {
            Long userId = getUserIdFromToken(authHeader);
            Long cartId = Long.valueOf(params.get("cartId").toString());
            cartService.removeCartItem(userId, cartId);
            return Result.success("删除成功", null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
