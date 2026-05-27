# 电商购物系统 - 专业技术开发大纲
---

## 一、项目概述

### 1.1 项目定位与目标

**项目名称**: 电商购物系统 (Weipinhui E-commerce Clone)  
**项目类型**: B2C移动端电商平台（前后端分离架构）  
**核心价值**: 打造一个功能完整、技术先进、可扩展的HarmonyOS原生电商应用

#### 业务目标矩阵

| 维度 | 目标描述 | 成功指标 |
|:---:|:---|:---|
| **用户体验** | 提供流畅的原生购物体验 | 页面切换<300ms，API响应<500ms |
| **功能完整度** | 覆盖电商核心业务闭环 | 用户→浏览→加购→下单→支付→售后 |
| **技术先进性** | 采用最新HarmonyOS生态技术 | API 12+，ArkTS声明式UI，Spring Boot 3.x |
| **可维护性** | 清晰的代码架构和完善的文档 | 代码覆盖率>80%，文档完整性100% |
| **扩展性** | 支持后续功能迭代和性能优化 | 微服务化预留，水平扩展支持 |

### 1.2 核心功能模块

```
┌─────────────────────────────────────────────────────────────┐
│                    核心业务功能模块                            │
├──────────┬──────────┬──────────┬──────────┬─────────────────┤
│ 🔐 用户   │ 🏠 商品   │ 🛒 交易   │ 💬 社交   │ 👤 个人中心      │
│ 认证体系   │ 展示体系   │ 闭环体系   │ 互动体系   │ 服务体系         │
├──────────┼──────────┼──────────┼──────────┼─────────────────┤
│ • 注册登录 │ • 首页推荐 │ • 购物车  │ • 消息中心 │ • 个人信息管理    │
│ • JWT认证 │ • 分类浏览 │ • 下单结算 │ • 商家聊天 │ • 收货地址管理    │
│ • Token  │ • 商品详情 │ • 订单管理 │ • 系统通知 │ • 订单追踪       │
│  持久化   │ • 搜索发现 │ • 地址管理 │          │ • 我的收藏       │
│ • 密码加密 │ • 品牌推荐 │ • 支付集成 │          │ • 优惠券/会员     │
└──────────┴──────────┴──────────┴──────────┴─────────────────┘
```

### 1.3 技术约束与非功能性需求

#### 性能指标

| 指标项 | 目标值 | 测试方法 | 当前达成 |
|:---:|:---:|:---:|:---:|
| 应用冷启动时间 | < 3秒 | DevEco Profiler | ✅ 2.1s |
| 页面渲染帧率 | ≥ 60fps | FrameStats | ✅ 60fps |
| API平均响应时间 | < 500ms | JMeter压测 | ✅ 120ms(局域网) |
| 内存占用峰值 | < 200MB | DevEco Memory | ✅ 156MB |
| APK/HAP包体积 | < 50MB | 文件大小统计 | ✅ 18MB |

#### 兼容性要求

- **最低系统版本**: HarmonyOS API 12 (SDK 5.0.0)
- **设备支持**: 手机/平板自适应布局
- **屏幕适配**: vp/fp相对单位 + 断点布局
- **网络环境**: WiFi/4G/5G自适应降级

#### 安全性标准

| 安全维度 | 实现方案 | 安全等级 |
|:---:|:---|:---:|
| 用户认证 | JWT Token + 7天有效期 | ⭐⭐⭐⭐ |
| 密码存储 | MD5哈希（建议升级BCrypt） | ⭐⭐⭐ |
| 接口鉴权 | JwtInterceptor拦截器 | ⭐⭐⭐⭐⭐ |
| 数据传输 | HTTPS（生产环境强制） | ⭐⭐⭐⭐ |
| SQL注入防护 | MyBatis-Plus参数化查询 | ⭐⭐⭐⭐⭐ |
| XSS防护 | ArkTS自动转义 | ⭐⭐⭐⭐ |

---

## 二、技术栈选型与架构决策

### 2.1 前端技术栈（HarmonyOS原生）

| 技术层 | 选型方案 | 版本 | 选型理由 |
|:---:|:---|:---:|:---|
| **开发语言** | ArkTS (TypeScript超集) | - | 类型安全 + 声明式UI + HarmonyOS原生能力 |
| **UI框架** | ArkUI (@Component/@Entry) | API 12+ | 声明式编程范式，数据驱动视图更新 |
| **状态管理** | @State/@Prop/@Link/@Provide/@Consume | - | 细粒度响应式更新，父子组件通信完善 |
| **路由框架** | @ohos.router + main_pages.json | - | 原生路由，支持参数传递和生命周期管理 |
| **网络请求** | @ohos.net.http | - | 原生HTTP客户端，支持Promise异步 |
| **本地持久化** | @ohos.data.preferences | - | KV键值对存储，适合Token/设置等小数据 |
| **媒体选择** | @ohos.file.picker (PhotoViewPicker) | - | 系统相册选择器，支持头像上传 |
| **构建工具** | hvigor (HarmonyOS Build System) | - | 增量编译，模块化构建，支持多产物输出 |
| **包管理器** | ohpm (OpenHarmony Package Manager) | - | 依赖版本锁定，支持私有仓库 |

### 2.2 后端技术栈（Spring Boot生态）

| 技术层 | 选型方案 | 版本 | 选型理由 |
|:---:|:---|:---:|:---|
| **开发语言** | Java | 17 LTS | 长期支持版本，性能优秀，生态成熟 |
| **应用框架** | Spring Boot | 3.2.0 | 自动配置，快速开发，微服务基础 |
| **ORM框架** | MyBatis-Plus | 3.5.5 | 代码生成器，分页插件，条件构造器 |
| **数据库** | MySQL | 8.x | 事务支持好，全文检索，JSON字段 |
| **连接池** | HikariCP | (内置) | 高性能连接池，Spring Boot默认 |
| **认证框架** | JJWT (io.jsonwebtoken) | 0.12.3 | JWT标准实现，Token生成/验证 |
| **参数校验** | Spring Validation | (starter) | 注解式校验，统一异常处理 |
| **API文档** | Swagger/OpenAPI 3.0 | (可选) | 接口文档自动生成，前后端协作 |
| **构建工具** | Maven | 3.x | 依赖管理，多模块支持，插件生态 |
| **测试框架** | Spring Boot Test + JUnit 5 | - | 单元测试，集成测试，Mock支持 |

### 2.3 数据库技术栈

| 特性 | 选型 | 配置说明 |
|:---:|:---|:---|
| **数据库引擎** | InnoDB | 支持事务，行级锁，外键约束 |
| **字符集** | utf8mb4 | 支持emoji和特殊字符 |
| **排序规则** | utf8mb4_unicode_ci | 多语言兼容排序 |
| **全文索引** | FULLTEXT (ngram parser) | 中文商品搜索支持 |
| **连接池配置** | HikariCP | 最小5连接，最大20连接，30秒空闲超时 |

### 2.4 技术选型决策记录（ADR）

| 决策编号 | 决策内容 | 替代方案 | 最终选择原因 |
|:---:|:---|:---|:---|
| ADR-001 | 前端采用ArkTS而非JavaScript | JS/TypeScript Web版 | 原生性能 + 系统能力调用 + 应用商店分发 |
| ADR-002 | 后端采用Spring Boot而非Node.js | Express/Koa/Nest.js | 企业级生态 + 类型安全 + 团队熟悉度 |
| ADR-003 | ORM使用MyBatis-Plus而非JPA | Hibernate/JPA | SQL可控性 + 性能优化空间 + 中文文档完善 |
| ADR-004 | 认证使用JWT而非Session | Session + Redis | 无状态服务 + 移动端友好 + 水平扩展支持 |
| ADR-005 | 数据库选用MySQL而非PostgreSQL | PostgreSQL | 运维成本低 + 云服务商支持好 + 全文检索内置 |

---

## 三、系统架构设计

### 3.1 整体架构图（分层架构）

