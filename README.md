# 唯品会电商平台 - VIP Shop

> 一个基于 HarmonyOS ArkTS 前端和 Spring Boot 后端的电商平台项目

## 📖 项目概述

本项目是一个模仿唯品会的电商平台，包含完整的前端应用和后端服务。项目采用现代化的技术栈，提供用户注册登录、商品浏览、购物车管理、订单处理等核心电商功能。

### ✨ 功能特性

**用户模块**
- 用户注册与登录
- 用户信息管理
- 个人资料编辑

**商品模块**
- 商品分类浏览
- 商品搜索功能
- 商品详情展示

**购物车模块**
- 购物车添加/删除商品
- 购物车商品数量修改
- 购物车商品规格选择

**订单模块**
- 订单创建与提交
- 订单状态管理
- 订单列表查询

**收藏模块**
- 商品收藏功能
- 收藏列表管理

**地址模块**
- 收货地址管理
- 默认地址设置

## 🛠️ 技术栈

### 前端技术

| 技术 | 版本 | 说明 |
|------|------|------|
| HarmonyOS | 4.0+ | 操作系统 |
| ArkTS | 4.0+ | 编程语言 |
| ArkUI | 4.0+ | UI框架 |

### 后端技术

| 技术 | 版本 | 说明 |
|------|------|------|
| Java | 17 | 编程语言 |
| Spring Boot | 3.2.0 | 后端框架 |
| MyBatis-Plus | 3.5.5 | ORM框架 |
| MySQL | 8.0+ | 数据库 |
| JWT | 0.12.3 | 身份认证 |

## 📋 环境要求

### 前端环境

- DevEco Studio 4.0+
- Node.js 18.0+
- HarmonyOS SDK 4.0+

### 后端环境

- JDK 17+
- Maven 3.8+
- MySQL 8.0+

## 🚀 安装与配置

### 1. 克隆项目

```bash
git clone https://github.com/TT-1224/weipinhui.git
cd weipinhui
```

### 2. 数据库配置

**创建数据库**

```sql
CREATE DATABASE IF NOT EXISTS wph 
  DEFAULT CHARACTER SET utf8mb4 
  DEFAULT COLLATE utf8mb4_unicode_ci;
```

**导入数据库脚本**

```bash
mysql -u root -p wph < database/vip_shop.sql
```

### 3. 后端配置

**修改数据库连接信息**

编辑 `backend/src/main/resources/application.yml`：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/wph?useUnicode=true&characterEncoding=utf-8&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
    username: your_username    # 替换为你的数据库用户名
    password: your_password    # 替换为你的数据库密码
```

**启动后端服务**

```bash
cd backend
mvn spring-boot:run
```

服务启动后访问：http://localhost:8080

### 4. 前端配置

**打开项目**

使用 DevEco Studio 打开 `frontend` 目录。

**配置后端接口地址**

编辑 `frontend/entry/src/main/ets/utils/HttpUtil.ets`，确保 API 地址正确指向后端服务。

**构建与运行**

在 DevEco Studio 中：
1. 连接 HarmonyOS 设备或启动模拟器
2. 点击运行按钮构建并部署应用

## 📱 基本使用

### 1. 用户注册

```bash
POST /api/auth/register
Content-Type: application/json

{
  "username": "testuser",
  "password": "123456",
  "phone": "13800138000"
}
```

### 2. 用户登录

```bash
POST /api/auth/login
Content-Type: application/json

{
  "username": "testuser",
  "password": "123456"
}
```

### 3. 获取商品列表

```bash
GET /api/goods/list?page=1&size=10
Authorization: Bearer <token>
```

### 4. 添加商品到购物车

```bash
POST /api/cart/add
Content-Type: application/json
Authorization: Bearer <token>

