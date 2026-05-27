package com.example.vipserver.pojo;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("order_item")
public class OrderItem {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long orderId;

    private Long goodsId;

    private String goodsName;  // 商品名称快照

    private String goodsImage; // 商品图片快照

    private BigDecimal goodsPrice; // 商品单价快照

    private Integer quantity;

    private String properColor;

    private String properSize;

    private LocalDateTime createTime;
}