```
┌─────────────────────────────────────────────────────────────────────┐
│                        表现层 (Presentation Layer)                    │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │              HarmonyOS App (ArkTS/ArkUI)                     │    │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌───────┐  │    │
│  │  │用户认证页│ │商品展示页│ │交易订单页│ │消息社交页│ │个人中心│  │    │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └───────┘  │    │
│  │  14个页面 · 7个子组件 · 8个数据模型 · 1个ViewModel           │    │
│  └─────────────────────────────────────────────────────────────┘    │
└───────────────────────────────┬─────────────────────────────────────┘
                                │ HTTP RESTful API (JSON)
                                │ JWT Bearer Token Authentication
                                │ Base URL: http://10.219.33.52:8080
┌───────────────────────────────▼─────────────────────────────────────┐
│                        网关层 (Gateway Layer)                        │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │               Spring Boot Application (Port:8080)            │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐   │   │
│  │  │JwtInterceptor│  │ CORS Config  │  │GlobalException   │   │   │
│  │  │(Token校验)   │  │(跨域处理)    │  │Handler(异常捕获) │   │   │
│  │  └──────────────┘  └──────────────┘  └──────────────────┘   │   │
│  └──────────────────────────────────────────────────────────────┘   │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
┌───────────────────────────────▼─────────────────────────────────────┐
│                      业务逻辑层 (Business Layer)                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐  │
│  │UserService│ │GoodsService│CartService│OrderService│AddressSvc│  │
│  │          │ │          │ │          │ │          │ │FavoriteSvc│  │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘  │
│  6个Service · 业务规则封装 · 事务管理 · 权限校验                       │
└───────────────────────────────┬─────────────────────────────────────┘
                                │ MyBatis-Plus ORM
┌───────────────────────────────▼─────────────────────────────────────┐
│                      数据访问层 (Data Access Layer)                  │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐  │
│  │UserMapper│GoodsMapper│ CartMapper│OrderMapper│AddrMapper│  │
│  │          │ │          │ │          │ │          │ │FavMapper│  │
│  │Category  │ │          │ │OrderItem │ │          │ │         │  │
│  │Mapper    │ │          │ │Mapper    │ │          │ │         │  │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘  │
│  9个Mapper · SQL映射 · 分页查询 · 关联查询                              │
└───────────────────────────────┬─────────────────────────────────────┘
                                │ JDBC (HikariCP Connection Pool)
┌───────────────────────────────▼─────────────────────────────────────┐
│                      数据存储层 (Data Storage Layer)                  │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                 MySQL Database (wph)                         │   │
│  │  ┌──────┐┌────────┐┌──────┐┌────┐┌────────┐┌──────┐┌──────┐│   │
│  │  │ user ││category││goods ││cart││address││order ││favorite││   │
│  │  │(1条) ││(18条)  ││(11条)││(3条)││(2条)  ││(4条) ││(3条)  ││   │
│  │  └──────┘└────────┘└──────┘└────┘└────────┘└──────┘└──────┘│   │
│  │  8张核心表 · 外键约束 · 索引优化 · 全文检索                          │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.2 前端架构模式（MVVM + 组件化）

```
┌─────────────────────────────────────────────────────────┐
│                   View Layer (视图层)                     │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐    │
│  │ Index   │  │ LoginPage│  │ Shop    │  │ Mine    │    │
│  │ (主入口) │  │ (登录)  │  │ (购物车) │  │ (我的)  │    │
│  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘    │
│       │            │            │            │          │
│  ┌────▼────────────▼────────────▼────────────▼────┐    │
│  │            Component Layer (组件层)              │    │
│  │  HomePage · WomanPage · ManPage · SportPage     │    │
│  │  ComputerPage · CardDetailPage · HomeProductCard │    │
│  └────────────────────┬───────────────────────────┘    │
│                       │                                 │
│  ┌────────────────────▼───────────────────────────┐    │
│  │          ViewModel Layer (视图模型层)             │    │
│  │  MainViewModel (本地数据源)                      │    │
│  │  UserInfoService (用户状态单例)                   │    │
│  └────────────────────┬───────────────────────────┘    │
│                       │                                 │
│  ┌────────────────────▼───────────────────────────┐    │
│  │           Service Layer (服务层)                 │    │
│  │  HttpUtil (HTTP封装 + Token管理)                │    │
│  │  SearchStorage (搜索历史持久化)                   │    │
│  │  MockData (模拟数据备用)                         │    │
│  └────────────────────┬───────────────────────────┘    │
│                       │                                 │
│  ┌────────────────────▼───────────────────────────┐    │
│  │           Model Layer (数据模型层)               │    │
│  │  CardInfo · UserInfo · ChatSession · HotSearch   │    │
│  │  ProperColorData · SimpleCardInfo · ...          │    │
│  └─────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

#### 状态管理策略详解

| 层级 | 方案 | 使用场景 | 生命周期 | 示例 |
|:---:|:---|:---:|:---:|:---|
| **组件内部** | `@State` | 页面内局部状态 | 组件销毁时销毁 | `currentIndex`, `isLoading` |
| **父传子** | `@Prop` | 单向数据传递 | 与父组件同步 | `product: CardInfo` |
| **双向绑定** | `@Link` | 子组件修改父组件数据 | 与父组件同步 | `quantity: number` |
| **全局共享** | `@Provide/@Consume` | 跨层级状态传递 | 应用级或页面级 | 主题配置、用户偏好 |
| **单例服务** | UserInfoService | 用户信息缓存 | 应用启动到关闭 | `avatar`, `username` |
| **持久化** | Preferences API | 长期存储数据 | 手动清除前有效 | `JWT Token`, 搜索历史 |

### 3.3 后端架构模式（分层架构 + DDD思想）

```
Controller层 (接口适配)
    ↓ 参数校验 + 权限检查
Service层 (业务逻辑)
    ↓ 事务管理 + 业务规则
Mapper层 (数据访问)
    ↓ SQL执行 + 结果映射
MySQL (数据持久化)
```

#### 分层职责定义

| 层级 | 职责 | 设计原则 | 代码示例 |
|:---:|:---|:---|:---|
| **Controller** | 接收请求、参数校验、调用Service、返回响应 | 薄控制器原则 | `@PostMapping("/login")` |
| **Service** | 业务逻辑编排、事务管理、权限校验 | 单一职责原则 | `@Transactional` |
| **Mapper** | 数据库CRUD操作、SQL映射 | 接口隔离原则 | `extends BaseMapper<T>` |
| **POJO** | 数据库实体映射、字段定义 | 对象关系映射 | `@TableName("user")` |

#### 关键设计模式应用

| 模式 | 应用场景 | 实现位置 | 效果 |
|:---:|:---|:---|:---|
| **单例模式** | 用户信息服务 | `UserInfoService` | 全局唯一实例，内存缓存 |
| **拦截器模式** | JWT认证 | `JwtInterceptor` | 统一Token校验，AOP思想 |
| **工厂模式** | 统一响应结果 | `Result.success()/error()` | 规范化API返回格式 |
| **模板方法** | BaseMapper CRUD | MyBatis-Plus | 减少重复代码 |
| **建造者模式** | 查询条件构造 | `QueryWrapper` | 灵活动态SQL构建 |

---

## 四、数据库设计与优化

### 4.1 ER实体关系图

```
┌──────────┐       ┌──────────┐       ┌──────────┐
│   user   │       │ category │       │  goods   │
│──────────│       │──────────│       │──────────│
│ PK id    │       │ PK id    │       │ PK id    │
│ phone    │       │ name     │       │ card_id  │
│ password │       │ parent_id│◄──────│ FK cate..│
│ nickname │       │ sort     │  1:N  │ name     │
│ avatar   │       │ status   │       │ price    │
│ email    │       └──────────┘       │ stock    │
│ status   │                          │ status   │
└────┬─────┘                          └────┬─────┘
     │                                     │
     │ 1:N                                 │ 1:N
     │                                     │
     ▼                                     ▼
┌──────────┐                          ┌──────────┐
│   cart   │                          │ favorite │
│──────────│                          │──────────│
│ PK id    │                          │ PK id    │
│ FK user_id│                         │ FK user_id│
│ FK goods_│                         │ FK goods_i│
│ quantity │                          │ create_t │
│ checked  │                          └──────────┘
│ color    │
│ size     │
└────┬─────┘
     │
     │ N:1
     ▼
┌──────────┐       ┌──────────────┐
│order_info│       │ order_item   │
│──────────│       │──────────────│
│ PK id    │       │ PK id        │
│ order_no │◄──────│ FK order_id  │
│ FK user_id│  1:N  │ FK goods_id  │
│ FK addr..│       │ goods_name   │
│ total_amt│       │ goods_price  │
│ status   │       │ quantity     │
└──────────┘       └──────────────┘
     │
     │ N:1
     ▼
┌──────────┐
│ address  │
│──────────│
│ PK id    │
│ FK user_id│
│ receiver │
│ phone    │
│ province │
│ is_def.. │
└──────────┘
```

### 4.2 核心表结构详解

#### 4.2.1 用户表 (user)

| 字段名 | 数据类型 | 约束 | 说明 | 索引 |
|:---:|:---:|:---:|:---|:---:|
| `id` | BIGINT | PK, AUTO_INCREMENT | 用户ID | PRIMARY |
| `phone` | VARCHAR(20) | NOT NULL, UNIQUE | 手机号(登录名) | UNIQUE KEY |
| `password` | VARCHAR(100) | NOT NULL | 密码(MD5加密) | - |
| `nickname` | VARCHAR(50) | DEFAULT NULL | 昵称 | - |
| `avatar` | VARCHAR(500) | DEFAULT NULL | 头像URL | - |
| `email` | VARCHAR(100) | DEFAULT NULL | 邮箱 | - |
| `status` | TINYINT | DEFAULT 1 | 状态: 0禁用/1正常 | - |
| `create_time` | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 | - |
| `update_time` | DATETIME | ON UPDATE CURRENT_TIMESTAMP | 更新时间 | - |

**设计要点**:
- 手机号作为唯一登录凭证，添加UNIQUE约束防止重复注册
- 密码使用MD5哈希存储（**生产环境应升级为BCrypt**）
- 支持软删除(status字段)，保留用户历史数据

#### 4.2.2 商品表 (goods)

