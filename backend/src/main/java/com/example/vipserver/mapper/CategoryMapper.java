package com.example.vipserver.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.vipserver.pojo.Category;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface CategoryMapper extends BaseMapper<Category> {
}
