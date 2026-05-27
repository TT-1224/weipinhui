# 电商购物APP (VIP Shop) — HarmonyOS 电商应用

## 📌 项目概述

**项目名称**: 电商购物APP (VIP Shop)\
**技术栈**: HarmonyOS ArkTS + Spring Boot + MySQL\
**项目路径**: `c:\Users\TT\Desktop\weipinhui2` (前端) / `D:\Downloads\vip-server` (后端)\
**当前版本**: v1.3 (2026-05-18 更新)

> 模仿电商购物APP的移动端应用，包含商品浏览、购物车、订单支付、搜索、分类、AI智能客服、聊天等完整电商功能模块。

***

## 🏗️ 项目架构

### 整体架构图

```
┌─────────────────────────────────────────────────────┐
│                   用户层 (HarmonyOS App)                │
│                                                      │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌─────────┐ │
│  │ 首页Index │ │ 分类Category│ │ 搜索Search│ │ 个人Mine│ │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬────┘ │
│       │            │            │            │       │
│  ┌────▼────────────▼────────────▼────────────▼───┐ │
│  │           商品详情 CardDetailPage               │ │
│  └────────────────────┬──────────────────────────┘ │
│                       │                               │
│  ┌────────────────────▼──────────────────────────┐ │
│  │              购物车 Shop                        │ │
│  └────────────────────┬──────────────────────────┘ │
│                       │                               │
│  ┌────────────────────▼──────────────────────┐    │
│  │        确认订单 ConfirmOrderPage            │    │
│  │        (虚拟支付: 微信/支付宝)              │    │
│  └────────────────────┬───────────────────────┘    │
│                       │                            │
│  ┌────────────────────▼───────────────────────┐   │
│  │             订单页 OrderPage                 │   │
│  │  待付款 | 待发货 | 待收货 | 待评价          │   │
│  └────────────────────────────────────────────┘   │
│                       │                            │
│  ┌────────────────────▼───────────────────────┐   │
│  │         AI智能客服 ChatPage                  │   │
│  │     (百度千帆API + 本地回退库)              │   │
│  └────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────┘
                          ↕ HTTP API
┌──────────────────────────────────────────────────┐
│                  后端服务 (Spring Boot)              │
│                                                    │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐     │
│  │UserController│ │GoodsController│ │OrderController│    │
│  └─────┬──────┘ └─────┬──────┘ └─────┬──────┘     │
│        │              │              │              │
│  ┌─────▼──────────────▼──────────────▼─────────┐  │
│  │         Service 层                          │  │
│  │  UserService │ GoodsService │ OrderService │  │
│  │  CartService(尺码区分) │ CategoryService   │  │
│  └────────────────────┬─────────────────────────┘  │
│                       │                           │
│  ┌────────────────────▼─────────────────────────┐  │
│  │         Mapper 层 (MyBatis-Plus)             │  │
│  └────────────────────┬─────────────────────────┘  │
│                       │                           │
│  ┌────────────────────▼─────────────────────────┐  │
│  │              MySQL 数据库                      │  │
│  │  user / goods / cart(4字段唯一键) / order_   │  │
│  │  info / order_item / category                │  │
│  └───────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────┘
```

***

## 📂 文件结构

### 前端 (HarmonyOS ArkTS) - 46个源文件