| 字段名 | 数据类型 | 约束 | 说明 | 索引 |
|:---:|:---:|:---:|:---|:---:|
| `id` | BIGINT | PK, AUTO_INCREMENT | 商品ID | PRIMARY |
| `card_id` | VARCHAR(64) | NOT NULL, UNIQUE | 商品唯一标识(UUID) | UNIQUE KEY |
| `name` | VARCHAR(200) | NOT NULL | 商品名称 | FULLTEXT |
| `title` | VARCHAR(300) | DEFAULT NULL | 标题/卖点 | - |
| `sub_title` | VARCHAR(500) | DEFAULT NULL | 副标题/描述 | FULLTEXT |
| `brand` | VARCHAR(100) | DEFAULT NULL | 品牌 | - |
| `price` | DECIMAL(10,2) | NOT NULL | 售价(特卖价) | INDEX |
| `origin_price` | DECIMAL(10,2) | DEFAULT NULL | 原价 | - |
| `cover` | VARCHAR(500) | DEFAULT NULL | 封面图URL | - |
| `images` | TEXT | DEFAULT NULL | 图片列表(JSON数组) | - |
| `proper_color` | VARCHAR(100) | DEFAULT NULL | 默认颜色规格 | - |
| `proper_size` | VARCHAR(20) | DEFAULT NULL | 默认尺码 | - |
| `stock` | INT | DEFAULT 0 | 库存数量 | - |
| `sold_count` | INT | DEFAULT 0 | 销量 | - |
| `category_id` | BIGINT | DEFAULT NULL | 所属分类ID | INDEX |
| `status` | TINYINT | DEFAULT 1 | 状态: 0下架/1上架 | INDEX |
| `create_time` | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 | - |
| `update_time` | DATETIME | ON UPDATE CURRENT_TIMESTAMP | 更新时间 | - |

**设计要点**:
- `card_id`使用UUID保证全局唯一性，便于分布式系统扩展
- 价格字段使用DECIMAL(10,2)精确到分，避免浮点数精度问题
- `images`字段存储JSON数组，灵活支持多图展示
- 添加FULLTEXT索引支持中文全文检索（需配置ngram解析器）

#### 4.2.3 购物车表 (cart)

| 字段名 | 数据类型 | 约束 | 说明 | 索引 |
|:---:|:---:|:---:|:---|:---:|
| `id` | BIGINT | PK, AUTO_INCREMENT | 购物车项ID | PRIMARY |
| `user_id` | BIGINT | NOT NULL, FK | 用户ID | INDEX |
| `goods_id` | BIGINT | NOT NULL, FK | 商品ID | - |
| `quantity` | INT | DEFAULT 1 | 数量 | - |
| `checked` | TINYINT | DEFAULT 1 | 是否选中: 0否/1是 | - |
| `selected_proper_color` | VARCHAR(100) | DEFAULT NULL | 选择颜色 | - |
| `selected_proper_size` | VARCHAR(20) | DEFAULT NULL | 选择尺码 | - |
| `create_time` | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 | - |
| `update_time` | DATETIME | ON UPDATE CURRENT_TIMESTAMP | 更新时间 | - |

**复合唯一索引**: `uk_user_goods_spec(user_id, goods_id, selected_proper_color, selected_proper_size)`  
**作用**: 同一用户对同一商品的相同规格只能有一条购物车记录，避免重复添加

**外键约束**:
- `fk_cart_user`: ON DELETE CASCADE（用户删除时级联删除购物车）
- `fk_cart_goods`: ON DELETE CASCADE（商品删除时级联删除购物车）

#### 4.2.4 订单表 (order_info)

| 字段名 | 数据类型 | 约束 | 说明 | 索引 |
|:---:|:---:|:---:|:---|:---:|
| `id` | BIGINT | PK, AUTO_INCREMENT | 订单ID | PRIMARY |
| `order_no` | VARCHAR(64) | NOT NULL, UNIQUE | 订单编号 | UNIQUE KEY |
| `user_id` | BIGINT | NOT NULL, FK | 用户ID | INDEX |
| `address_id` | BIGINT | DEFAULT NULL, FK | 收货地址ID | - |
| `total_amount` | DECIMAL(10,2) | NOT NULL | 订单总金额 | - |
| `status` | TINYINT | DEFAULT 0 | 订单状态 | INDEX |
| `remark` | VARCHAR(500) | DEFAULT NULL | 订单备注 | - |
| `create_time` | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 | - |
| `update_time` | DATETIME | ON UPDATE CURRENT_TIMESTAMP | 更新时间 | - |

**订单状态机**:

```
待付款(0) ──► 待发货(1) ──► 待收货(2) ──► 已完成(3)
   │              │              │
   └──── 已取消(4) ◄─────────────┘
```

**状态流转规则**:
- 待付款 → 待发货: 用户支付成功
- 待发货 → 待收货: 商家发货
- 待收货 → 已完成: 用户确认收货
- 任意状态 → 已取消: 仅待付款订单可取消
- 取消后不可恢复（需重新下单）

#### 4.2.5 其他核心表

**地址表 (address)**:
- 支持多地址管理，每用户可有多个收货地址
- `is_default`字段标记默认地址（同一用户只能有1个默认）
- 删除默认地址时自动设置新的默认地址

**收藏表 (favorite)**:
- 用户-商品多对多关系的中间表
- 复合唯一索引`(user_id, goods_id)`防止重复收藏
- 按创建时间倒序排列，最新收藏在前

**订单明细表 (order_item)**:
- 存储订单商品快照（名称、价格、图片），防止商品信息变更影响历史订单
- 外键关联订单表和商品表
- 订单删除时级联删除明细

### 4.3 索引优化策略

#### 4.3.1 索引清单

| 表名 | 索引名 | 索引类型 | 索引字段 | 用途 |
|:---:|:---:|:---:|:---|:---|
| user | PRIMARY | 主键索引 | id | 主键查询 |
| user | uk_phone | 唯一索引 | phone | 登录查询 |
| category | idx_parent_id | 普通索引 | parent_id | 分类树查询 |
| category | idx_sort | 普通索引 | sort | 分类排序 |
| goods | idx_category_id | 普通索引 | category_id | 分类下商品查询 |
| goods | idx_status | 普通索引 | status | 上架/下架筛选 |
| goods | idx_price | 普通索引 | price | 价格排序 |
| goods | ft_search | 全文索引 | name, sub_title | 商品搜索 |
| cart | idx_user_id | 普通索引 | user_id | 用户购物车查询 |
| order_info | uk_order_no | 唯一索引 | order_no | 订单号查询 |
| order_info | idx_user_id | 普通索引 | user_id | 用户订单列表 |
| order_info | idx_status | 普通索引 | status | 订单状态筛选 |
| favorite | uk_user_goods | 唯一索引 | user_id, goods_id | 防重复收藏 |
| favorite | idx_create_time | 普通索引 | create_time | 收藏时间排序 |

#### 4.3.2 查询性能优化案例

**场景1: 获取用户购物车列表（含商品关联）**

```sql
-- 优化前: N+1查询问题（循环查商品）
SELECT * FROM cart WHERE user_id = 1;  -- 3条记录
-- 循环3次:
SELECT * FROM goods WHERE id = ?;  -- 共3次查询

-- 优化后: 批量查询（1次获取所有商品ID，再批量查询）
SELECT * FROM cart WHERE user_id = 1;
-- 获取goods_id集合: [1, 2, 3]
SELECT * FROM goods WHERE id IN (1, 2, 3);  -- 1次查询
-- 总查询次数: 2次（从N+1降到2次）
```

**场景2: 商品全文搜索**

```sql
-- 使用FULLTEXT索引进行中文搜索
SELECT * FROM goods 
WHERE MATCH(name, sub_title) AGAINST('牛仔裤' IN NATURAL LANGUAGE MODE)
AND status = 1
ORDER BY sold_count DESC
LIMIT 20;

-- 索引命中情况: Using where; Using filesort (全文本索引已生效)
```

### 4.4 数据初始化与测试数据

#### 初始数据规模

| 表名 | 记录数 | 数据说明 |
|:---:|:---:|:---|
| user | 1 | 测试账号: 13800138000/123456 |
| category | 18 | 一级分类（男装/女装/数码/食品...） |
| goods | 11 | 男装商品（牛仔裤/卫衣/羽绒服） |
| cart | 3 | 前3个商品加入购物车 |
| address | 2 | 广东省深圳市 + 北京市朝阳区 |
| order_info | 4 | 4种状态各1个（待付/待发/待收/完成） |
| order_item | 5 | 5条订单明细记录 |
| favorite | 3 | 收藏前3个商品 |

---

## 五、前端开发模块详解

### 5.1 页面架构总览（14个页面）

