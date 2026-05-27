package com.example.vipserver.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.vipserver.mapper.GoodsMapper;
import com.example.vipserver.pojo.Category;
import com.example.vipserver.pojo.Goods;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class GoodsService {

    @Autowired
    private GoodsMapper goodsMapper;

    @Autowired
    private CategoryService categoryService;

    // 商品列表（分页+排序）
    public Page<Goods> getGoodsList(Integer page, Integer pageSize,
                                     String sortField, String sortOrder,
                                     Long categoryId) {
        Page<Goods> pageParam = new Page<>(page, pageSize);
        LambdaQueryWrapper<Goods> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Goods::getStatus, 1);

        if (categoryId != null) {
            wrapper.eq(Goods::getCategoryId, categoryId);
        }

        // 排序：price_asc / price_desc / sold_desc
        if ("price".equals(sortField)) {
            if ("asc".equals(sortOrder)) {
                wrapper.orderByAsc(Goods::getPrice);
            } else {
                wrapper.orderByDesc(Goods::getPrice);
            }
        } else if ("sold".equals(sortField)) {
            wrapper.orderByDesc(Goods::getSoldCount);
        } else {
            wrapper.orderByDesc(Goods::getId);
        }

        return goodsMapper.selectPage(pageParam, wrapper);
    }

    // 商品详情
    public Goods getGoodsDetail(Long id) {
        Goods goods = goodsMapper.selectById(id);
        if (goods == null || goods.getStatus() != 1) {
            throw new RuntimeException("商品不存在或已下架");
        }
        return goods;
    }

    // 搜索商品
    public List<Goods> searchGoods(String keyword, String sort) {
        LambdaQueryWrapper<Goods> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Goods::getStatus, 1)
               .and(w -> w.like(Goods::getName, keyword)
                         .or()
                         .like(Goods::getSubTitle, keyword));

        switch (sort) {
            case "sales":
                wrapper.orderByDesc(Goods::getSoldCount);
                break;
            case "price_asc":
                wrapper.orderByAsc(Goods::getPrice);
                break;
            case "price_desc":
                wrapper.orderByDesc(Goods::getPrice);
                break;
            case "default":
            default:
                // 综合排序：名称完全匹配优先，然后按销量
                wrapper.orderByDesc(Goods::getSoldCount);
                break;
        }

        wrapper.last("LIMIT 50");
        return goodsMapper.selectList(wrapper);
    }

    // 获取分类列表
    public List<Category> getCategoryList() {
        return categoryService.getAllCategories();
    }

    // 获取推荐商品（首页使用）
    public List<Goods> getRecommendedGoods(int limit) {
        LambdaQueryWrapper<Goods> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Goods::getStatus, 1)
               .orderByDesc(Goods::getSoldCount)
               .last("LIMIT " + limit);
        return goodsMapper.selectList(wrapper);
    }

    // 根据ID获取商品（内部使用）
    public Goods getById(Long id) {
        return goodsMapper.selectById(id);
    }

    /**
     * 批量获取商品列表（根据ID集合）
     * @param ids 商品ID列表
     * @return 商品列表
     */
    public List<Goods> listByIds(List<Long> ids) {
        if (ids == null || ids.isEmpty()) {
            return new java.util.ArrayList<>();
        }
        return goodsMapper.selectBatchIds(ids);
    }

    /**
     * 更新商品信息
     * @param goods 商品对象
     * @return 是否更新成功
     */
    public boolean updateById(Goods goods) {
        return goodsMapper.updateById(goods) > 0;
    }
}
