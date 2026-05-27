import http from '@ohos.net.http'

// DeepSeek API 配置
const DEEPSEEK_BASE_URL: string = 'https://api.deepseek.com/v1'
const CHAT_COMPLETIONS_PATH: string = '/chat/completions'
const DEEPSEEK_MODEL: string = 'deepseek-chat'

// 获取地址：https://platform.deepseek.com/api_keys
const API_KEY: string = 'sk-527b072285c44912923b7d2235d23fe2'

// 消息接口定义（兼容 OpenAI/DeepSeek 格式）
interface ChatMessage {
  role: string
  content: string
}

// DeepSeek API 响应结构
interface DeepSeekChoice {
  index: number
  message: ChatMessage
  finish_reason: string
}

interface DeepSeekUsage {
  prompt_tokens: number
  completion_tokens: number
  total_tokens: number
}

interface DeepSeekResponse {
  id: string
  created: number
  model: string
  choices: DeepSeekChoice[]
  usage: DeepSeekUsage
}
//提问实例：羽绒服185 80kg穿什么尺码?

// 请求体结构
interface RequestBody {
  model: string
  messages: ChatMessage[]
  temperature: number
  top_p: number
  max_tokens?: number
  stream?: boolean
}

// 本地智能回复规则库（保留作为降级方案）
interface LocalReplyRule {
  keywords: string[]
  response: string
}

const replyLogistics: LocalReplyRule = {
  keywords: ['物流', '快递', '发货', '配送', '运输'],
  response: '关于订单物流查询📦\n\n您可以通过以下方式查询：\n1️⃣ 在"我的订单"页面查看物流状态\n2️⃣ 复制运单号到快递100/菜鸟查询\n3️⃣ 关注"唯品会"公众号获取推送\n\n一般发货后1-3天可查到物流信息哦~'
}

const replyReturn: LocalReplyRule = {
  keywords: ['退货', '退款', '换货', '退换货', '售后'],
  response: '退换货政策说明🔄\n\n✅ **7天无理由退换**：签收7天内可申请\n✅ **15天质量问题包换**：质量问题的商品\n\n操作步骤：\n1️⃣ 进入"我的订单"\n2️⃣ 点击对应订单"申请售后"\n3️⃣ 选择原因并提交\n\n我们会在1-3个工作日内处理~'
}

const replyCoupon: LocalReplyRule = {
  keywords: ['优惠券', '优惠', '红包', '满减', '折扣', '使用'],
  response: '优惠券使用指南🎫\n\n**领取方式：**\n• 首单礼金：新人注册自动发放\n• 活动券：参与活动获取\n• 品牌券：品牌页面领取\n\n**使用规则：**\n• 可叠加满减活动\n• 部分特价商品不适用\n• 有效期一般为7-30天\n\n结账时自动抵扣，记得先领再用哦~'
}

const replyMember: LocalReplyRule = {
  keywords: ['会员', '等级', 'VIP', '积分', '权益', 'SVIP'],
  response: '会员权益说明⭐\n\n**等级体系：**\n• 普通会员：注册即享\n• VIP会员：消费升级\n• SVIP超级VIP：最高权益\n\n**主要权益：**\n✅ 专属折扣和优惠券\n✅ 免费配送门槛降低\n✅ 专属客服通道\n✅ 积分加速累积\n\n消费越多，等级越高，优惠越大哦~'
}

const replyPayment: LocalReplyRule = {
  keywords: ['支付', '付款', '微信', '支付宝', '银行卡', '发票'],
  response: '支付与发票说明💳\n\n**支持方式：**\n• 微信支付\n• 支付宝\n• 银联卡支付\n• 唯品花/唯品金融\n\n**发票申请：**\n订单完成后可在"我的订单-开发票"中申请电子发票，一般24小时内开具~'
}

const replySize: LocalReplyRule = {
  keywords: ['尺码', '尺寸', '大小', '怎么选', '合适', '穿什么'],
  response: '尺码选择建议👔\n\n**通用尺码参考：**\n• XS号：身高155-160cm，体重40-45kg\n• S号：身高160-165cm，体重45-50kg\n• M号：身高165-170cm，体重50-58kg\n• L号：身高170-175cm，体重58-65kg\n• XL号：身高175-180cm，体重65-75kg\n\n建议根据平时穿着习惯选择，宽松款可选大一码哦~'
}

const replyMaterial: LocalReplyRule = {
  keywords: ['材质', '面料', '棉', '聚酯纤维', '洗涤', '清洗'],
  response: '材质与洗涤指南🧺\n\n**常见材质：**\n• 纯棉：透气舒适，易皱需熨烫\n• 聚酯纤维：抗皱耐磨，不易变形\n• 混纺：兼具两者优点\n\n**洗涤建议：**\n• 冷水手洗最佳\n• 机洗用洗衣袋保护\n• 避免暴晒，阴干为佳\n• 详细请看商品洗标标签~'
}

const replyStock: LocalReplyRule = {
  keywords: ['库存', '没货', '缺货', '补货', '什么时候有', '预售'],
  response: '库存与补货说明📋\n\n**当前库存情况：**\n• 热销商品可能暂时缺货\n• 可以点击"到货通知"提醒\n\n**补货周期：**\n• 常规商品：3-7天\n• 预售商品：7-15天\n• 季节性商品：可能需要更久\n\n设置提醒后，到货我们会第一时间通知您~'
}