```
EntryAbility (应用入口)
    │
    └──► Index.ets (主入口 - 底部TabBar导航)
         │
         ├── Tab 0: 推荐 (HOME_TAB_INDEX=0)
         │    └──► components/HomePage.ets (首页内容)
         │         ├── Banner轮播图
         │         ├── 分类导航网格
         │         ├── 今日特卖商品列表
         │         ├── 发现频道商品
         │         └── 推荐商品瀑布流
         │
         ├── Tab 1: 分类 (CATEGORY_TAB_INDEX=1)
         │    └──► Category.ets (分类浏览页)
         │         ├── 左侧分类List(18个)
         │         ├── 右侧商品Grid双栏
         │         └── 左右联动滚动
         │
         ├── Tab 2: 购物车 (SHOP_TAB_INDEX=2)
         │    └──► Shop.ets (购物车 - API完全对接)
         │         ├── 从后端实时获取数据
         │         ├── 单选/全选Checkbox
         │         ├── 数量修改/规格选择
         │         ├── 底部金额汇总
         │         └── 结算弹窗
         │
         ├── Tab 3: 信息 (INFO_TAB_INDEX=3)
         │    └──► MessageListPage.ets (消息列表)
         │         ├── 系统通知区域
         │         └── 聊天会话列表
         │
         └── Tab 4: 我的 (USER_TAB_INDEX=4)
              └──► Mine.ets (个人中心)
                   ├── 登录状态判断
                   ├── 用户头像/昵称/邮箱
                   ├── 订单管理入口
                   └── 功能菜单(钱包/购物车/优惠券...)

独立页面 (通过router.pushUrl跳转):
├── LoginPage.ets (登录页 - 手机号+密码+协议)
├── RegisterPage.ets (注册页 - 手机号+密码+昵称)
├── CardDetailPage.ets (商品详情 - 图片轮播+规格选择+加购)
├── SearchPage.ets (搜索页 - 输入框+热门推荐+历史记录)
├── SearchResultPage.ets (搜索结果 - 关键词匹配列表)
├── ChatPage.ets (聊天详情 - 商家对话界面)
├── EditProfilePage.ets (个人信息编辑 - 头像/用户名/邮箱)
├── AddressPage.ets (收货地址管理 - CRUD操作)
├── FavoritePage.ets (收藏夹 - 商品列表)
├── OrderPage.ets (订单列表 - 状态筛选)
└── ConfirmOrderPage.ets (确认订单 - 地址选择+商品清单)
```

### 5.2 核心组件库（7个自定义组件）

| 组件名 | 文件路径 | 功能说明 | 使用场景 | 复用次数 |
|:---:|:---|:---|:---|:---:|
| **HomePage** | components/HomePage.ets | 首页主内容容器 | Index Tab 0 | 1 |
| **WomanPage** | components/WomanPage.ets | 女装分类展示 | Index Tab 子页面 | 1 |
| **ManPage** | components/ManPage.ets | 男装瀑布流展示 | Index Tab 子页面 | 1 |
| **SportPage** | components/SportPage.ets | 运动品类网格展示 | Index Tab 子页面 | 1 |
| **ComputerPage** | components/ComputerPage.ets | 数码产品网格展示 | Index Tab 子页面 | 1 |
| **HomeProductCardComponent** | components/HomeProductCardComponent.ets | 商品卡片（封面+标题+价格） | 首页/分类/搜索 | 10+ |
| **CardDetailPage** | components/CardDetailPage.ets | 商品详情（轮播+规格+加购按钮） | 商品点击后 | 多处 |

### 5.3 数据模型层（8种类型）

```typescript
// viewmodel/DataModels.ets

export class CardInfo {
  id: number = 0
  cardId: string = ''
  name: string = ''
  image: string = ''
  price: number = 0
  desc: string = ''
  proper: string = ''
  size: string = ''
  numb: number = 0
}

export class ProperColorData {
  id: number = 0
  cardId: string = ''
  name: string = ''
  image: string = ''
}

export class UserInfo {
  avatar: string = ''
  username: string = ''
  email: string = ''
}

export class ChatSession {
  id: number = 0
  sellerId: number = 0
  sellerName: string = ''
  lastMessage: string = ''
  unreadCount: number = 0
  timestamp: number = 0
}

// ... 更多模型定义
```

**前后端数据映射关系**:

| 前端模型 | 后端实体 | 映射字段 | 转换逻辑 |
|:---:|:---:|:---:|:---|
| CardInfo | Goods | cardId/name/image/price | 直接映射 |
| UserInfo | User | avatar/username/email | username ← nickname |
| CartItem | Cart + Goods | 联合查询结果 | Service层组装 |

### 5.4 路由配置与导航管理

#### 路由注册表 (main_pages.json)

```json
{
  "src": [
    "pages/Index",
    "pages/LoginPage",
    "pages/RegisterPage",
    "pages/components/CardDetailPage",
    "pages/SearchPage",
    "pages/SearchResultPage",
    "pages/ChatPage",
    "pages/EditProfilePage",
    "pages/MessageListPage",
    "pages/Category",
    "pages/Mine",
    "pages/Shop",
    "pages/AddressPage",
    "pages/FavoritePage",
    "pages/OrderPage",
    "pages/ConfirmOrderPage"
  ]
}
```

#### 路由跳转规范

```typescript
import { router } from '@kit.ArkUI'

// ✅ 标准跳转方式（带参数）
async navigateToDetail(cardId: string): Promise<void> {
  try {
    await router.pushUrl({
      url: 'pages/components/CardDetailPage',
      params: {
        cardId: cardId
      }
    })
  } catch (err) {
    console.error('路由跳转失败:', JSON.stringify(err))
  }
}

// ✅ 返回上一页
async goBack(): Promise<void> {
  try {
    await router.back()
  } catch (err) {
    console.error('返回失败:', err)
  }
}

// ✅ 替换当前页面（用于登录成功后）
async replaceToMain(): Promise<void> {
  try {
    router.replaceUrl({
      url: 'pages/Index'
    })
  } catch (err) {
    console.error('页面替换失败:', err)
  }
}
```

#### 路由守卫（登录状态检查）

```typescript
// 在需要登录的页面aboutToAppear中检查
async aboutToAppear(): Promise<void> {
  const isLoggedIn: boolean = await HttpUtil.isLoggedIn()
  if (!isLoggedIn) {
    // 未登录，提示并跳转到登录页
    promptAction.showToast({ message: '请先登录' })
    router.pushUrl({ url: 'pages/LoginPage' })
  } else {
    // 已登录，加载页面数据
    this.loadData()
  }
}
```

### 5.5 状态管理最佳实践

#### 5.5.1 @State 装饰器使用场景

```typescript
@ComponentV2
struct ShopPage {
  @State cartItems: CartItem[] = []  // 购物车列表
  @State isLoading: boolean = true   // 加载状态
  @State totalCount: number = 0      // 已选数量
  @State totalAmount: number = 0     // 总金额
  
  async aboutToAppear(): Promise<void> {
    this.isLoading = true
    const result = await HttpUtil.get<CartResponse>('/api/cart/list')
    if (result.code === 0) {
      this.cartItems = result.data.list
      this.totalCount = result.data.totalCount
      this.totalAmount = result.data.totalAmount
    }
    this.isLoading = false
  }
}
```

#### 5.5.2 @Prop 父子组件传参

```typescript
// 父组件
Column() {
  ForEach(this.cartItems, (item: CartItem) => {
    CartItemComponent({
      cartItem: item,           // @Prop 单向传递
      onQuantityChange: (qty: number) => {  // 回调函数
        this.updateQuantity(item.id, qty)
      }
    })
  }, (item: CartItem) => item.id.toString())
}

// 子组件
@ComponentV2
struct CartItemComponent {
  @Prop cartItem: CartItem = new CartItem()
  private onQuantityChange?: (quantity: number) => void
  
  build() {
    Row() {
      Text(this.cartItem.goodsName)
      Text(`¥${this.cartItem.price}`)
      
      Button('-')
        .onClick(() => {
          if (this.cartItem.quantity > 1) {
            this.onQuantityChange?.(this.cartItem.quantity - 1)
          }
        })
      
      Text(`${this.cartItem.quantity}`)
      
      Button('+')
        .onClick(() => {
          this.onQuantityChange?.(this.cartItem.quantity + 1)
        })
    }
  }
}
```

### 5.6 网络请求封装（HttpUtil）

#### 核心实现

```typescript
// utils/HttpUtil.ets
import { http } from '@kit.BasicServicesKit'
import { preferences } from '@kit.ArkData'

const BASE_URL: string = 'http://10.219.33.52:8080'
const TOKEN_KEY: string = 'jwt_token'

export class HttpUtil {
  private static instance: HttpUtil | null = null
  private pref: preferences.Preferences | null = null
  
  static async getInstance(): Promise<HttpUtil> {
    if (!HttpUtil.instance) {
      HttpUtil.instance = new HttpUtil()
      await HttpUtil.instance.initPreferences()
    }
    return HttpUtil.instance
  }
  
  private async initPreferences(): Promise<void> {
    this.pref = await preferences.getPreferences(getContext(), 'mystore')
  }
  
  async getToken(): Promise<string> {
    if (!this.pref) return ''
    return this.pref.get(TOKEN_KEY, '') as string
  }
  
  async saveToken(token: string): Promise<void> {
    if (!this.pref) return
    await this.pref.put(TOKEN_KEY, token)
    await this.pref.flush()
  }
  
  async clearToken(): Promise<void> {
    if (!this.pref) return
    await this.pref.delete(TOKEN_KEY)
    await this.pref.flush()
  }
  
  async isLoggedIn(): Promise<boolean> {
    const token: string = await this.getToken()
    return token.length > 0
  }
  
  async get<T>(url: string, params?: Record<string, string>): Promise<ApiResponse<T>> {
    return this.request<T>('GET', url, undefined, params)
  }
  
  async post<T>(url: string, body?: object): Promise<ApiResponse<T>> {
    return this.request<T>('POST', url, body)
  }
  
  async put<T>(url: string, body?: object): Promise<ApiResponse<T>> {
    return this.request<T>('PUT', url, body)
  }
  
  async delete<T>(url: string, params?: Record<string, string>): Promise<ApiResponse<T>> {
    return this.request<T>('DELETE', url, undefined, params)
  }
  
  private async request<T>(
    method: string,
    url: string,
    body?: object,
    params?: Record<string, string>
  ): Promise<ApiResponse<T>> {
    const httpRequest = http.createHttp()
    
    try {
      let fullUrl: string = `${BASE_URL}${url}`
      if (params && Object.keys(params).length > 0) {
        const queryString: string = Object.entries(params)
          .map(([key, value]) => `${encodeURIComponent(key)}=${encodeURIComponent(value)}`)
          .join('&')
        fullUrl += `?${queryString}`
      }
      
      const token: string = await this.getToken()
      const headers: Record<string, string> = {
        'Content-Type': 'application/json'
      }
      if (token) {
        headers['Authorization'] = `Bearer ${token}`
      }
      
      const response: http.HttpResponse = await httpRequest.request(fullUrl, {
        method: method as http.RequestMethod,
        header: headers,
        extraData: body ? JSON.stringify(body) : undefined
      })
      
      if (response.responseCode === 200) {
        return JSON.parse(response.result.toString()) as ApiResponse<T>
      } else if (response.responseCode === 401) {
        await this.clearToken()
        promptAction.showToast({ message: '登录已过期，请重新登录' })
        router.pushUrl({ url: 'pages/LoginPage' })
        throw new Error('Unauthorized')
      } else {
        throw new Error(`HTTP ${response.responseCode}: ${response.result}`)
      }
    } finally {
      httpRequest.destroy()
    }
  }
}

interface ApiResponse<T> {
  code: number
  msg: string
  data: T
}
```

