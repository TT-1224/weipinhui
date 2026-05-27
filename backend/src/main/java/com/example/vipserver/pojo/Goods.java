package com.example.vipserver.pojo;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("goods")
public class Goods {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String cardId;
    private String name;
    private String title;
    private String subTitle;
    private String brand;
    private BigDecimal price;
    private BigDecimal originPrice;
    private BigDecimal marketPrice;
    private String cover;
    private String images;
    private String description;
    private String properColor;
    private String properSize;
    private Integer stock;
    private Integer soldCount;
    private Long categoryId;
    private Integer status;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}
