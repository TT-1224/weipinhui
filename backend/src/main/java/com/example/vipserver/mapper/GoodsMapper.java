package com.example.vipserver.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.vipserver.pojo.Goods;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface GoodsMapper extends BaseMapper<Goods> {
}