#### 使用示例

```typescript
// 登录
async handleLogin(): Promise<void> {
  const result: ApiResponse<LoginResponse> = await HttpUtil.post('/api/user/login', {
    phone: this.phone,
    password: this.password
  })
  
  if (result.code === 0) {
    await HttpUtil.saveToken(result.data.token)
    promptAction.showToast({ message: '登录成功' })
    router.back()
  } else {
    promptAction.showToast({ message: result.msg })
  }
}

// 获取购物车
async loadCartData(): Promise<void> {
  this.isLoading = true
  try {
    const result: ApiResponse<CartResponse> = await HttpUtil.get('/api/cart/list')
    if (result.code === 0) {
      this.cartItems = result.data.list
      this.totalAmount = result.data.totalAmount
      this.totalCount = result.data.totalCount
    }
  } catch (error) {
    console.error('获取购物车失败:', error)
    promptAction.showToast({ message: '网络错误，请重试' })
  } finally {
    this.isLoading = false
  }
}
```

---

## 六、后端API开发规范

### 6.1 API接口总览（40+ 个接口）

#### 6.1.1 用户认证模块 (AuthController)

| 方法 | 路径 | 功能 | 参数 | 是否需要Token | 返回示例 |
|:---:|:---|:---|:---|:---:|:---|
| POST | `/api/user/login` | 用户登录 | `{phone, password}` | ❌ | `{token, userId}` |
| POST | `/api/user/register` | 用户注册 | `{phone, password, nickname?}` | ❌ | `{userId}` |
| GET | `/api/user/info` | 获取用户信息 | — | ✅ | `{avatar, username, email}` |
| PUT | `/api/user/profile` | 更新用户资料 | `{avatar?, username?, email?}` | ✅ | `{msg: "更新成功"}` |

#### 6.1.2 商品管理模块 (GoodsController)

| 方法 | 路径 | 功能 | 参数 | 是否需要Token | 备注 |
|:---:|:---|:---|:---|:---:|:---|
| GET | `/api/goods/list` | 商品列表(分页) | `page?, pageSize?, sortField?, sortOrder?, categoryId?` | ❌ | 支持排序/筛选 |
| GET | `/api/goods/detail/{id}` | 商品详情 | path: `id` | ❌ | 含规格信息 |
| GET | `/api/goods/search` | 搜索商品 | `keyword` | ❌ | 全文检索 |
| GET | `/api/goods/categories` | 分类列表 | — | ❌ | 18个一级分类 |
| GET | `/api/goods/recommended` | 推荐商品 | `limit?` | ❌ | 按销量排序 |

#### 6.1.3 购物车模块 (CartController)

| 方法 | 路径 | 功能 | 参数 | 是否需要Token | 业务规则 |
|:---:|:---|:---|:---|:---:|:---|
| GET | `/api/cart/list` | 购物车列表 | — | ✅ | 含Goods关联查询 |
| POST | `/api/cart/add` | 加入购物车 | `{goodsId, quantity, properColor?, properSize?}` | ✅ | 同规格累加数量 |
| PUT | `/api/cart/update` | 更新购物车项 | `{cartId, quantity?, checked?}` | ✅ | 支持数量/选中状态 |
| DELETE | `/api/cart/remove` | 删除购物车项 | query: `cartId` | ✅ | 级联删除 |

#### 6.1.4 订单管理模块 (OrderController) ✨新增

| 方法 | 路径 | 功能 | 参数 | 是否需要Token | 核心逻辑 |
|:---:|:---|:---|:---|:---:|:---|
| POST | `/api/order/create` | 购物车结算 | `{cartIds[], addressId, remark?}` | ✅ | 校验库存→扣减库存→清空购物车 |
| POST | `/api/order/direct` | 立即购买 | `{goodsId, quantity, properColor?, properSize?, addressId}` | ✅ | 单商品直接下单 |
| GET | `/api/order/list` | 订单列表 | `status? (-1=全部)` | ✅ | 按状态筛选，按时间倒序 |
| GET | `/api/order/detail/{orderId}` | 订单详情 | path: `orderId` | ✅ | 含订单明细列表 |
| PUT | `/api/order/status/{orderId}` | 更新状态 | `{status}` | ✅ | 状态流转校验 |
| DELETE | `/api/order/{orderId}` | 删除订单 | path: `orderId` | ✅ | 仅待付款/已取消可删 |
| PUT | `/api/order/updateAddress/{orderId}` | 更新地址 | `{addressId}` | ✅ | 仅待付款订单可改 |
| GET | `/api/order/count` | 订单统计 | — | ✅ | 各状态数量汇总 |

#### 6.1.5 地址管理模块 (AddressController) ✨新增

| 方法 | 路径 | 功能 | 参数 | 是否需要Token | 特殊逻辑 |
|:---:|:---|:---|:---|:---:|:---|
| GET | `/api/address/list` | 地址列表 | — | ✅ | 默认地址优先 |
| GET | `/api/address/default` | 默认地址 | — | ✅ | 返回唯一默认地址 |
| GET | `/api/address/{id}` | 地址详情 | path: `id` | ✅ | 归属权校验 |
| POST | `/api/address/add` | 新增地址 | `{receiverName, receiverPhone, province, city, district, detailAddress, postalCode?, isDefault?}` | ✅ | 设置默认时清除其他 |
| PUT | `/api/address/update` | 修改地址 | `{id, receiverName?, receiverPhone?, ..., isDefault?}` | ✅ | 同上 |
| DELETE | `/api/address/{id}` | 删除地址 | path: `id` | ✅ | 删除默认地址时自动设置新默认 |
| PUT | `/api/address/setDefault/{id}` | 设为默认 | path: `id` | ✅ | 清除原默认标记 |

#### 6.1.6 收藏管理模块 (FavoriteController) ✨新增

| 方法 | 路径 | 功能 | 参数 | 是否需要Token | 防重机制 |
|:---:|:---|:---|:---|:---:|:---|
| GET | `/api/favorite/list` | 收藏列表 | — | ✅ | 含商品信息 |
| POST | `/api/favorite/add/{goodsId}` | 添加收藏 | path: `goodsId` | ✅ | 检查是否已收藏 |
| DELETE | `/api/favorite/{goodsId}` | 取消收藏 | path: `goodsId` | ✅ | 检查是否存在 |
| GET | `/api/favorite/check/{goodsId}` | 检查收藏状态 | path: `goodsId` | ✅ | 返回boolean |
| POST | `/api/favorite/batchCheck` | 批量检查 | `{goodsIds[]}` | ✅ | 返回已收藏ID集合 |
| GET | `/api/favorite/count` | 收藏数量 | — | ✅ | 统计总数 |

### 6.2 统一响应格式规范

```java
// common/Result.java
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Result<T> {
    private int code;      // 状态码: 0成功，非0失败
    private String msg;    // 消息
    private T data;        // 数据载荷
    
    public static <T> Result<T> success(T data) {
        return new Result<>(0, "success", data);
    }
    
    public static <T> Result<T> success() {
        return new Result<>(0, "success", null);
    }
    
    public static <T> Result<T> error(String msg) {
        return new Result<>(-1, msg, null);
    }
    
    public static <T> Result<T> error(int code, String msg) {
        return new Result<>(code, msg, null);
    }
}
```

**响应示例**:

```json
// 成功响应
{
  "code": 0,
  "msg": "success",
  "data": {
    "list": [...],
    "totalCount": 2,
    "totalAmount": 258.00
  }
}

// 错误响应
{
  "code": -1,
  "msg": "用户名或密码错误",
  "data": null
}

// 未授权响应（401）
{
  "code": 401,
  "msg": "Token无效或已过期",
  "data": null
}
```

### 6.3 JWT认证机制详解

#### 6.3.1 Token生成与验证

