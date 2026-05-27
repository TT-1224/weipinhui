-- ============================================
-- 唯品会仿制项目 - 数据库初始化脚本 (MVP版本)
-- 数据库: wph (MySQL 8.x)
-- 字符集: utf8mb4
-- 创建时间: 2026-04-20
-- 更新时间: 2026-05-13 (新增订单系统)
-- ============================================
--
-- ⚠️ 重要说明:
--   本脚本采用"先删除后重建"模式
--   执行后会清空所有数据并重新初始化
--   请确保已备份重要数据！
-- ============================================

CREATE DATABASE IF NOT EXISTS `wph` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `wph`;

-- ============================================
-- 第一阶段：删除所有现有表（按依赖关系倒序）
-- 说明：确保每次执行都是干净的环境
-- ============================================

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `order_item`;
DROP TABLE IF EXISTS `order_info`;
DROP TABLE IF EXISTS `address`;
DROP TABLE IF EXISTS `cart`;
DROP TABLE IF EXISTS `goods`;
DROP TABLE IF EXISTS `category`;
DROP TABLE IF EXISTS `user`;

SET FOREIGN_KEY_CHECKS = 1;

SELECT '✅ 所有旧表已清除，开始重建...' AS status_message;

-- ============================================
-- 第二阶段：重建所有表（按依赖关系正序）
-- ============================================

