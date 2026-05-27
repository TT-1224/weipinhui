package com.example.vipserver.controller;

import com.example.vipserver.common.JwtUtil;
import com.example.vipserver.common.Result;
import com.example.vipserver.pojo.Favorite;
import com.example.vipserver.service.FavoriteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

@RestController
@RequestMapping("/api/favorite")
public class FavoriteController {

    @Autowired
    private FavoriteService favoriteService;

    @Autowired
    private JwtUtil jwtUtil;

    /**
     * 从Token中获取用户ID
     */
    private Long getUserIdFromToken(String authHeader) {
        String token = authHeader.replace("Bearer ", "");
        return jwtUtil.getUserIdFromToken(token);
    }

    /**
     * 获取收藏列表（包含商品详情）
     * 对应前端: FavoritePage.ets
     */
    @GetMapping("/list")
    public Result<Map<String, Object>> getFavoriteList(@RequestHeader("Authorization") String authHeader) {
        try {
            Long userId = getUserIdFromToken(authHeader);

            // 获取收藏记录列表（只含goodsId）
            List<Favorite> favorites = favoriteService.getFavoriteList(userId);

            // 获取收藏数量
            long totalCount = favoriteService.getFavoriteCount(userId);

            Map<String, Object> data = new HashMap<>();
            data.put("list", favorites);
            data.put("totalCount", totalCount);

            System.out.println("🔍 [FavoriteController] 获取收藏列表 - userId: " + userId + ", 数量: " + totalCount);

            return Result.success(data);
        } catch (Exception e) {
            return Result.error("获取收藏列表失败: " + e.getMessage());
        }
    }

    /**
     * 添加收藏
     * 对应前端: CardDetailPage.ets 收藏按钮
     */
    @PostMapping("/add/{goodsId}")
    public Result<Boolean> addFavorite(@PathVariable Long goodsId,
                                       @RequestHeader("Authorization") String authHeader) {
        try {
            Long userId = getUserIdFromToken(authHeader);

            if (goodsId == null || goodsId <= 0) {
                return Result.error(400, "商品ID无效");
            }

            favoriteService.addFavorite(userId, goodsId);

            System.out.println("✅ [FavoriteController] 添加收藏成功 - userId: " + userId + ", goodsId: " + goodsId);

            return Result.success(true);
        } catch (RuntimeException e) {
            if (e.getMessage().contains("已在收藏夹中")) {
                return Result.error(409, e.getMessage());
            }
            return Result.error(e.getMessage());
        } catch (Exception e) {
            return Result.error("添加收藏失败: " + e.getMessage());
        }
    }

    /**
     * 取消收藏
     * 对应前端: CardDetailPage.ets / FavoritePage.ets 删除按钮
     */
    @DeleteMapping("/{goodsId}")
    public Result<Boolean> removeFavorite(@PathVariable Long goodsId,
                                          @RequestHeader("Authorization") String authHeader) {
        try {
            Long userId = getUserIdFromToken(authHeader);

            if (goodsId == null || goodsId <= 0) {
                return Result.error(400, "商品ID无效");
            }

            favoriteService.removeFavorite(userId, goodsId);

            System.out.println("✅ [FavoriteController] 取消收藏成功 - userId: " + userId + ", goodsId: " + goodsId);

            return Result.success(true);
        } catch (RuntimeException e) {
            return Result.error(e.getMessage());
        } catch (Exception e) {
            return Result.error("取消收藏失败: " + e.getMessage());
        }
    }

    /**
     * 检查指定商品是否已收藏
     * 对应前端: CardDetailPage.ets 显示收藏状态图标
     */
    @GetMapping("/check/{goodsId}")
    public Result<Map<String, Boolean>> checkFavorited(@PathVariable Long goodsId,
                                                      @RequestHeader("Authorization") String authHeader) {
        try {
            Long userId = getUserIdFromToken(authHeader);

            boolean isFavorited = favoriteService.isFavorited(userId, goodsId);

            Map<String, Boolean> data = new HashMap<>();
            data.put("isFavorited", isFavorited);

            return Result.success(data);
        } catch (Exception e) {
            return Result.error("检查收藏状态失败: " + e.getMessage());
        }
    }

    /**
     * 批量检查商品收藏状态
     * 对应前端: 商品列表页批量显示收藏状态
     */
    @PostMapping("/batchCheck")
    public Result<Map<Long, Boolean>> batchCheckFavorited(@RequestBody Map<String, Object> params,
                                                          @RequestHeader("Authorization") String authHeader) {
        try {
            Long userId = getUserIdFromToken(authHeader);

            @SuppressWarnings("unchecked")
            List<Integer> goodsIdsList = (List<Integer>) params.get("goodsIds");
            
            List<Long> goodsIds = goodsIdsList.stream()
                    .map(Integer::longValue)
                    .toList();

            Set<Long> favoritedIds = favoriteService.batchCheckFavorited(userId, goodsIds);

            // 构建返回结果：每个商品的收藏状态
            Map<Long, Boolean> result = new HashMap<>();
            for (Long goodsId : goodsIds) {
                result.put(goodsId, favoritedIds.contains(goodsId));
            }

            return Result.success(result);
        } catch (Exception e) {
            return Error("批量检查失败: " + e.getMessage());
        }
    }

    /**
     * 获取收藏数量（用于角标显示）
     * 对应前端: Mine.ets TabBar角标
     */
    @GetMapping("/count")
    public Result<Map<String, Long>> getFavoriteCount(@RequestHeader("Authorization") String authHeader) {
        try {
            Long userId = getUserIdFromToken(authHeader);

            long count = favoriteService.getFavoriteCount(userId);

            Map<String, Long> data = new HashMap<>();
            data.put("count", count);

            return Result.success(data);
        } catch (Exception e) {
            return Result.error("获取收藏数量失败: " + e.getMessage());
        }
    }

    private Result<Map<Long, Boolean>> Error(String s) {
        // TODO Auto-generated method stub
        throw new UnsupportedOperationException("Unimplemented method 'Error'");
    }
}