{
  "goodsId": 1,
  "quantity": 1,
  "specification": "M"
}
```

## 🎯 API 接口文档

### 认证接口

| 接口 | 方法 | 描述 |
|------|------|------|
| `/api/auth/register` | POST | 用户注册 |
| `/api/auth/login` | POST | 用户登录 |

### 商品接口

| 接口 | 方法 | 描述 |
|------|------|------|
| `/api/goods/list` | GET | 获取商品列表 |
| `/api/goods/{id}` | GET | 获取商品详情 |
| `/api/goods/category/{id}` | GET | 获取分类商品 |

### 购物车接口

| 接口 | 方法 | 描述 |
|------|------|------|
| `/api/cart/list` | GET | 获取购物车列表 |
| `/api/cart/add` | POST | 添加商品到购物车 |
| `/api/cart/update` | PUT | 更新购物车商品数量 |
| `/api/cart/delete/{id}` | DELETE | 删除购物车商品 |

### 订单接口

| 接口 | 方法 | 描述 |
|------|------|------|
| `/api/order/create` | POST | 创建订单 |
| `/api/order/list` | GET | 获取订单列表 |
| `/api/order/{id}` | GET | 获取订单详情 |

### 收藏接口

| 接口 | 方法 | 描述 |
|------|------|------|
| `/api/favorite/list` | GET | 获取收藏列表 |
| `/api/favorite/add` | POST | 添加收藏 |
| `/api/favorite/delete/{id}` | DELETE | 删除收藏 |

### 地址接口

| 接口 | 方法 | 描述 |
|------|------|------|
| `/api/address/list` | GET | 获取地址列表 |
| `/api/address/add` | POST | 添加地址 |
| `/api/address/update` | PUT | 更新地址 |
| `/api/address/delete/{id}` | DELETE | 删除地址 |

## 🔧 高级功能

### JWT 认证

后端采用 JWT (JSON Web Token) 进行身份认证：

1. 用户登录成功后，服务端返回 `accessToken`
2. 后续请求需在请求头中携带 `Authorization: Bearer <token>`
3. Token 有效期为 7 天

### 全局异常处理

后端实现了全局异常处理器，统一返回格式：

```json
{
  "code": 400,
  "message": "错误信息",
  "data": null
}
```

### 数据校验

使用 Spring Validation 进行请求参数校验：

```java
@NotBlank(message = "用户名不能为空")
private String username;

@Size(min = 6, max = 20, message = "密码长度必须在6-20之间")
private String password;
```

## ❓ 常见问题解答

### Q1: 后端服务启动失败

**原因**：数据库连接配置错误或 MySQL 服务未启动

**解决方案**：
1. 确保 MySQL 服务已启动
2. 检查 `application.yml` 中的数据库连接信息是否正确
3. 确保数据库 `wph` 已创建并导入脚本

### Q2: 前端无法连接后端

**原因**：网络配置问题或后端服务未启动

**解决方案**：
1. 确保后端服务正常运行在 http://localhost:8080
2. 检查前端 HttpUtil 配置的 API 地址
3. 确保防火墙允许 8080 端口访问

### Q3: 图片无法显示

**原因**：图片资源路径配置错误

**解决方案**：
1. 检查图片资源是否存在于 `frontend/entry/src/main/resources/base/media/`
2. 确保使用正确的资源引用方式 `$r('app.media.image_name')`

### Q4: 订单创建失败

**原因**：购物车为空或库存不足

**解决方案**：
1. 确保购物车中有商品
2. 检查商品库存是否充足
3. 确保收货地址已设置

## 🤝 贡献指南

### 开发流程

1. Fork 本仓库
2. 创建特性分支：`git checkout -b feature/your-feature`
3. 提交代码：`git commit -m 'Add some feature'`
4. 推送到分支：`git push origin feature/your-feature`
5. 创建 Pull Request

### 代码规范

**Java 代码规范**
- 遵循 Google Java 代码规范
- 使用 Lombok 简化代码
- 方法命名使用小驼峰命名法

**ArkTS 代码规范**
- 遵循 HarmonyOS ArkTS 代码规范
- 使用 @Entry 和 @Component 装饰器
- 状态变量使用 @State、@Prop、@Link 等装饰器

**提交信息规范**

```
<类型>(<模块>): <描述>

<详细说明>
```

类型说明：
- `feat`: 新功能
- `fix`: 修复 Bug
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 代码重构
- `test`: 测试用例

## 📄 许可信息

### 版权声明

Copyright (c) 2024 VIP Shop. All rights reserved.

### 许可证

本项目仅供学习和研究使用，未经授权不得用于商业用途。

### 免责声明

本项目为学习演示项目，与唯品会官方无任何关联。项目中使用的图片和数据仅供演示，如有侵权请联系删除。

---

## 📞 联系方式

如有问题或建议，请通过以下方式联系：

- GitHub Issues: [https://github.com/TT-1224/weipinhui/issues](https://github.com/TT-1224/weipinhui/issues)

---

**项目状态**: 🚀 持续开发中

**最后更新**: 2024年