-- -------------------------------------------
-- 1. 用户表
-- 对应前端: UserInfoService / EditProfilePage
-- -------------------------------------------
CREATE TABLE `user` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户ID',
    `phone` VARCHAR(20) NOT NULL COMMENT '手机号(登录名)',
    `password` VARCHAR(100) NOT NULL COMMENT '密码(MD5加密)',
    `nickname` VARCHAR(50) DEFAULT NULL COMMENT '昵称',
    `avatar` VARCHAR(500) DEFAULT NULL COMMENT '头像URL',
    `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
    `status` TINYINT DEFAULT 1 COMMENT '状态: 0禁用/1正常',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 初始化测试用户(密码: 123456 的MD5)
INSERT INTO `user` (`phone`, `password`, `nickname`, `avatar`, `email`) VALUES
('13800138000', 'e10adc3949ba59abbe56e057f20f883e', '个人用户', 'https://example.com/avatar/default.png', 'gerenyonghu@163.com');

-- -------------------------------------------
-- 2. 商品分类表
-- 对应前端: Category.ets (18个分类)
-- -------------------------------------------
CREATE TABLE `category` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '分类ID',
    `name` VARCHAR(200) NOT NULL COMMENT '分类名称',
    `icon` VARCHAR(500) DEFAULT NULL COMMENT '图标URL',
    `sort` INT DEFAULT 0 COMMENT '排序序号(越小越前)',
    `parent_id` BIGINT DEFAULT NULL COMMENT '父分类ID(NULL为一级)',
    `status` TINYINT DEFAULT 1 COMMENT '状态: 0隐藏/1显示',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_parent_id` (`parent_id`),
    KEY `idx_sort` (`sort`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品分类表';

-- 初始化分类数据(对应Category.ets中的18个分类)
INSERT INTO `category` (`name`, `sort`, `parent_id`) VALUES
('男装', 1, NULL),
('女装', 2, NULL),
('数码', 3, NULL),
('食品', 4, NULL),
('电器', 5, NULL),
('鞋包', 6, NULL),
('百货', 7, NULL),
('家居', 8, NULL),
('家纺', 9, NULL),
('美妆', 10, NULL),
('母婴', 11, NULL),
('运动', 12, NULL),
('图书', 13, NULL),
('汽车', 14, NULL),
('乐器', 15, NULL),
('办公', 16, NULL),
('钟表', 17, NULL),
('珠宝', 18, NULL);

-- -------------------------------------------
-- 3. 商品表
-- 对应前端: CardInfo / MockData.ets / MainViewModel
-- -------------------------------------------
CREATE TABLE `goods` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '商品ID',
    `card_id` VARCHAR(64) NOT NULL COMMENT '商品唯一标识(UUID)',
    `name` VARCHAR(200) NOT NULL COMMENT '商品名称',
    `title` VARCHAR(300) DEFAULT NULL COMMENT '标题/卖点',
    `sub_title` VARCHAR(500) DEFAULT NULL COMMENT '副标题/描述',
    `brand` VARCHAR(100) DEFAULT NULL COMMENT '品牌',
    `price` DECIMAL(10,2) NOT NULL COMMENT '售价(特卖价)',
    `origin_price` DECIMAL(10,2) DEFAULT NULL COMMENT '原价',
    `market_price` DECIMAL(10,2) DEFAULT NULL COMMENT '市场价',
    `cover` VARCHAR(500) DEFAULT NULL COMMENT '封面图URL',
    `images` TEXT DEFAULT NULL COMMENT '图片列表(JSON数组)',
    `description` TEXT DEFAULT NULL COMMENT '商品描述(RTF)',
    `proper_color` VARCHAR(100) DEFAULT NULL COMMENT '默认颜色规格',
    `proper_size` VARCHAR(20) DEFAULT NULL COMMENT '默认尺码',
    `stock` INT DEFAULT 0 COMMENT '库存数量',
    `sold_count` INT DEFAULT 0 COMMENT '销量',
    `category_id` BIGINT DEFAULT NULL COMMENT '所属分类ID',
    `status` TINYINT DEFAULT 1 COMMENT '状态: 0下架/1上架',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_card_id` (`card_id`),
    KEY `idx_category_id` (`category_id`),
    KEY `idx_status` (`status`),
    KEY `idx_price` (`price`),
    FULLTEXT KEY `ft_name_desc` (`name`, `sub_title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品表';

-- 初始化商品数据(对应MockData.ets中的11条mockCardInfo)
-- 注意：前3个商品的默认尺码使用'M'与CardDetailPage的尺码选项保持一致
-- 品牌名称已添加，年份已更新为2026
INSERT INTO `goods` (`card_id`, `name`, `sub_title`, `price`, `origin_price`, `cover`, `proper_color`, `proper_size`, `stock`, `sold_count`, `category_id`, `brand`) VALUES
('5bdbe6b0-c34a-4c35-8c8f-19be0ef8104b', '[2026新款]秋冬男士牛仔裤男宽松直筒弹力休闲长裤子男装', '黑色/M码', 134.00, 199.00, 'man1.jpg', '黑色', 'M', 100, 580, 1, '优衣库'),
('c8761280-4d67-4783-ab69-1c176b75fde0', '[2026新款]秋冬男士卫衣男宽松弹力休闲男装', '黑色/M码', 124.00, 188.00, 'man2.jpg', '黑色', 'M', 150, 420, 1, 'ZARA'),
('72464fc9-9448-43f3-9caf-2a3a6a2a07ed', '[2026新款]秋冬男士短袖男宽松弹力休闲男装', '黑色/M码', 99.00, 158.00, 'man3.jpg', '黑色', 'M', 200, 350, 1, 'H&M'),
('58fb40d9-4e36-4ff1-a1b8-7544b0334395', '[2026新款]秋冬男士羽绒服男修身男装', NULL, 78.00, 128.00, 'man4.jpg', NULL, NULL, 180, 280, 1, '波司登'),
('9c4b64d4-62c8-48e4-b685-97e8e5f50b21', '[2026新款]秋冬男士羽绒服男修身男装', NULL, 123.00, 198.00, 'man5.jpg', NULL, NULL, 120, 190, 1, '鸭鸭'),
('5b4d9098-0011-4383-9d5c-91f67ddfd83c', '[2026新款]秋冬男士羽绒服男修身男装', NULL, 453.00, 699.00, 'man6.jpg', NULL, NULL, 80, 150, 1, '加拿大鹅'),
('7b6fa990-e114-4361-a9ff-00d5a93bed07', '[2026新款]秋冬男士羽绒服男修身男装', NULL, 765.00, 1199.00, 'man7.jpg', NULL, NULL, 60, 98, 1, 'Moncler'),
('8794cff1-094a-4b6d-8d04-d6238b806e77', '[2026新款]秋冬男士羽绒服男修身男装', NULL, 66.00, 108.00, 'man8.jpg', NULL, NULL, 220, 450, 1, '李宁'),
('8531161a-a2f9-4c06-8c94-18fd7bb16078', '[2026新款]秋冬男士羽绒服男修身男装', NULL, 88.00, 148.00, 'man9.jpg', NULL, NULL, 170, 320, 1, '安踏'),
('26b2a836-b826-4cb3-b247-119873ef4076', '[2026新款]秋冬男士羽绒服男修身男装', NULL, 73.00, 118.00, 'man10.jpg', NULL, NULL, 190, 380, 1, '耐克'),
('34f7f253-d136-4b88-87d7-724b5ec4d23c', '[2026新款]秋冬男士羽绒服男修身男装', NULL, 90.00, 158.00, 'man11.jpg', NULL, NULL, 140, 260, 1, '阿迪达斯');

-- -------------------------------------------
-- 4. 购物车表
-- 对应前端: Shop.ets / MockData.ets(mockShopCardInfo)
-- -------------------------------------------
CREATE TABLE `cart` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '购物车项ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `goods_id` BIGINT NOT NULL COMMENT '商品ID',
    `quantity` INT DEFAULT 1 COMMENT '数量',
    `checked` TINYINT DEFAULT 1 COMMENT '是否选中结算: 0否/1是',
    `selected_proper_color` VARCHAR(100) DEFAULT NULL COMMENT '选择的颜色',
    `selected_proper_size` VARCHAR(20) DEFAULT NULL COMMENT '选择的尺码',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_goods_spec` (`user_id`, `goods_id`, `selected_proper_color`, `selected_proper_size`),
    KEY `idx_user_id` (`user_id`),
    CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_cart_goods` FOREIGN KEY (`goods_id`) REFERENCES `goods` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='购物车表';

-- 初始化购物车数据(对应MockData.ets中的mockShopCardInfo - 前3个商品)
-- 注意：尺码使用'M'与CardDetailPage的尺码选项['XS','S','M','L','XL','XXL']保持一致
INSERT INTO `cart` (`user_id`, `goods_id`, `quantity`, `checked`, `selected_proper_color`, `selected_proper_size`) VALUES
(1, 1, 1, 1, '黑色', 'M'),
(1, 2, 1, 1, '黑色', 'M'),
(1, 3, 1, 0, '黑色', 'M');

-- -------------------------------------------
-- 5. 收货地址表 (address) ✨新增
-- 说明: 用户收货地址管理，支持默认地址
-- -------------------------------------------
CREATE TABLE `address` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '地址ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `receiver_name` VARCHAR(50) NOT NULL COMMENT '收件人姓名',
    `receiver_phone` VARCHAR(20) NOT NULL COMMENT '联系电话',
    `province` VARCHAR(50) NOT NULL COMMENT '省份',
    `city` VARCHAR(50) NOT NULL COMMENT '城市',
    `district` VARCHAR(50) NOT NULL COMMENT '区/县',
    `detail_address` VARCHAR(200) NOT NULL COMMENT '详细地址(街道/门牌)',
    `postal_code` VARCHAR(10) DEFAULT NULL COMMENT '邮政编码',
    `is_default` TINYINT DEFAULT 0 COMMENT '是否默认地址: 0否/1是(同一用户只能有1个默认)',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    CONSTRAINT `fk_address_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收货地址表';

-- 初始化测试地址数据(用户ID=1)
INSERT INTO `address` (`user_id`, `receiver_name`, `receiver_phone`, `province`, `city`, `district`, `detail_address`, `postal_code`, `is_default`) VALUES
(1, '张三', '13800138000', '广东省', '深圳市', '南山区', '科技园南路1000号A座1201室', '518000', 1),
(1, '李四', '13900139000', '北京市', '北京市', '朝阳区', '建国路88号万达广场B座1502室', '100020', 0);

-- ============================================
-- 订单系统模块（新增）
-- 对应前端: OrderPage / OrderManager / Shop.ets结算 / CardDetailPage立即购买
-- 创建时间: 2026-05-13
-- ============================================

-- -------------------------------------------
-- 6. 订单表 (order_info)
-- 说明: 存储订单主信息
-- -------------------------------------------
CREATE TABLE `order_info` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '订单ID',
    `order_no` VARCHAR(64) NOT NULL COMMENT '订单编号(唯一)',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `address_id` BIGINT DEFAULT NULL COMMENT '收货地址ID',
    `total_amount` DECIMAL(10,2) NOT NULL COMMENT '订单总金额',
    `status` TINYINT DEFAULT 0 COMMENT '订单状态: 0待付款/1待发货/2待收货/3已完成/4已取消',
    `remark` VARCHAR(500) DEFAULT NULL COMMENT '订单备注',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_order_no` (`order_no`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_status` (`status`),
    CONSTRAINT `fk_order_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_order_address` FOREIGN KEY (`address_id`) REFERENCES `address` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

-- -------------------------------------------
-- 7. 订单商品明细表 (order_item)
-- 说明: 存储订单中的商品快照信息
-- -------------------------------------------
CREATE TABLE `order_item` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '明细ID',
    `order_id` BIGINT NOT NULL COMMENT '订单ID',
    `goods_id` BIGINT NOT NULL COMMENT '商品ID',
    `goods_name` VARCHAR(200) NOT NULL COMMENT '商品名称(快照)',
    `goods_image` VARCHAR(500) DEFAULT NULL COMMENT '商品图片(快照)',
    `goods_price` DECIMAL(10,2) NOT NULL COMMENT '商品单价(快照)',
    `quantity` INT NOT NULL COMMENT '购买数量',
    `proper_color` VARCHAR(100) DEFAULT NULL COMMENT '选择的颜色',
    `proper_size` VARCHAR(20) DEFAULT NULL COMMENT '选择的尺码',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_order_id` (`order_id`),
    CONSTRAINT `fk_item_order` FOREIGN KEY (`order_id`) REFERENCES `order_info` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_item_goods` FOREIGN KEY (`goods_id`) REFERENCES `goods` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单商品明细表';

-- -------------------------------------------
-- 初始化测试订单数据
-- 数据说明:
--   - 4条不同状态的测试订单
--   - 5条订单明细记录
-- -------------------------------------------
INSERT INTO `order_info` (`order_no`, `user_id`, `address_id`, `total_amount`, `status`, `remark`) VALUES
('VIP202605130001', 1, 1, 258.00, 0, '测试订单-待付款'),
('VIP202605130002', 1, 1, 99.00, 1, '测试订单-待发货'),
('VIP202605130003', 1, 2, 453.00, 2, '测试订单-待收货'),
('VIP202605130004', 1, NULL, 134.00, 3, '测试订单-已完成');

INSERT INTO `order_item` (`order_id`, `goods_id`, `goods_name`, `goods_image`, `goods_price`, `quantity`, `proper_color`, `proper_size`) VALUES
(1, 1, '[2026新款]秋冬男士牛仔裤男宽松直筒弹力休闲长裤子男装', 'man1.jpg', 134.00, 1, '黑色', '均码'),
(1, 2, '[2026新款]秋冬男士卫衣男宽松弹力休闲男装', 'man2.jpg', 124.00, 1, '黑色', '均码'),
(2, 3, '[2026新款]秋冬男士短袖男宽松弹力休闲男装', 'man3.jpg', 99.00, 1, '黑色', '均码'),
(3, 6, '[2026新款]秋冬男士羽绒服男修身男装', 'man6.jpg', 453.00, 1, '黑色', 'M'),
(4, 1, '[2026新款]秋冬男士牛仔裤男宽松直筒弹力休闲长裤子男装', 'man1.jpg', 134.00, 1, '黑色', '均码');

-- 验证数据插入结果
SELECT
    'order_info 表' AS table_name,
    COUNT(*) AS record_count
FROM order_info
UNION ALL
SELECT
    'order_item 表',
    COUNT(*)
FROM order_item;

-- -------------------------------------------
-- 8. 索引优化查询性能
-- -------------------------------------------

-- 商品搜索索引(全文检索)
ALTER TABLE `goods` ADD FULLTEXT INDEX `ft_search` (`name`, `sub_title`);

-- 分类下商品数量统计视图(可选)
-- CREATE OR REPLACE VIEW v_category_goods_count AS
-- SELECT c.id AS category_id, c.name, COUNT(g.id) AS goods_count
-- FROM category c LEFT JOIN goods g ON c.id = g.category_id AND g.status = 1
-- GROUP BY c.id, c.name;

-- ============================================
-- 数据库初始化完成
-- 统计信息:
--   用户(user): 1 条
--   分类(category): 18 条
--   商品(goods): 11 条
--   购物车(cart): 3 条
--   地址(address): 2 条
--   订单(order_info): 4 条 (待付款1/待发货1/待收货1/已完成1)
--   订单明细(order_item): 5 条
-- ============================================

-- 第三阶段：验证数据完整性
SELECT '✅ 数据库重建完成！' AS status;

-- 显示各表记录数
SELECT
    '📊 表结构统计' AS category,
    table_name,
    table_comment,
    CASE WHEN table_rows > 0 THEN CONCAT(table_rows, ' 条') ELSE '空表' END AS data_count,
    create_time AS created_at
FROM information_schema.tables
WHERE table_schema = DATABASE()
    AND table_name IN ('user', 'category', 'goods', 'cart', 'address', 'order_info', 'order_item')
ORDER BY FIELD(table_name, 'user', 'category', 'goods', 'cart', 'address', 'order_info', 'order_item');

-- 显示各状态订单数量（如果有）
SELECT 
    '📦 订单状态分布' AS category,
    CASE status
        WHEN 0 THEN '待付款'
        WHEN 1 THEN '待发货'
        WHEN 2 THEN '待收货'
        WHEN 3 THEN '已完成'
        WHEN 4 THEN '已取消'
        ELSE '未知'
    END AS order_status,
    COUNT(*) AS count
FROM order_info
GROUP BY status
ORDER BY status;

-- ============================================
-- 收藏夹模块（新增）
-- 对应前端: FavoritePage / FavoriteManager / CardDetailPage收藏按钮
-- 创建时间: 2026-05-22
-- ============================================

-- -------------------------------------------
-- 8. 收藏表 (favorite)
-- 说明: 用户收藏的商品列表
-- -------------------------------------------
CREATE TABLE `favorite` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '收藏ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `goods_id` BIGINT NOT NULL COMMENT '商品ID',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_goods` (`user_id`, `goods_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_create_time` (`create_time`),
    CONSTRAINT `fk_favorite_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_favorite_goods` FOREIGN KEY (`goods_id`) REFERENCES `goods` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收藏表';

-- 初始化测试收藏数据(用户ID=1, 收藏前3个商品)
INSERT INTO `favorite` (`user_id`, `goods_id`) VALUES
(1, 1),
(1, 2),
(1, 3);

-- 验证数据插入结果
SELECT
    'favorite 表' AS table_name,
    COUNT(*) AS record_count
FROM favorite;
