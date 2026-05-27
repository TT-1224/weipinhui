package com.example.vipserver.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.vipserver.pojo.OrderInfo;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface OrderMapper extends BaseMapper<OrderInfo> {
}
