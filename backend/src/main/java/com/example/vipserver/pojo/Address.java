package com.example.vipserver.pojo;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("address")
public class Address {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;           // 用户ID
    private String receiverName;   // 收件人姓名
    private String receiverPhone;  // 联系电话
    private String province;       // 省份
    private String city;           // 城市
    private String district;       // 区/县
    private String detailAddress;  // 详细地址(街道/门牌)
    private String postalCode;     // 邮政编码
    private Integer isDefault;     // 是否默认: 0否/1是
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}