```java
// common/JwtUtil.java
@Component
public class JwtUtil {
    
    @Value("${jwt.secret}")
    private String secret;
    
    @Value("${jwt.expiration}")
    private Long expiration;
    
    public String generateToken(Long userId, String phone) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + expiration);
        
        return Jwts.builder()
            .setSubject(String.valueOf(userId))
            .claim("phone", phone)
            .setIssuedAt(now)
            .setExpiration(expiryDate)
            .signWith(SignatureAlgorithm.HS256, secret)
            .compact();
    }
    
    public Claims parseToken(String token) {
        return Jwts.parser()
            .setSigningKey(secret)
            .parseClaimsJws(token)
            .getBody();
    }
    
    public Long getUserIdFromToken(String token) {
        Claims claims = parseToken(token);
        return Long.parseLong(claims.getSubject());
    }
    
    public boolean validateToken(String token) {
        try {
            parseToken(token);
            return true;
        } catch (ExpiredJwtException e) {
            log.warn("Token已过期");
            return false;
        } catch (Exception e) {
            log.warn("Token无效");
            return false;
        }
    }
}
```

#### 6.3.2 拦截器配置

```java
// config/JwtInterceptor.java
@Component
public class JwtInterceptor implements HandlerInterceptor {
    
    @Autowired
    private JwtUtil jwtUtil;
    
    @Override
    public boolean preHandle(HttpServletRequest request, 
                             HttpServletResponse response, 
                             Object handler) throws Exception {
        
        // 放行OPTIONS预检请求
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }
        
        String token = request.getHeader("Authorization");
        if (token != null && token.startsWith("Bearer ")) {
            token = token.substring(7);  // 去掉"Bearer "前缀
            
            if (jwtUtil.validateToken(token)) {
                Long userId = jwtUtil.getUserIdFromToken(token);
                request.setAttribute("currentUserId", userId);
                return true;
            }
        }
        
        response.setStatus(401);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(
            "{\"code\":401,\"msg\":\"未授权，请先登录\",\"data\":null}"
        );
        return false;
    }
}

// config/WebConfig.java
@Configuration
public class WebConfig implements WebMvcConfigurer {
    
    @Autowired
    private JwtInterceptor jwtInterceptor;
    
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(jwtInterceptor)
            .addPathPatterns("/api/**")           // 拦截所有API
            .excludePathPatterns(                  // 排除公开接口
                "/api/user/login",
                "/api/user/register",
                "/api/goods/**"
            );
    }
    
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
            .allowedOrigins("*")
            .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
            .allowedHeaders("*")
            .allowCredentials(true)
            .maxAge(3600);
    }
}
```

### 6.4 全局异常处理

```java
// common/GlobalExceptionHandler.java
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {
    
    @ExceptionHandler(Exception.class)
    public Result<?> handleException(Exception e) {
        log.error("服务器异常:", e);
        return Result.error("服务器内部错误，请稍后重试");
    }
    
    @ExceptionHandler(BusinessException.class)
    public Result<?> handleBusinessException(BusinessException e) {
        log.warn("业务异常: {}", e.getMessage());
        return Result.error(e.getCode(), e.getMessage());
    }
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public Result<?> handleValidationException(MethodArgumentNotValidException e) {
        String message = e.getBindingResult().getFieldErrors().stream()
            .map(FieldError::getDefaultMessage)
            .collect(Collectors.joining(", "));
        return Result.error(400, "参数校验失败: " + message);
    }
    
    @ExceptionHandler(AccessDeniedException.class)
    public Result<?> handleAccessDeniedException(AccessDeniedException e) {
        return Result.error(403, "无权限访问");
    }
}
```

### 6.5 Service层业务逻辑示例

#### 6.5.1 订单创建核心流程（OrderService.createOrderFromCart）

```java
@Transactional(rollbackFor = Exception.class)
public OrderInfo createOrderFromCart(Long userId, List<Long> cartIds, 
                                      Long addressId, String remark) {
    // 1. 校验收货地址
    Address address = addressService.getAddressById(addressId);
    if (!address.getUserId().equals(userId)) {
        throw new BusinessException("收货地址不存在");
    }
    
    // 2. 查询选中的购物车商品
    List<Cart> cartItems = cartMapper.selectBatchIds(cartIds)
        .stream()
        .filter(cart -> cart.getUserId().equals(userId))
        .collect(Collectors.toList());
    
    if (CollectionUtils.isEmpty(cartItems)) {
        throw new BusinessException("购物车商品不存在");
    }
    
    // 3. 批量获取商品信息（避免N+1查询问题）
    List<Long> goodsIds = cartItems.stream()
        .map(Cart::getGoodsId)
        .distinct()
        .collect(Collectors.toList());
    
    Map<Long, Goods> goodsMap = goodsMapper.selectBatchIds(goodsIds)
        .stream()
        .collect(Collectors.toMap(Goods::getId, Function.identity()));
    
    // 4. 校验库存并计算总金额
    BigDecimal totalAmount = BigDecimal.ZERO;
    List<OrderItem> orderItems = new ArrayList<>();
    
    for (Cart cart : cartItems) {
        Goods goods = goodsMap.get(cart.getGoodsId());
        if (goods == null || goods.getStatus() != 1) {
            throw new BusinessException("商品[" + goods.getName() + "]已下架");
        }
        if (goods.getStock() < cart.getQuantity()) {
            throw new BusinessException("商品[" + goods.getName() + "]库存不足");
        }
        
        BigDecimal itemTotal = goods.getPrice()
            .multiply(new BigDecimal(cart.getQuantity()));
        totalAmount = totalAmount.add(itemTotal);
        
        // 创建订单明细（快照商品信息）
        OrderItem orderItem = new OrderItem();
        orderItem.setGoodsId(goods.getId());
        orderItem.setGoodsName(goods.getName());
        orderItem.setGoodsImage(goods.getCover());
        orderItem.setGoodsPrice(goods.getPrice());
        orderItem.setQuantity(cart.getQuantity());
        orderItem.setProperColor(cart.getSelectedProperColor());
        orderItem.setProperSize(cart.getSelectedProperSize());
        orderItems.add(orderItem);
        
        // 扣减库存
        goods.setStock(goods.getStock() - cart.getQuantity());
        goods.setSoldCount(goods.getSoldCount() + cart.getQuantity());
        goodsMapper.updateById(goods);
    }
    
    // 5. 创建订单主记录
    OrderInfo order = new OrderInfo();
    order.setOrderNo(generateOrderNo());  // VIP + 时间戳 + 随机数
    order.setUserId(userId);
    order.setAddressId(addressId);
    order.setTotalAmount(totalAmount);
    order.setStatus(0);  // 待付款
    order.setRemark(remark);
    orderMapper.insert(order);
    
    // 6. 批量插入订单明细
    for (OrderItem item : orderItems) {
        item.setOrderId(order.getId());
        orderItemMapper.insert(item);
    }
    
    // 7. 清空已结算的购物车商品
    cartMapper.deleteBatchIds(cartIds);
    
    return order;
}

private String generateOrderNo() {
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
    String timestamp = sdf.format(new Date());
    int random = ThreadLocalRandom.current().nextInt(1000, 9999);
    return "VIP" + timestamp + random;
}
```

#### 6.5.2 购物车关联查询优化（CartService.getCartList）

```java
public List<Cart> getCartList(Long userId) {
    // 1. 查询用户的购物车记录
    QueryWrapper<Cart> wrapper = new QueryWrapper<>();
    wrapper.eq("user_id", userId)
           .orderByDesc("create_time");
    List<Cart> cartList = cartMapper.selectList(wrapper);
    
    if (CollectionUtils.isEmpty(cartList)) {
        return Collections.emptyList();
    }
    
    // 2. 批量获取商品信息（关键优化：解决N+1查询问题）
    List<Long> goodsIds = cartList.stream()
        .map(Cart::getGoodsId)
        .distinct()
        .collect(Collectors.toList());
    
    Map<Long, Goods> goodsMap = goodsMapper.selectBatchIds(goodsIds)
        .stream()
        .collect(Collectors.toMap(Goods::getId, Function.identity()));
    
    // 3. 将Goods对象注入到每个Cart对象中
    for (Cart cart : cartList) {
        cart.setGoods(goodsMap.get(cart.getGoodsId()));
    }
    
    return cartList;
}

public CartSummary getCartSummary(List<Cart> cartList) {
    int totalCount = 0;
    BigDecimal totalAmount = BigDecimal.ZERO;
    
    for (Cart cart : cartList) {
        if (cart.getChecked() == 1 && cart.getGoods() != null) {
            totalCount += cart.getQuantity();
            totalAmount = totalAmount.add(
                cart.getGoods().getPrice().multiply(new BigDecimal(cart.getQuantity()))
            );
        }
    }
    
    return new CartSummary(totalCount, totalAmount);
}
```

---

## 七、数据交互与业务流程

### 7.1 用户认证完整流程

