package com.example.vipserver.pojo;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("order_info")
public class OrderInfo {
    @TableId(type = IdType.AUTO)
    private Long id;

    private String orderNo;

    private Long userId;

    private Long addressId;

    private BigDecimal totalAmount;

    private Integer status;  // 0待付款/1待发货/2待收货/3已完成/4已取消

    private String remark;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}