```
entry/src/main/
├── ets/
│   ├── pages/                          # 页面组件 (18个)
│   │   ├── Index.ets                  # 首页 (Banner + 秒杀 + 推荐 + 发现) [粉色主题]
│   │   ├── LoginPage.ets             # 登录页 → 登录成功跳转首页
│   │   ├── RegisterPage.ets          # 注册页 (手机号+密码+协议)
│   │   ├── SearchPage.ets            # 搜索入口 (历史持久化+热搜+猜你想搜)
│   │   ├── SearchResultPage.ets       # 搜索结果 (4种排序+商品卡片)
│   │   ├── Category.ets              # 分类页 (左右双向联动滚动)
│   │   ├── ChatPage.ets              # AI智能客服对话 (千帆API+本地回退)
│   │   ├── Mine.ets                  # 个人中心 (头像/订单入口/功能列表)
│   │   ├── EditProfilePage.ets       # 编辑资料 (昵称/头像/性别/签名)
│   │   ├── MessageListPage.ets       # 消息列表
│   │   ├── Shop.ets                  # 购物车 (全选/删除/结算→确认订单) [尺码区分]
│   │   ├── OrderPage.ets             # 订单页 (5个Tab + 评价弹窗)
│   │   ├── ConfirmOrderPage.ets      # 确认订单 (自动创建+虚拟支付)
│   │   ├── TabsExcample.ets          # 标签页示例
│   │   └── demo/
│   │       ├── Demo01.ets           # 演示页面1
│   │       ├── Demo02.ets           # 演示页面2
│   │       └── Demo03.ets           # 演示页面3
│   │
│   ├── components/                     # 子组件 (7个)
│   │   ├── CardDetailPage.ets        # 商品详情 (规格选择/加购/立即购买) [图片映射修复]
│   │   ├── HomePage.ets             # 首页内容组件
│   │   ├── WomanPage.ets            # 女装页 [粉色Tab]
│   │   ├── ManPage.ets              # 男装页 [品牌展示+圆角卡片]
│   │   ├── SportPage.ets            # 运动页
│   │   ├── ComputerPage.ets         # 电脑办公页
│   │   └── HomeProductCardComponent.ets  # 商品卡片组件
│   │
│   ├── manager/                         # 全局状态管理器 (单例模式)
│   │   ├── CartManager.ets            # 购物车管理 (增删改查+订阅通知)
│   │   ├── UserManager.ets            # 用户管理 (登录/登出/AppStorage同步)
│   │   └── OrderManager.ets           # 订单管理 (创建/更新/删除/状态机)
│   │
│   ├── utils/                           # 工具类 (6个)
│   │   ├── HttpUtil.ets               # HTTP请求封装 (Token自动附加)
│   │   ├── AiService.ets              # ✨ AI智能客服 (百度千帆ERNIE+本地回退库)
│   │   ├── ImageUtil.ets              # 图片工具 (本地资源名→$r映射)
│   │   ├── ToastUtil.ets              # Toast提示工具
│   │   ├── StorageUtil.ets            # 存储工具
│   │   └── SearchStorage.ets          # 搜索历史持久化
│   │
│   ├── constants/
│   │   └── CommonConstants.ets        # 全局常量定义
│   │
│   ├── viewmodel/                       # 视图模型层 (3个)
│   │   ├── DataModels.ets             # 数据模型定义 (含brand字段)
│   │   ├── MainViewModel.ets          # 主视图模型
│   │   └── ItemData.ets              # 列表项数据类 (含brandName)
│   │
│   ├── datasource/                      # 数据服务层 (5个)
│   │   ├── MockData.ets               # Mock数据源 (11个商品+品牌+2026年份)
│   │   ├── UserInfoService.ets        # 用户信息服务
│   │   ├── DataUtils.ets              # 数据处理工具
│   │   ├── MockMessageService.ets     # 消息模拟服务
│   │   └── WaterFlowDataSource.ets    # 瀑布流数据源
│   │
│   ├── model/
│   │   └── User.ets                   # 用户模型
│   │
│   ├── entryability/
│   │   └── EntryAbility.ets           # 应用入口
│   │
│   └── entrybackupability/
│       └── EntryBackupAbility.ets     # 备份能力
│
└── resources/base/
    ├── media/                          # 图片资源 (man1~11, card, brand等)
    ├── element/
    │   ├── color.json                  # 颜色资源
    │   ├── float.json                  # 浮点数资源
    │   └── string.json                 # 字符串资源
    └── profile/
        └── main_pages.json             # 页面路由注册 (18+页面)
```

### 后端 (Spring Boot)

```
src/main/java/com/example/vipserver/
├── controller/
│   ├── UserController.java           # 用户接口 (登录/注册/信息/JWT认证)
│   ├── GoodsController.java          # 商品接口 (列表/详情/搜索/推荐/分类)
│   ├── CartController.java           # 购物车接口 (JWT用户隔离+尺码区分)
│   ├── OrderController.java          # 订单接口 (创建/列表/详情/状态/删除/统计)
│   └── AuthController.java           # Token验证接口
│
├── service/
│   ├── UserService.java              # 用户服务
│   ├── GoodsService.java             # 商品服务 (含模糊搜索+4种排序)
│   ├── CartService.java              # ✨ 购物车服务 (4字段唯一键: user_id+goods_id+color+size)
│   ├── OrderService.java             # 订单服务 (事务性创建)
│   └── CategoryService.java          # 分类服务
│
├── pojo/                             # 实体类
│   ├── User.java                     # 用户
│   ├── Goods.java                    # 商品 (含brand字段)
│   ├── Cart.java                     # 购物车 (含selected_proper_color/selected_proper_size)
│   ├── OrderInfo.java                # 订单
│   ├── OrderItem.java                # 订单明细
│   └── Category.java                 # 分类
│
├── mapper/                           # MyBatis-Plus Mapper
│   ├── UserMapper.java
│   ├── GoodsMapper.java
│   ├── CartMapper.java
│   ├── OrderMapper.java
│   ├── OrderItemMapper.java
│   └── CategoryMapper.java
│
├── common/
│   ├── Result.java                   # 统一响应格式
│   └── JwtUtil.java                  # JWT工具类 (生成/解析Token)
│
└── config/
    └── JwtInterceptor.java            # JWT拦截器 (校验Token提取userId)

sql/
├── wph.sql                           # 数据库初始化脚本 (7表+测试数据) [2026更新]
└── upgrade_cart_size_distinction.sql # ✨ 购物车尺码升级迁移脚本 (无损升级)
```

