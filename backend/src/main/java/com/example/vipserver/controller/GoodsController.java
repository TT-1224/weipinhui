package com.example.vipserver.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.vipserver.common.Result;
import com.example.vipserver.pojo.Category;
import com.example.vipserver.pojo.Goods;
import com.example.vipserver.service.GoodsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/goods")
public class GoodsController {

    @Autowired
    private GoodsService goodsService;

    // 商品列表（分页+排序）- 对应Category.ets / HomePage.ets
  @GetMapping("/list")
  public Result<Map<String, Object>> getGoodsList(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) String sortField,
            @RequestParam(required = false) String sortOrder,
            @RequestParam(required = false) Long categoryId) {
        Page<Goods> result = goodsService.getGoodsList(page, pageSize, sortField, sortOrder, categoryId);

        Map<String, Object> data = new HashMap<> ();
        data.put("list", result.getRecords());
        data.put("total", result.getTotal());

        return Result.success(data);
    }

    // 商品详情 - 对应CardDetailPage.ets
    @GetMapping("/detail/{id}")
    public Result<Goods> getGoodsDetail(@PathVariable Long id) {
        try {
            Goods goods = goodsService.getGoodsDetail(id);
            return Result.success(goods);
        } catch (RuntimeException e) {
            return Result.error(e.getMessage());
        }
    }

    // 搜索商品 - 对应SearchResultPage.ets / SearchPage.ets
    @GetMapping("/search")
    public Result<List<Goods>> searchGoods(
            @RequestParam String keyword,
            @RequestParam(required = false, defaultValue = "default") String sort) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return Result.error("搜索关键词不能为空");
        }
        List<Goods> result = goodsService.searchGoods(keyword.trim(), sort);
        return Result.success(result);
    }

    // 分类列表 - 对应Category.ets左侧导航(18个分类)
    @GetMapping("/categories")
    public Result<List<Category>> getCategoryList() {
        List<Category> categories = goodsService.getCategoryList();
        return Result.success(categories);
    }

    // 推荐商品 - 对应HomePage.ets推荐区域
    @GetMapping("/recommended")
    public Result<List<Goods>> getRecommendedGoods(
            @RequestParam(defaultValue = "8") Integer limit) {
        List<Goods> goods = goodsService.getRecommendedGoods(limit);
        return Result.success(goods);
    }
}