const replyGreeting: LocalReplyRule = {
  keywords: ['你好', '在吗', '有人吗', '客服', '帮助', '谢谢'],
  response: '您好呀！我是智能客服小唯😊\n\n很高兴为您服务！我可以帮您：\n📦 查询订单和物流\n🔄 处理退换货问题\n🎫 解答优惠活动疑问\n📏 商品尺码和材质咨询\n⭐ 会员权益说明\n\n请问有什么可以帮到您的呢？'
}

const LOCAL_REPLIES: LocalReplyRule[] = [
  replyLogistics,
  replyReturn,
  replyCoupon,
  replyMember,
  replyPayment,
  replySize,
  replyMaterial,
  replyStock,
  replyGreeting
]

class AiService {
  /**
   * 调用 DeepSeek API 进行智能对话
   * @param userMessage 用户输入的消息
   * @param chatHistory 历史对话记录（可选）
   * @returns AI 回复内容
   */
  static async chat(userMessage: string, chatHistory: ChatMessage[] = []): Promise<string> {
    // 系统提示词：定义客服角色和规范
    const systemMessage: ChatMessage = {
      role: 'system',
      content: '你是智能客服小唯，一个专业、友好、高效的电商客服助手。\n\n你的职责包括但不限于：\n1. 查询订单状态和物流信息\n2. 处理退换货申请和售后问题\n3. 解答商品相关问题（尺码、材质、搭配等）\n4. 查询优惠活动、优惠券使用方法\n5. 介绍会员权益和等级体系\n6. 支付方式、发票等问题\n\n回答要求：\n- 使用简洁友好的语气，适当使用emoji增加亲和力\n- 回答要具体实用，避免空泛\n- 如果涉及APP的具体政策，请基于一般电商平台的通用规则给出合理建议\n- 每次回复控制在200字以内，保持简洁\n- 不要编造具体的订单号或物流单号'
    }

    const userMsg: ChatMessage = {
      role: 'user',
      content: userMessage
    }

    // 构建完整消息列表：系统消息 + 历史记录 + 当前用户消息
    const allMessages: ChatMessage[] = [systemMessage, ...chatHistory, userMsg]

    // 请求体配置
    const requestBody: RequestBody = {
      model: DEEPSEEK_MODEL,
      messages: allMessages,
      temperature: 0.8,      // 控制创造性，范围 0-2
      top_p: 0.8,            // 核采样参数
      max_tokens: 500,       // 最大输出长度
      stream: false          // 非流式输出
    }

    const client: http.HttpRequest = http.createHttp()
    try {
      const url: string = `${DEEPSEEK_BASE_URL}${CHAT_COMPLETIONS_PATH}`
      console.info('🤖 DeepSeek API 请求发送:', userMessage.substring(0, 50))

      const res: http.HttpResponse = await client.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${API_KEY}`
        },
        extraData: JSON.stringify(requestBody),
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 15000,   // 连接超时 15 秒
        readTimeout: 30000       // 读取超时 30 秒
      })

      // 检查 HTTP 状态码
      if (res.responseCode !== 200) {
        console.error(`❌ DeepSeek API 请求失败，HTTP 状态码: ${res.responseCode}`)
        throw new Error(`DeepSeek API 请求失败 (HTTP ${res.responseCode})`)
      }

      // 解析响应数据
      const data: DeepSeekResponse = JSON.parse(res.result as string) as DeepSeekResponse

      if (!data.choices || data.choices.length === 0 || !data.choices[0].message?.content) {
        console.error('❌ DeepSeek API 返回数据异常:', res.result as string)
        throw new Error('DeepSeek API 返回内容为空')
      }

      const replyContent: string = data.choices[0].message.content
      console.info(`✅ DeepSeek 回复成功 (使用 ${data.usage?.total_tokens || 0} tokens):`, replyContent.substring(0, 80))
      return replyContent

    } catch (e) {
      console.error('❌ DeepSeek API 调用异常:', JSON.stringify(e))

      // 降级方案：尝试本地规则匹配
      const localReply: string | null = AiService.getLocalReply(userMessage)
      if (localReply) {
        console.info('📚 使用本地回复库降级响应')
        return localReply
      }

      // 如果本地也没有匹配规则，抛出异常
      if (e instanceof Error) {
        throw new Error(`AI 服务不可用: ${e.message}`)
      }
      throw new Error('AI 服务异常，请稍后重试')
    } finally {
      client.destroy()  // 销毁 HTTP 请求对象，释放资源
    }
  }

  /**
   * 本地规则匹配（作为 API 调用失败时的降级方案）
   * @param message 用户输入的消息
   * @returns 匹配的本地回复内容，如果没有匹配则返回 null
   */
  static getLocalReply(message: string): string | null {
    const lowerMsg: string = message.toLowerCase()

    for (const rule of LOCAL_REPLIES) {
      for (const keyword of rule.keywords) {
        if (lowerMsg.includes(keyword.toLowerCase())) {
          return rule.response
        }
      }
    }

    return null
  }
}

export default AiService