***

## 📱 页面清单 (18+已注册页面)

| 序号    | 页面路径                              | 功能描述                                | 最新更新            |
| ----- | --------------------------------- | ----------------------------------- | --------------- |
| 1     | `pages/Index`                     | 首页：轮播Banner、限时秒杀、推荐商品、发现频道          | 🎨 粉色主题UI       |
| 2     | `pages/LoginPage`                 | 登录：手机号+密码，登录后跳转首页                   | -               |
| 3     | `pages/RegisterPage`              | 注册：手机号+昵称+密码+确认密码+协议勾选              | -               |
| 4     | `pages/SearchPage`                | 搜索入口：历史记录(持久化)、猜你想搜、热搜榜单(8条)        | -               |
| 5     | `pages/SearchResultPage`          | 搜索结果：4种排序(综合/销量/价格)、商品卡片            | -               |
| 6     | `pages/Category`                  | 分类页：左侧导航18项 + 右侧内容 **双向联动滚动**       | -               |
| 7     | `pages/ChatPage`                  | ✨ **AI智能客服**：百度千帆ERNIE模型 + 本地9场景回退库 | 🤖 2026-05-18新增 |
| 8     | `pages/Mine`                      | 个人中心：头像/用户名/4个订单Tab入口/功能菜单          | -               |
| 9     | `pages/EditProfilePage`           | 编辑资料：修改昵称/头像/性别/个性签名                | -               |
| 10    | `pages/MessageListPage`           | 消息列表                                | -               |
| 11    | `pages/Shop`                      | 购物车：全选/增减数量/删除/结算→ConfirmOrderPage  | 🔧 尺码区分机制       |
| 12    | `pages/OrderPage`                 | 订单页：全部/待付款/待发货/待收货/**待评价**(5个Tab)   | -               |
| 13    | `pages/ConfirmOrderPage`          | 确认订单：进入即创建(status=0)+微信/支付宝虚拟支付     | -               |
| 14    | `pages/components/CardDetailPage` | 商品详情：图片/规格/价格/加入购物车/立即购买            | ✅ 图片映射修复        |
| 15-17 | `pages/demo/Demo01~03`            | 演示页面                                | -               |
| 18    | `pages/TabsExcample`              | 标签页示例                               | -               |

***

## 🔑 核心业务流程

### 1. 完整购物流程（含尺码区分）

```
首页/分类页
    ↓ 点击商品
CardDetailPage (商品详情) [✅ 11个商品图片正确映射]
    ├─ 选择颜色规格 (如: 黑色)
    ├─ 选择尺码规格 (如: M码)
    ├─ "加入购物车" → CartManager.addToCart(color, size)
    │   └─ 后端: INSERT INTO cart (user_id, goods_id, color='黑色', size='M')
    │   └─ ✅ 相同商品不同尺码 → 独立购物车条目（不合并）
    └─ "立即购买"  → 收集商品信息
                        ↓
              ConfirmOrderPage (确认订单)
              ├─ aboutToAppear → 自动创建订单(status=0 待付款)
              ├─ 选择支付方式: 微信支付 / 支付宝
              ├─ 点击"确认支付"
              │   ├─ 成功 → status=1(待发货) → 跳转"待发货"Tab
              │   └─ 失败/取消 → 保持status=0(待付款) → 跳转"待付款"Tab
              └─ 退出不支付 → 弹窗提示 → 订单保留在待付款中

购物车 Shop.ets [🔧 尺码独立显示]
    └─ 显示格式: "商品名称 [黑色 / M码] x2"
    └─ "结算" → 收集选中商品 → ConfirmOrderPage (同上流程)
```

### 2. 订单状态生命周期

```
创建订单 ──→ status=0 (待付款)
    │
    ├─ 确认支付成功 ──→ status=1 (待发货) ──→ [确认付款]可重新进入支付
    │                                    │
    │                              商家发货
    │                                    ↓
    │                                status=2 (待收货)
    │                                    │
    │                              [确认收货]
    │                                    ↓
    │                                status=3 (待评价)
    │                                    │
    │                              [去评价] → 弹窗(★评分+评论) → status=4
    │
    └─ 取消支付/取消订单 ──→ status=4 (已取消)
```

### 3. 用户系统

```
RegisterPage (注册)
    ↓ POST /api/user/register
LoginPage (登录)
    ↓ POST /api/user/login → 获取Token + 用户信息
    ↓ UserManager.login() → AppStorage全局同步
    ↓ router.replaceUrl({ url: 'pages/Index' })
    
所有需要身份的API:
    → HttpUtil 自动附加 Authorization: Bearer {token}
    → JwtInterceptor 校验Token → 提取真实 userId
    → 不同用户数据完全隔离 (订单/购物车/个人信息)
```

### 4. ✨ AI智能客服流程（2026-05-18新增）

```
用户打开 ChatPage (聊天页面)
    ↓ 输入消息 (如: "物流查询"、"退款政策")
    ↓
AiService.chat(userMessage, chatHistory)
    ↓
① 尝试调用百度千帆AI API (ERNIE-speed-128k模型)
   ├─ API: https://qianfan.baidubce.com/v2/chat/completions
   ├─ Header: Authorization: Bearer {API_KEY}
   └─ 超时设置: 连接15s / 读取30s
    ↓
├── ✅ API调用成功
│   └─ 返回AI智能回复 (专业客服语气 + emoji)
│
└── ❌ API调用失败 (网络错误/API密钥无效/超时)
    ↓
    ② 自动切换到本地回复库匹配
    ├─ 遍历9大场景规则 (LOCAL_REPLIES数组)
    ├─ 关键词模糊匹配 (如: "物流"匹配["物流","快递","发货"...])
    └─ 返回预设的专业回复:
       ├─ 📦 物流查询 (运单号查询方法)
       ├─ 🔄 退换货政策 (7天无理由)
       ├─ 🎫 优惠券使用指南
       ├─ ⭐ 会员权益说明
       ├─ 💳 支付与发票
       ├─ 👔 尺码选择建议 (XS-XL参考)
       ├─ 🧺 材质与洗涤指南
       ├─ 📋 库存与补货说明
       └─ 😊 问候与帮助引导
    ↓
    └── ❌ 未匹配到任何关键词
        └─ 返回: "AI服务暂时不可用，请稍后再试"
```

***

## 🎨 UI/UX 特性

### 设计规范 (v1.3更新)

| 特性       | 规范值                                       | 实现状态        |
| -------- | ----------------------------------------- | ----------- |
| **主题色**  | **#FF2D55 (粉色)**                          | ✅ 全面替代蓝色    |
| **辅助色**  | #8E8E93 (灰色文字) / #FF3B30 (红色警告)           | ✅ 已实现       |
| **圆角半径** | 14vp (卡片) / 8vp (按钮) / 40vp (圆形头像)        | ✅ 已实现       |
| **间距规范** | 10-16vp (常规) / 20vp (区块间)                 | ✅ 已实现       |
| **字体大小** | 12vp (小字) / 14vp (正文) / 16-18vp (标题)      | ✅ 已实现       |
| **阴影效果** | radius: 8, color: '#12000000', offsetY: 1 | ✅ ManPage卡片 |

### 核心UI特性

| 特性         | 实现方式                                                                  | 版本         |
| ---------- | --------------------------------------------------------------------- | ---------- |
| **粉色主题统一** | 自定义TopTabBuilder/CategoryTabBuilder + Text().fontColor('#FF2D55')     | 🎨 v1.3    |
| **自定义搜索栏** | Row + TextInput + Text(粉色搜索按钮) 替代原生Search组件                           | 🎨 v1.3    |
| **系统图标**   | SymbolGlyph 替代自定义 Image (chevron\_left/magnifyingglass/flame 等)       | v1.0       |
| **商品图片映射** | ImageUtil.getGoodsImage() + CardDetailPage.loadMockGoods() 11商品正确对应   | ✅ v1.3修复   |
| **品牌展示**   | ManPage卡片显示brand字段 + 所有商品含品牌名                                         | 🏷️ v1.3新增 |
| **双向联动**   | Category.ets 左右滚动联动 (点击导航→右侧定位 / 右侧滑动→左侧高亮)                           | v1.0       |
| **全局状态**   | CartManager/UserManager/OrderManager 单例 + subscribe/unsubscribe 观察者模式 | v1.0       |
| **实时刷新**   | 购物车/订单/用户信息跨页面实时同步 (@Watch + AppStorage)                              | v1.0       |
| **虚拟支付**   | 微信/支付宝选择 + 1.5s模拟动画 + Toast反馈                                         | v1.0       |
| **评价功能**   | bindSheet 半模态弹窗 (★★★★★ 评分 + TextArea 评论)                              | v1.0       |
| **搜索优化**   | 历史持久化(AppStorage) + 单条删除 + 4种排序 + 高级空状态                               | v1.0       |
| **布局对齐**   | Scroll align(Alignment.Top) 内容靠顶排列                                    | v1.0       |

***

## 🗄️ 数据库设计 (7张表)

### 核心表结构 (v1.3更新)

```sql
-- 用户表
user (id, phone, password, nickname, avatar, gender, signature, token, create_time, update_time)

-- 商品表 ✅ 新增brand字段
goods (id, card_id, name, sub_title, price, origin_price, cover, 
       proper_color, proper_size, stock, sold_count, category_id, 
       **brand VARCHAR(50)**,  -- ✅ 新增: 品牌名称
       status, create_time)

-- 购物车表 ✅ 唯一键改为4字段组合
cart (id, user_id, goods_id, quantity, 
      selected_proper_color,   -- ✅ 选中的颜色规格
      selected_proper_size,    -- ✅ 选中的尺码规格
      checked, create_time,
      **UNIQUE KEY uk_user_goods_spec (user_id, goods_id, selected_proper_color, selected_proper_size)**)
      -- ✅ 相同商品不同尺码 = 独立条目

-- 订单主表
order_info (id, order_no, user_id, total_amount, status, remark, create_time, update_time)
-- status: 0=待付款 / 1=待发货 / 2=待收货 / 3=待评价 / 4=已取消

-- 订单明细表
order_item (id, order_id, goods_id, goods_name, goods_image, goods_price,
            quantity, proper_color, proper_size)

-- 分类表
category (id, name, icon, sort_order)
```

## 🔧 技术要点

### 前端 (ArkTS)

- **@ComponentV2** + @Local/@Param 状态管理 (V2规范)
- **对象字面量类型安全**: 所有对象字面量必须对应显式声明的 interface (arkts-no-untyped-obj-literals)
- **SymbolGlyph**: 系统图标组件替代 Image 加载 sys.symbol 资源
- **bindSheet 半模态**: 用于评价弹窗、日期选择器等场景
- **$$this 双向绑定**: bindSheet 中使用（编辑器误报可忽略）
- **AppStorage**: 跨页面数据持久化 (搜索历史/用户状态)
- **观察者模式**: Manager单例 + subscribe/unsubscribe + notifyListeners
- **AI集成**: 百度千帆ERNIE API + 本地关键词匹配回退机制
- **网络权限**: module.json5 配置 ohos.permission.INTERNET

### 后端 (Spring Boot)

- **MyBatis-Plus**: LambdaQueryWrapper 链式查询
- **JWT认证**: JwtUtil生成/解析 + JwtInterceptor拦截器 + @RequestHeader获取Token
- **用户隔离**: 所有写操作接口从JWT提取真实userId (CartController/OrderController)
- **事务管理**: @Transactional 保证订单创建的原子性 (order + order\_items + 清购物车)
- **模糊搜索**: LIKE 匹配 name/subTitle + 多种排序策略
- **✨ 购物车尺码区分**: 4字段复合唯一键 (user\_id + goods\_id + color + size)
- **关联查询**: CartService批量查询Goods并注入到Cart对象（解决总价为0的Bug）

***

## 📋 开发规范遵循

1. **ArkTS类型安全**: 禁止 any/unknown/未声明类型的对象字面量
2. **状态管理隔离**: V1(@State/@Prop) vs V2(@Local/@Param) 不混用
3. **资源引用**: 使用 `$r('app.type.name')` 引用本地资源
4. **命名规范**:
   - 页面以 Page 结尾 (Index, LoginPage)
   - 组件以 Component 结尾
   - 常量大写 (PAGE\_PATH, CommonConstants)
5. **编译要求**: 每次代码修改后必须执行 `hvigorw assembleApp` 编译验证
6. **部署要求**: 编译成功后必须运行 `.\run.ps1` 或 `./run.sh` 部署测试

\--

```
#### **初始数据完整映射** (11个商品)

| ID | 前端图片 | 商品名称 | 品牌 | 默认尺码 | 价格 |
|:---:|:---:|:---|:---:|:---:|:---:|
| 1 | man1.jpg | 秋冬男士牛仔裤 | **优衣库** | M | ¥134 |
| 2 | man2.jpg | 秋冬男士卫衣 | **ZARA** | M | ¥124 |
| 3 | man3.jpg | 秋冬男士短袖 | **H&M** | M | ¥99 |
| 4 | man4.jpg | 秋冬男士短羽绒服 | **波司登** | NULL | ¥78 |
| 5 | man5.jpg | 秋冬轻薄羽绒服 | **鸭鸭** | NULL | ¥123 |
| 6 | man6.jpg | 秋冬厚羽绒服 | **加拿大鹅** | NULL | ¥453 |
| 7 | man7.jpg | 秋冬高端羽绒服 | **Moncler** | NULL | ¥765 |
| 8 | man8.jpg | 秋冬运动裤 | **李宁** | NULL | ¥66 |
| 9 | man9.jpg | 秋冬运动外套 | **安踏** | NULL | ¥88 |
| 10 | man10.jpg | 秋季T恤 | **耐克** | NULL | ¥73 |
| 11 | man11.jpg | 秋季运动鞋 | **阿迪达斯** | NULL | ¥90 |

---

### 5️⃣ 前后端接口对接验证

#### **购物车API调用链路**

```

前端 CardDetailPage.ets                    后端 CartController.java
─────────────────────                    ──────────────────────
用户点击"加入购物车"
↓
① 收集规格信息                              ↓ POST /api/cart/add
const params = {                         ↓
goodsId: this.goodsId,                 CartController.addToCart()
quantity: 1,                           ↓
properColor: '黑色',                   CartService.addToCart()
properSize: 'M'                        ↓
}                                        数据库INSERT/UPDATE
↓                                         ↓
② HttpUtil.post('/api/cart/add', params)    ✅ 返回成功
↓
③ Shop.ets loadCartData()
↓ GET /api/cart/list
↓ CartService.getCartList(userId)
↓ 批量查询Goods表（关联注入）
↓ 返回含规格的购物车列表
↓
④ 渲染购物车UI
"优衣库 牛仔裤 \[黑色 / M码] ×1  ¥134"

```

#### **数据一致性检查清单**

- [x] 前端CardInfo.brand ↔ 后端Goods.brand ↔ 数据库goods.brand
- [x] 前端CardInfo.size='M' ↔ 后端goods.proper_size='M' ↔ cart.selected_proper_size='M'
- [x] 前端CartManager.addToCart(color, size) ↔ 后端CartService.addToCart(properColor, properSize)
- [x] 数据库cart表4字段唯一键约束生效
- [x] 15个单元测试全部通过

---

## 🤖 AI智能客服系统详解 (v1.3新增)

### 架构设计

```

┌─────────────────────────────────────────┐
│           ChatPage (聊天界面)             │
│  ┌───────────────────────────────────┐  │
│  │     消息气泡列表 (用户/AI)        │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  输入框 + 发送按钮                 │  │
│  └─────────────┬─────────────────────┘  │
└────────────────┼────────────────────────┘
│ 调用
▼
┌─────────────────────────────────────────┐
│        AiService.ets (核心服务)           │
│                                         │
│  chat(userMessage, history)              │
│    ├─ ① try: 调用百度千帆API             │
│    │   └─ ERNIE-speed-128k 模型         │
│    │                                      │
│    └─ ② catch: 本地回退库                │
│        └─ getLocalReply(message)         │
│           └─ 9大场景关键词匹配            │
└─────────────────────────────────────────┘

````

### 本地回复库覆盖场景 (9大类)

| 场景 | 关键词示例 | 回复内容特点 |
|------|-----------|-------------|
| 📦 **物流查询** | 物流、快递、发货、配送 | 运单号查询方法 + 1-3天可查 |
| 🔄 **退换货** | 退货、退款、换货、售后 | 7天无理由 + 15天质量问题 |
| 🎫 **优惠券** | 优惠、红包、满减、折扣 | 领取方式 + 使用规则 |
| ⭐ **会员权益** | VIP、积分、等级、SVIP | 等级体系 + 主要权益 |
| 💳 **支付发票** | 支付、微信、支付宝、发票 | 支付方式 + 发票申请 |
| 👔 **尺码选择** | 尺码、尺寸、大小、怎么选 | XS-XL身高体重参考表 |
| 🧺 **材质洗涤** | 材质、面料、棉、清洗 | 常见材质 + 洗涤建议 |
| 📋 **库存补货** | 缺货、补货、预售 | 补货周期 + 到货通知 |
| 😊 **问候帮助** | 你好、在吗、客服、谢谢 | 功能引导 + 服务介绍 |

### 技术实现要点

```typescript
// AiService.ets 核心代码结构
interface LocalReplyRule {
  keywords: string[]   // 关键词数组
  response: string     // 回复内容
}

// ✅ ArkTS合规: 使用独立类型变量而非内联对象字面量
const replyLogistics: LocalReplyRule = {
  keywords: ['物流', '快递', '发货', '配送', '运输'],
  response: '关于订单物流查询📦\n\n...'
}

const LOCAL_REPLIES: LocalReplyRule[] = [
  replyLogistics, replyReturn, replyCoupon, ...
  // 共9个规则
]
````

***

## 📊 功能完成度总览 (v1.3)

### ✅ 已完成并可正常使用 (生产就绪)

| 模块            | 功能点                     | 实现状态 |  API对接 |   最后更新   |
| :------------ | :---------------------- | ---: | -----: | :------: |
| **🔐 用户认证**   | 登录/注册/JWT Token         | ✅ 完成 |  🟢 完整 |   v1.1   |
| **🏠 主页导航**   | 底部5 Tab + 顶部6 Tab + 搜索栏 | ✅ 完成 |      - |  🎨 v1.3 |
| <br />        | **粉色主题全面统一**            | ✅ 完成 |      - |  🎨 v1.3 |
| **📦 商品体系**   | 商品详情页 + 规格选择            | ✅ 完成 |  🟢 完整 |  ✅ v1.3  |
| <br />        | **11商品图片正确映射**          | ✅ 修复 |      - |  ✅ v1.3  |
| <br />        | **商品名称显示实际描述**          | ✅ 修复 |      - |  ✅ v1.3  |
| <br />        | **品牌名称展示**              | ✅ 新增 |      - | 🏷️ v1.3 |
| <br />        | **年份2026更新**            | ✅ 更新 |      - |  📅 v1.3 |
| **🛒 购物车**    | 后端API实时数据               | ✅ 完成 |  🟢 完整 |   v1.1   |
| <br />        | **尺码区分机制** (不同规格独立条目)   | ✅ 新增 |  🟢 完整 |  🔧 v1.3 |
| <br />        | 单选/全选/数量修改/删除           | ✅ 完成 |  🟢 完整 |   v1.1   |
| **🤖 AI智能客服** | 百度千帆ERNIE模型集成           | ✅ 完成 | 🤖 API |  🤖 v1.3 |
| <br />        | **本地9场景回退库**            | ✅ 完成 |      - |  🤖 v1.3 |
| <br />        | **网络权限配置**              | ✅ 配置 |      - |  🤖 v1.3 |
| **💬 消息系统**   | 消息列表 + 聊天详情             | ✅ 完成 |      - |   v1.0   |
| **👤 个人中心**   | 登录判断 + 信息编辑             | ✅ 完成 |  🟢 完整 |   v1.1   |
| **📋 订单系统**   | 创建/列表/状态/评价             | ✅ 完成 |  🟢 完整 |   v1.0   |
| **🔍 搜索系统**   | 历史/热搜/结果排序              | ✅ 完成 |  🟢 部分 |   v1.0   |

### 📈 项目统计

| 维度          |   数量  | 说明                          |
| :---------- | :---: | --------------------------- |
| **前端页面**    | 18+ 个 | 含3个Demo页面                   |
| **子组件**     |  7 个  | HomePage/WomanPage/ManPage等 |
| **工具类**     |  6 个  | 含AiService                  |
| **数据模型**    |  8+ 类 | 含brand/brandName字段          |
| **Mock数据集** |  6 组  | 11个商品+品牌信息                  |
| **后端接口**    | 18+ 个 | RESTful API                 |
| **数据库表**    |  7 张  | 含购物车4字段唯一键                  |
| **AI回复场景**  |  9 大类 | 覆盖主要客服需求                    |
| **商品品牌**    |  11 个 | 优衣库/ZARA/H\&M等              |
| **源代码文件**   |  46 个 | .ets文件总数                    |

***

## 🚀 快速启动指南

### 环境要求

- **前端**: DevEco Studio 4.0+ / HarmonyOS SDK API 12+
- **后端**: JDK 17+ / Maven 3.6+ / MySQL 8.0+
- **构建工具**: hvigor (HarmonyOS) / Maven (Spring Boot)

### 启动步骤

```bash
# 1. 后端启动
cd D:\Downloads\vip-server
mvn spring-boot:run
# 访问 http://localhost:8080 确认启动成功

# 2. 数据库初始化 (首次)
mysql -u root -p < sql/wph.sql
# 如需升级购物车表 (已有数据无损升级)
mysql -u root -p < sql/upgrade_cart_size_distinction.sql

# 3. 前端编译
cd c:\Users\TT\Desktop\weipinhui2
hvigorw assembleApp   # 必须执行！验证编译通过

# 4. 部署到模拟器/真机
.\run.ps1   # Windows
# 或
./run.sh    # macOS
```

### 测试账号

|  角色  | 手机号         | 密码     |  权限  |
| :--: | :---------- | :----- | :--: |
| 测试用户 | 13800138000 | 123456 | 普通用户 |

***

## ⚠️ 已知问题与解决方案

### 当前限制

| 限制              | 影响       | 改进方案          |
| :-------------- | :------- | ------------- |
| 首页数据仍使用MockData | 无法动态更新商品 | v2.0计划对接后端API |
| AI API密钥可能失效    | 仅使用本地回退库 | 更新有效密钥或切换模型   |
| 无真实图片CDN        | 显示本地占位符  | 配置图片服务器或CDN   |
| 密码明文MD5存储       | 安全性较低    | 生产环境改用BCrypt  |

### 后续完善

\- 首页数据完全对接后端API （目前部分使用MockData）

- 收货地址管理 （CRUD + 默认地址）
- 商品收藏功能 （收藏夹列表）
- 优惠券系统 （领取/使用/满减计算）
- 真实支付集成 （微信/支付宝SDK）
- 商品评价系统 （晒图 + 评分）
- 搜索功能增强 （ES全文检索）
- 消息推送WebSocket （实时通知订单状态）

***

## 📞 技术支持与联系方式

### 项目仓库

- **前端代码**: `c:\Users\TT\Desktop\weipinhui2\`
- **后端代码**: `D:\Downloads\vip-server\`
- **数据库脚本**: `D:\Downloads\vip-server\sql\wph.sql`
- **项目大纲**: `c:\Users\TT\Desktop\weipinhui2\PROJECT_OUTLINE.md` (本文档)

### 关键文件速查

| 用途           | 文件路径                                                     |
| :----------- | -------------------------------------------------------- |
| AI智能客服       | `entry/src/main/ets/utils/AiService.ets`                 |
| 商品详情页        | `entry/src/main/ets/pages/components/CardDetailPage.ets` |
| 购物车逻辑        | `entry/src/main/ets/pages/Shop.ets`                      |
| 主页粉色主题       | `entry/src/main/ets/pages/Index.ets`                     |
| 男装品牌展示       | `entry/src/main/ets/pages/components/ManPage.ets`        |
| Mock数据(11商品) | `entry/src/main/ets/datasource/MockData.ets`             |
| 数据模型(含brand) | `entry/src/main/ets/viewmodel/DataModels.ets`            |
| 后端购物车服务      | `vip-server/.../service/CartService.java`                |
| 数据库初始化       | `vip-server/sql/wph.sql`                                 |
| 购物车升级脚本      | `vip-server/sql/upgrade_cart_size_distinction.sql`       |

### 常见问题FAQ

**Q: 如何修改后端连接的数据库？**
A: 编辑 `application.yml`，修改`spring.datasource.url`。

**Q: 如何修改前端连接的后端地址？**
A: 编辑 `HttpUtil.ets` 第5行的`BASE_URL`常量。

**Q: AI客服显示"服务不可用"？**
A: 1) 检查网络权限(module.json5) ✅ 已配置
    2) 验证API密钥有效性(AiService.ets第7行)
    3) 即使API失败，本地回退库也会响应9大场景关键词

**Q: 购物车同商品不同尺码如何区分？**
A: 数据库cart表的唯一键已改为`(user_id, goods_id, color, size)`4字段组合。

**Q: 如何添加新的AI回复场景？**
A: 在`AiService.ets`中添加新的`LocalReplyRule`变量并加入`LOCAL_REPLIES`数组。


完整交互流程演示
场景1：商品详情页点击收藏（实时更新）
┌─────────────────────────────────┐
│  ←       商品详情         ♡   │  ← 未收藏状态（灰色空心）
├─────────────────────────────────┤
│                                 │
│     [商品大图]                  │
│                                 │
│     ¥134.00                    │
│     [2026新款]秋冬季男...       │
│                                 │
│     [加入购物车]                │
└─────────────────────────────────┘
              ↓ 点击爱心图标
              
┌─────────────────────────────────┐
│  ←       商品详情         ❤️  │  ← 已收藏状态（粉色实心）✨
├─────────────────────────────────┤
│                                 │
│     Toast: "已添加到收藏夹"     │  ← 立即提示
│                                 │
└─────────────────────────────────┘

✅ 图标立即变化，无需等待或退出！

场景2：收藏夹 ↔ 详情页 来回切换（状态同步）

步骤1: 进入"我的收藏"页面
    ↓
┌─────────────────────────────────┐
│  ←     我的收藏          共3件  │
├─────────────────────────────────┤
│  ┌─────────────────────┐       │
│  │ [商品图片]           │       │
│  │ [2026新款]...  ¥134 │  🗑️  │
│  └─────────────────────┘       │
│  ┌─────────────────────┐       │
│  │ [商品图片]           │       │
│  │ [2026新款]...  ¥99  │  🗑️  │
│  └─────────────────────┘       │
└─────────────────────────────────┘
    ↓ 点击第一个商品
    
步骤2: 进入商品详情页
    ↓
┌─────────────────────────────────┐
│  ←       商品详情         ❤️  │  ← 自动显示已收藏（粉色）✨
├─────────────────────────────────┤
│     [商品信息...]               │
└─────────────────────────────────┘
    ↓ 点击爱心取消收藏
    
步骤3: 爱心变为空心 ♡（实时更新）
    ↓
    点击返回按钮
    
步骤4: 返回"我的收藏"页面
    ↓
┌─────────────────────────────────┐
│  ←     我的收藏          共2件  │  ← 数量自动减少！✨
├─────────────────────────────────┤
│  ┌─────────────────────┐       │
│  │ [商品图片]           │       │  ← 第一个商品消失了！
│  │ [2026新款]...  ¥99  │  🗑️  │
│  └─────────────────────┘       │
└─────────────────────────────────┘

✅ 数据完全同步，无需手动刷新！
场景3：详情页收藏 → 收藏夹查看（新增同步）

步骤1: 在商城浏览某商品
    ↓
    点击进入详情页
    
步骤2: 详情页点击 ♡ 收藏
    ↓
    图标变为 ❤️（粉色实心）
    Toast: "已添加到收藏夹"
    
步骤3: 导航到"我的"页面
    ↓
    点击"我的收藏"
    
步骤4: 收藏夹页面
    ↓
┌─────────────────────────────────┐
│  ←     我的收藏          共4件  │  ← 数量+1 ✨
├─────────────────────────────────┤
│  ┌─────────────────────┐       │
│  │ [新收藏的商品图片]   │  ← 新出现的商品！
│  │ [商品名称]  ¥价格   │  🗑️  │
│  └─────────────────────┘       │
│  ...其他已有收藏...            │
└─────────────────────────────────┘

✅ 新收藏的商品立即可见！