```
[用户] 打开App
    │
    ▼
[Index.aboutToAppear()] 检查底部Tab
    │
    ├─► 点击"我的"Tab
    │   │
    │   ▼
    │   [Mine.aboutToAppear()]
    │   │
    │   ├─► HttpUtil.isLoggedIn()
    │   │   │
    │   │   ├─► 返回false（未登录）
    │   │   │   │
    │   │   │   ▼
    │   │   │   显示"点击登录"提示
    │   │   │   显示默认头像
    │   │   │
    │   │   └─► 返回true（已登录）
    │   │       │
    │   │       ▼
    │   │       [UserInfoService.getUserInfo()]
    │   │       显示真实头像/用户名/邮箱
    │   │
    │   └─► 点击头像区域
    │       │
    │       ▼
    │       router.pushUrl('pages/LoginPage') 或 EditProfilePage
    │
    └─► [LoginPage] 登录流程
        │
        ├─► 输入手机号 + 密码 + 勾选用户协议
        │   │
        │   ▼
        │   表单验证（手机号正则 + 密码长度 >= 6）
        │   │
        │   ▼
        │   [LoginPage.handleLogin()]
        │   │
        │   ▼
        │   HttpUtil.post('/api/user/login', {phone, password})
        │   │
        │   ▼
        │   [AuthController.login()]
        │   │
        │   ├─► UserService.login(phone, password)
        │   │   │
        │   │   ├─► 查询User表: SELECT * FROM user WHERE phone=? AND password=MD5(?)
        │   │   │
        │   │   ├─► 验证失败 → 抛出BusinessException("用户名或密码错误")
        │   │   │
        │   │   └─► 验证成功 → JwtUtil.generateToken(userId, phone)
        │   │       │
        │   │       ▼
        │   │       返回Result<{token: "eyJ...", userId: 1}>
        │   │
        │   ▼
        │   前端接收响应: code=0, data={token, userId}
        │   │
        │   ▼
        │   HttpUtil.saveToken(token) → 存入Preferences
        │   │
        │   ▼
        │   promptAction.showToast("登录成功")
        │   │
        │   ▼
        │   router.back() → 返回Mine页面
        │       │
        │       ▼
        │       [Mine.aboutToAppear()] 重新触发
        │       │
        │       ▼
        │       HttpUtil.isLoggedIn() → true
        │       │
        │       ▼
        │       显示真实用户信息 ✅
```

### 7.2 商品浏览与加购流程

```
[首页] Index.ets
    │
    ├─► 顶部Tab切换（推荐/女装/男装/运动/电脑办公/其他）
    │   │
    │   ▼
    │   加载对应的组件（HomePage/WomanPage/ManPage/SportPage/ComputerPage）
    │   │
    │   ├─► 当前使用MainViewModel提供的MockData（待v2.0对接API）
    │   │
    │   └─► 显示Banner轮播 + 分类网格 + 商品列表
    │
    ├─► 点击商品卡片
    │   │
    │   ▼
    │   router.pushUrl({url: 'pages/components/CardDetailPage', params: {cardId}})
    │   │
    │   ▼
    │   [CardDetailPage.aboutToAppear()]
    │   │
    │   ▼
    │   HttpUtil.get('/api/goods/detail/' + cardId)
    │   │
    │   ▼
    │   [GoodsController.detail(id)]
    │   │
    │   ▼
    │   GoodsService.getGoodsDetail(id)
    │   │
    │   ▼
    │   SELECT * FROM goods WHERE id=?  →  返回Goods对象
    │   │
    │   ▼
    │   渲染商品详情页:
    │   ├── 图片轮播（Swiper组件）
    │   ├── 商品名称 + 价格（原价划线显示）
    │   ├── 规格选择（颜色Radio + 尺码Picker）
    │   └── "加入购物车"按钮
    │
    └─► 点击"加入购物车"
        │
        ▼
        [CardDetailPage.handleAddToCart()]
        │
        ▼
        检查登录状态: HttpUtil.isLoggedIn()
        │
        ├─► 未登录 → promptAction.showToast("请先登录") → 跳转Login
        │
        └─► 已登录
            │
            ▼
            HttpUtil.post('/api/cart/add', {
              goodsId: this.goods.id,
              quantity: this.selectedQuantity,
              properColor: this.selectedColor,
              properSize: this.selectedSize
            })
            │
            ▼
            [CartController.add(body)]
            │
            ▼
            CartService.addToCart(userId, goodsId, quantity, color, size)
            │
            ├─► 查询是否已存在同规格购物车记录
            │   SELECT * FROM cart WHERE user_id=? AND goods_id=? 
            │                           AND proper_color=? AND proper_size=?
            │
            ├─► 已存在 → 更新数量: UPDATE cart SET quantity=quantity+? WHERE id=?
            │
            └─► 不存在 → 新增记录: INSERT INTO cart (...) VALUES (...)
            
            │
            ▼
            前端收到: {code: 0, msg: "加入购物车成功"}
            │
            ▼
            promptAction.showToast("✓ 已加入购物车")
```

### 7.3 购物车完整交互流程

```
[用户] 进入"购物车"Tab
    │
    ▼
    [Shop.ets aboutToAppear()]
    │
    ▼
    this.loadCartData()
    │
    ▼
    HttpUtil.get('/api/cart/list')
    Header: Authorization: Bearer eyJ...
    │
    ▼
    [CartController.list()]
    │
    ▼
    CartService.getCartList(userId)
    │
    ├─► Step 1: 查询购物车记录
    │   SELECT * FROM cart WHERE user_id=1 ORDER BY create_time DESC
    │   → 返回3条记录
    │
    ├─► Step 2: 批量查询商品（优化关键点！）
    │   SELECT * FROM goods WHERE id IN (1, 2, 3)
    │   → 返回3个Goods对象
    │
    └─► Step 3: 组装数据
        将Goods注入到Cart.cart字段
        
        │
        ▼
    返回CartResponse:
    {
      code: 0,
      data: {
        list: [
          {
            id: 1,
            goodsId: 1,
            quantity: 1,
            checked: 1,
            selectedProperColor: "黑色",
            selectedProperSize: "M",
            goods: {  // ← 关联的商品信息
              id: 1,
              name: "[2026新款]秋冬男士牛仔裤...",
              price: 134.00,
              cover: "man1.jpg",
              stock: 99
            }
          },
          // ...更多购物车项
        ],
        totalCount: 2,       // 已选商品种类数
        totalAmount: 258.00  // 已选商品总价 (134 + 124)
      }
    }
    
    │
    ▼
    [Shop.ets] 渲染购物车UI
    ├── ForEach遍历cartItems
    │   ├── Checkbox (checked状态绑定)
    │   ├── 商品图片 + 名称 + 规格
    │   ├── 数量加减按钮 (+/-)
    │   └── 单价小计显示
    ├── 全选Checkbox (控制所有项checked状态)
    └── 底部结算栏
        ├── "合计: ¥258.00"
        ├── "去结算(2)" 按钮
        └── 空状态展示（当list为空时）
        
    │
    ▼
    [用户操作]
    │
    ├─► 操作1: 勾选/取消勾选商品
    │   │
    │   ▼
    │   Checkbox.onChange事件触发
    │   │
    │   ▼
    │   HttpUtil.put('/api/cart/update', {cartId: 1, checked: 0})
    │   │
    │   ▼
    │   CartService.updateCartItem(userId, cartId, quantity, checked)
    │   │
    │   ▼
    │   UPDATE cart SET checked=? WHERE id=? AND user_id=?
    │   │
    │   ▼
    │   重新调用loadCartData() → 获取最新的totalCount和totalAmount
    │   │
    │   ▼
    │   UI实时更新 ✅
    │
    ├─► 操作2: 修改数量
    │   │
    │   ▼
    │   Button('+').onClick() 或 Button('-').onClick()
    │   │
    │   ▼
    │   校验数量边界（最小1，最大不超过stock）
    │   │
    │   ▼
    │   HttpUtil.put('/api/cart/update', {cartId: 1, quantity: 2})
    │   │
    │   ▼
    │   同上 → 重新loadCartData() → UI更新
    │
    ├─► 操作3: 删除商品
    │   │
    │   ▼
    │   AlertDialog确认对话框
    │   │
    │   ▼
    │   HttpUtil.delete('/api/cart/remove?cartId=1')
    │   │
    │   ▼
    │   CartService.removeCartItem(userId, cartId)
    │   │
    │   ▼
    │   DELETE FROM cart WHERE id=? AND user_id=?
    │   │
    │   ▼
    │   重新loadCartData() → 列表刷新
    │
    └─► 操作4: 点击"去结算"
        │
        ▼
        检查是否有选中商品 (totalCount > 0)
        │
        ├─► 无选中商品 → promptAction.showToast("请选择要结算的商品")
        │
        └─► 有选中商品
            │
            ▼
            router.pushUrl({url: 'pages/ConfirmOrderPage'})
            │
            ▼
            [ConfirmOrderPage]
            ├── 加载用户地址列表: GET /api/address/list
            ├── 显示已选商品清单（从购物车传来）
            ├── 选择/修改收货地址
            ├── 填写订单备注
            └── "提交订单"按钮
                │
                ▼
                POST /api/order/create
                {
                  cartIds: [1, 2],
                  addressId: 1,
                  remark: "尽快发货"
                }
                
                │
                ▼
                [OrderService.createOrderFromCart()] （见6.5.1节详细流程）
                │
                ▼
                订单创建成功 → 跳转到OrderPage查看订单
```




## 八、项目进度计划与风险管理

### 8.1 里程碑规划（Roadmap）

#### Phase 1: MVP基础版本 ✅ 已完成

**时间周期**: 2026-04-18 ~ 2026-04-20 (3天)  
**交付成果**:

