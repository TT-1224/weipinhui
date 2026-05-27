package com.example.vipserver.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.vipserver.pojo.Cart;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface CartMapper extends BaseMapper<Cart> {
}
