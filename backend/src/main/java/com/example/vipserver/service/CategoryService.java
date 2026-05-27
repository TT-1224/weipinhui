package com.example.vipserver.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.vipserver.mapper.CategoryMapper;
import com.example.vipserver.pojo.Category;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CategoryService {

    @Autowired
    private CategoryMapper categoryMapper;

    // 获取所有一级分类
    public List<Category> getAllCategories() {
        LambdaQueryWrapper<Category> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Category::getStatus, 1)
               .isNull(Category::getParentId)
               .orderByAsc(Category::getSort);
        return categoryMapper.selectList(wrapper);
    }

    // 根据ID获取分类
    public Category getCategoryById(Long id) {
        return categoryMapper.selectById(id);
    }
}
