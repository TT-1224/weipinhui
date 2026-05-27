package com.example.vipserver.pojo;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("favorite")
public class Favorite {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;           // 用户ID
    private Long goodsId;          // 商品ID
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}
