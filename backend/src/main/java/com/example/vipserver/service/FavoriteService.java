package com.example.vipserver.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.vipserver.mapper.FavoriteMapper;
import com.example.vipserver.pojo.Favorite;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class FavoriteService {

    @Autowired
    private FavoriteMapper favoriteMapper;

    /**
     * 获取用户所有收藏记录
     */
    public List<Favorite> getFavoriteList(Long userId) {
        LambdaQueryWrapper<Favorite> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Favorite::getUserId, userId)
              .orderByDesc(Favorite::getCreateTime);
        return favoriteMapper.selectList(wrapper);
    }

    /**
     * 获取用户收藏的商品ID列表
     */
    public List<Long> getFavoriteGoodsIds(Long userId) {
        List<Favorite> favorites = getFavoriteList(userId);
        return favorites.stream()
                .map(Favorite::getGoodsId)
                .collect(Collectors.toList());
    }

    /**
     * 获取用户收藏的商品ID集合（用于快速查找）
     */
    public Set<Long> getFavoriteGoodsIdSet(Long userId) {
        List<Long> goodsIds = getFavoriteGoodsIds(userId);
        return Set.copyOf(goodsIds);
    }

    /**
     * 添加收藏（去重：同一用户不能重复收藏同一商品）
     */
    @Transactional
    public void addFavorite(Long userId, Long goodsId) {
        // 检查是否已收藏
        if (isFavorited(userId, goodsId)) {
            throw new RuntimeException("该商品已在收藏夹中");
        }

        Favorite favorite = new Favorite();
        favorite.setUserId(userId);
        favorite.setGoodsId(goodsId);

        favoriteMapper.insert(favorite);
    }

    /**
     * 取消收藏
     */
    @Transactional
    public void removeFavorite(Long userId, Long goodsId) {
        LambdaQueryWrapper<Favorite> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Favorite::getUserId, userId)
              .eq(Favorite::getGoodsId, goodsId);

        int rows = favoriteMapper.delete(wrapper);
        if (rows == 0) {
            throw new RuntimeException("收藏记录不存在");
        }
    }

    /**
     * 检查是否已收藏指定商品
     */
    public boolean isFavorited(Long userId, Long goodsId) {
        LambdaQueryWrapper<Favorite> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Favorite::getUserId, userId)
              .eq(Favorite::getGoodsId, goodsId);
        
        return favoriteMapper.selectCount(wrapper) > 0;
    }

    /**
     * 批量检查商品收藏状态
     * @param goodsIds 商品ID列表
     * @return 已收藏的商品ID集合
     */
    public Set<Long> batchCheckFavorited(Long userId, List<Long> goodsIds) {
        if (goodsIds == null || goodsIds.isEmpty()) {
            return Set.of();
        }

        LambdaQueryWrapper<Favorite> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Favorite::getUserId, userId)
              .in(Favorite::getGoodsId, goodsIds);

        List<Favorite> favorites = favoriteMapper.selectList(wrapper);
        return favorites.stream()
                .map(Favorite::getGoodsId)
                .collect(Collectors.toSet());
    }

    /**
     * 获取收藏数量
     */
    public long getFavoriteCount(Long userId) {
        LambdaQueryWrapper<Favorite> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Favorite::getUserId, userId);
        return favoriteMapper.selectCount(wrapper);
    }
}