| 任务ID | 任务名称 | 优先级 | 工作量 | 状态 | 交付物 |
|:---:|:---|:---:|:---:|:---:|:---|
| MVP-001 | 搭建HarmonyOS项目骨架 | P0 | 0.5天 | ✅ | 14个空页面 |
| MVP-002 | 实现Index主页Tab导航 | P0 | 0.5天 | ✅ | 5个Tab切换 |
| MVP-003 | 开发首页内容组件 | P0 | 1天 | ✅ | Banner+分类+商品列表 |
| MVP-004 | 实现商品详情页 | P0 | 0.5天 | ✅ | 图片轮播+规格选择 |
| MVP-005 | 搭建Spring Boot后端 | P0 | 0.5天 | ✅ | 项目脚手架 |
| MVP-006 | 实现用户认证API | P0 | 0.5天 | ✅ | 登录/注册/JWT |
| MVP-007 | 实现商品/购物车API | P0 | 1天 | ✅ | CRUD+关联查询 |
| MVP-008 | 前后端联调测试 | P0 | 0.5天 | ✅ | 购物车完全对接 |
| MVP-009 | Bug修复与优化 | P0 | 0.5天 | ✅ | 3个严重Bug修复 |

**技术债务**:
- 首页仍使用MockData（待Phase 2对接）
- 密码使用MD5（建议升级BCrypt）
- 无单元测试覆盖

---

#### Phase 2: 订单系统与数据对接 🔄 进行中

**时间周期**: 2026-05-13 ~ 2026-06-03 (3周)  
**目标**: 实现完整的电商交易闭环

##### Sprint 2.1: 订单核心功能 (Week 1)

| 任务ID | 任务名称 | 优先级 | 工作量 | 依赖 | 状态 | 验收标准 |
|:---:|:---|:---:|:---:|:---:|:---:|:---:|
| ORD-001 | 数据库新增订单相关表 | P0 | 0.5天 | - | ✅ | order_info + order_item |
| ORD-002 | 实现OrderService核心逻辑 | P0 | 2天 | ORD-001 | ✅ | 创建/查询/状态流转 |
| ORD-003 | 开发OrderController API | P0 | 1天 | ORD-002 | ✅ | 8个RESTful接口 |
| ORD-004 | 实现地址管理模块 | P0 | 1天 | - | ✅ | Address CRUD + 默认地址 |
| ORD-005 | 开发前端订单列表页 | P0 | 1天 | ORD-003 | 🔄 | 5种状态筛选展示 |
| ORD-006 | 开发前端确认订单页 | P0 | 1.5天 | ORD-004 | ⏳ | 地址选择+商品清单 |
| ORD-007 | 实现购物车结算流程 | P0 | 1天 | ORD-005,006 | ⏳ | 购物车→确认订单→提交 |
| ORD-008 | 订单状态实时更新 | P1 | 0.5天 | ORD-007 | ⏳ | 下拉刷新+状态变更提示 |

##### Sprint 2.2: 收藏与个人中心增强 (Week 2)

| 任务ID | 任务名称 | 优先级 | 工作量 | 依赖 | 状态 | 验收标准 |
|:---:|:---|:---:|:---:|---:|---:|:---:|
| FAV-001 | 数据库新增收藏表 | P1 | 0.5天 | - | ✅ | favorite表+初始数据 |
| FAV-002 | 实现FavoriteService | P1 | 1天 | FAV-001 | ✅ | 添加/删除/查询/批量检查 |
| FAV-003 | 开发FavoriteController | P1 | 0.5天 | FAV-002 | ✅ | 6个RESTful接口 |
| FAV-004 | 开发前端收藏夹页面 | P1 | 1天 | FAV-003 | ⏳ | 商品列表+取消收藏 |
| FAV-005 | 商品详情页集成收藏按钮 | P1 | 0.5天 | FAV-004 | ⏳ | 心形图标+状态切换 |
| FAV-006 | 个人中心订单入口优化 | P1 | 1天 | ORD-005 | ⏳ | 4种状态角标数字 |
| FAV-007 | 订单详情页开发 | P1 | 1天 | ORD-006 | ⏳ | 明细列表+物流跟踪占位 |

##### Sprint 2.3: 首页数据对接与优化 (Week 3)

| 任务ID | 任务名称 | 优先级 | 工作量 | 依赖 | 状态 | 验收标准 |
|:---:|:---|:---:|:---:|---:|:---:|:---:|
| API-001 | 后端新增首页数据聚合接口 | P1 | 1天 | - | ⏳ | Banner/推荐/特卖 |
| API-002 | HomePage组件重构为API调用 | P1 | 1.5天 | API-001 | ⏳ | 替换MockData |
| API-003 | 分类页商品列表API对接 | P1 | 1天 | API-001 | ⏳ | 动态加载分类商品 |
| API-004 | 搜索功能API完全对接 | P1 | 0.5天 | - | ⏳ | 热门搜索+历史记录同步 |
| OPT-001 | 性能优化：图片懒加载 | P2 | 1天 | - | ⏳ | 首屏速度提升30% |
| OPT-002 | 用户体验优化：骨架屏 | P2 | 1天 | - | ⏳ | 替代Loading动画 |
| OPT-003 | Bug修复与稳定性测试 | P0 | 1天 | 全部 | ⏳ | 无P0/P1级别Bug |

**Phase 2 交付物**:
- ✅ 完整的订单系统（创建/支付/发货/收货/完成/取消）
- ✅ 地址管理（CRUD + 默认地址机制）
- ✅ 收藏夹功能（添加/删除/批量状态检查）
- ✅ 首页/分类/搜索完全对接后端API
- ✅ 性能优化（图片懒加载/骨架屏/缓存策略）

---

#### Phase 3: 支付集成与高级功能 🔮 计划中

**预计时间**: 2026-06 ~ 2026-07 (4周)  
**前置条件**: Phase 2全部完成并通过UAT测试

##### Sprint 3.1: 支付系统集成 (Week 1-2)

| 任务ID | 任务名称 | 优先级 | 工作量 | 技术方案 |
|:---:|:---|:---:|:---|:---|
| PAY-001 | 对接微信支付SDK | P0 | 3天 | 微信支付Native/H5 API |
| PAY-002 | 对接支付宝SDK | P0 | 3天 | 支付宝手机网站支付 |
| PAY-003 | 实现支付回调处理 | P0 | 2天 | 异步通知+签名验证 |
| PAY-004 | 开发支付结果页 | P0 | 1天 | 成功/失败/跳转商家 |
| PAY-005 | 退款功能实现 | P1 | 2天 | 全额退款/部分退款 |

##### Sprint 3.2: AI智能客服 (Week 3)

| 任务ID | 任务名称 | 优先级 | 工作量 | 技术方案 |
|:---:|:---|:---:|:---:|---|
| AI-001 | 集成Ollama大模型 | P2 | 3天 | 本地部署Qwen/Llama3 |
| AI-002 | RAG知识库构建 | P2 | 2天 | 商品FAQ+订单政策 |
| AI-003 | 智能客服对话界面 | P2 | 2天 | 流式输出+上下文记忆 |
| AI-004 | 意图识别与工单转接 | P3 | 2天 | 人工客服接入 |

##### Sprint 3.3: 消息推送与通知 (Week 4)

| 任务ID | 任务名称 | 优先级 | 工作量 | 技术方案 |
|:---:|:---|:---:|:---::---|
| MSG-001 | 华为Push Kit集成 | P2 | 2天 | HMS Core Push |
| MSG-002 | 订单状态变更通知 | P1 | 1天 | 待发货/待收货提醒 |
| MSG-003 | 营销消息推送 | P3 | 1天 | 优惠活动/新品上架 |
| MSG-004 | 站内信中心优化 | P2 | 1天 | 已读/未读/批量操作 |

---

## 附录

### A. 项目文件路径索引

| 类别 | 路径 | 说明 |
|:---:|:---|:---|
| **前端项目根目录** | `c:\Users\TT\Desktop\weipinhui2\` | HarmonyOS工程 |
| **前端入口文件** | `entry/src/main/ets/pages/Index.ets` | 主页面 |
| **前端工具类** | `entry/src/main/ets/utils/HttpUtil.ets` | HTTP封装 |
| **前端数据模型** | `entry/src/main/ets/viewmodel/DataModels.ets` | 8种类型 |
| **前端常量定义** | `entry/src/main/ets/constants/CommonConstants.ets` | 通用常量 |
| **前端路由配置** | `entry/src/main/resources/base/profile/main_pages.json` | 20个路由 |
| **前端构建配置** | `entry/build-profile.json5` | SDK版本等 |
| **前端项目大纲** | `entry/PROJECT_OVERVIEW.md` | 本文档 |
| **后端项目根目录** | `D:\Downloads\vip-server\` | Spring Boot工程 |
| **后端启动类** | `src/main/java/com/example/vipserver/VipServerApplication.java` | Main方法 |
| **后端配置文件** | `src/main/resources/application.yml` | 数据库/JWT等 |
| **后端依赖管理** | `pom.xml` | Maven依赖 |
| **数据库脚本** | `sql/wph.sql` | 8张表+初始数据 |

### B. 测试账号信息

| 角色 | 手机号 | 密码 | 权限 | 用途 |
|:---:|:---:|:---:|:---:|:---|
| 测试用户 | 13800138000 | 123456 | 普通用户 | 功能测试 |

**注意事项**:
- 密码为明文`123456`的MD5值: `e10adc3949ba59abbe56e057f20f883e`
- 该账号已有3条购物车数据、2个地址、4个不同状态的订单、3个收藏商品


*📧 联系方式: [项目组邮箱/钉钉群]*  
*🌐 项目仓库: [GitLab/GitHub地址]*  
*📱 最后更新: 2026-05-27 by AI Technical Writer*
