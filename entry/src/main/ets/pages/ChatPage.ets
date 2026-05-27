import CommonConstants from '../constants/CommonConstants';
import { ChatMessage } from '../viewmodel/DataModels';
import { getChatMessages, addChatMessage, simulateSellerReply, markSessionAsRead } from '../datasource/MockMessageService';
import router from '@ohos.router';
import userInfoService from '../datasource/UserInfoService';
import AiService from '../utils/AiService';

interface QuickQuestion {
  text: string
  icon: string
}

interface ChatHistoryItem {
  role: string
  content: string
}

@Entry
@Component
struct ChatPage {
  @State messages: ChatMessage[] = [];
  @State inputValue: string = '';
  @State sellerId: string = '';
  @State sellerName: string = '';
  @State isSmartService: boolean = false;
  @State isAiLoading: boolean = false;
  private userSenderId: string = 'user_001';
  private userSenderName: string = '我';
  private scrollController: Scroller = new Scroller();
  private pendingScrollTimer: number = -1;

  @State quickQuestions: QuickQuestion[] = [
    { text: '订单物流查询', icon: '📦' },
    { text: '退换货政策', icon: '🔄' },
    { text: '优惠券使用', icon: '🎫' },
    { text: '会员权益说明', icon: '⭐' }
  ];

  onPageShow(): void {
    const params: Record<string, Object> | undefined = router.getParams() as Record<string, Object> | undefined;
    if (params && params['sellerId'] && params['sellerName']) {
      this.sellerId = params['sellerId'] as string;
      this.sellerName = params['sellerName'] as string;

      if (this.sellerId === 'smart_service_001') {
        this.isSmartService = true;
        this.loadSmartServiceMessages();
      } else {
        markSessionAsRead(this.sellerId);
        this.loadChatMessages();
      }

      this.scrollToBottom(100);
    } else {
      router.back();
    }
  }

  private loadChatMessages(): void {
    this.messages = getChatMessages(this.sellerId);
    this.scrollToBottom(50);
  }

  private loadSmartServiceMessages(): void {
    this.messages = [
      {
        id: 'welcome_1',
        senderId: 'smart_service',
        senderName: '智能客服',
        receiverId: this.userSenderId,
        content: '您好！我是唯品会智能客服小唯，很高兴为您服务~\n\n我可以帮您：\n• 查询订单状态和物流\n• 处理退换货申请\n• 解答商品相关问题\n• 查询优惠活动信息\n\n请问有什么可以帮到您的？',
        type: 'text',
        timestamp: new Date().toISOString().slice(0, 19).replace('T', ' '),
        isRead: true
      } as ChatMessage
    ];
    this.scrollToBottom(50);
  }

  private scrollToBottom(delayMs: number = 0): void {
    if (this.pendingScrollTimer > -1) {
      clearTimeout(this.pendingScrollTimer);
      this.pendingScrollTimer = -1;
    }
    this.pendingScrollTimer = setTimeout(() => {
      this.scrollController.scrollEdge(Edge.Bottom);
      this.pendingScrollTimer = -1;
    }, delayMs);
  }

  private sendMessage(): void {
    if (this.inputValue.trim() === '') {
      return;
    }

    const newMessage: ChatMessage = {
      id: `msg_${Date.now()}`,
      senderId: this.userSenderId,
      senderName: this.userSenderName,
      receiverId: this.sellerId,
      content: this.inputValue.trim(),
      type: 'text',
      timestamp: new Date().toISOString().slice(0, 19).replace('T', ' '),
      isRead: true
    };

    this.messages = [...this.messages, newMessage];
    addChatMessage(this.sellerId, newMessage);

    const userText: string = this.inputValue.trim();
    this.inputValue = '';

    this.scrollToBottom(50);

    if (this.isSmartService) {
      this.isAiLoading = true;
      this.generateSmartReply(userText);
    } else {
      this.simulateSellerReply();
    }
  }

  private sendQuickQuestion(question: string): void {
    this.inputValue = question;
    this.sendMessage();
  }

  private async generateSmartReply(userText: string): Promise<void> {
    this.isAiLoading = true;

    try {
      const chatHistory: ChatHistoryItem[] = this.messages
        .filter((m: ChatMessage) => m.id !== 'welcome_1')
        .slice(-10)
        .map((m: ChatMessage): ChatHistoryItem => {
          const item: ChatHistoryItem = {
            role: m.senderId === this.userSenderId ? 'user' : 'assistant',
            content: m.content
          }
          return item
        });

      const replyContent: string = await AiService.chat(userText, chatHistory);

      const replyMessage: ChatMessage = {
        id: `reply_${Date.now()}`,
        senderId: this.sellerId,
        senderName: '智能客服',
        receiverId: this.userSenderId,
        content: replyContent,
        type: 'text',
        timestamp: new Date().toISOString().slice(0, 19).replace('T', ' '),
        isRead: true
      };
      this.messages = [...this.messages, replyMessage];
      addChatMessage(this.sellerId, replyMessage);
      this.scrollToBottom(50);
    } catch (e) {
      console.error('❌ AI回复失败:', JSON.stringify(e));

      const fallbackReplies: string[] = [
        '抱歉，AI服务暂时不可用，请稍后重试。您可以尝试问我：\n• "怎么查物流"\n• "如何退货"\n• "有什么优惠活动"',
        '网络连接出现问题，智能客服暂时离线。您也可以在"我的订单"中查看相关信息哦~',
        '抱歉让您久等了，服务暂时繁忙。建议稍后再试，或拨打客服热线 400-123-4567 获取帮助'
      ];
      const randomIndex: number = Math.floor(Math.random() * fallbackReplies.length);

      const errorMessage: ChatMessage = {
        id: `error_${Date.now()}`,
        senderId: this.sellerId,
        senderName: '智能客服',
        receiverId: this.userSenderId,
        content: fallbackReplies[randomIndex],
        type: 'text',
        timestamp: new Date().toISOString().slice(0, 19).replace('T', ' '),
        isRead: true
      };
      this.messages = [...this.messages, errorMessage];
      addChatMessage(this.sellerId, errorMessage);
      this.scrollToBottom(50);
    } finally {
      this.isAiLoading = false;
    }
  }

  private simulateSellerReply(): void {
    setTimeout(() => {
      const replyMessage = simulateSellerReply(this.sellerId, this.userSenderId);
      this.messages = [...this.messages, replyMessage];
      this.scrollToBottom(50);
    }, 1000);
  }

  private formatTime(timestamp: string): string {
    if (!timestamp) return '';
    const date: Date = new Date(timestamp);
    return `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }

  build() {
    Column() {
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .width(22)
          .height(22)
          .fontColor(['#1C1C1E'])
          .onClick(() => {
            router.back();
          })

        Text(this.sellerName)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1C1C1E')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        if (this.isSmartService) {
          SymbolGlyph($r('sys.symbol.star_fill'))
            .width(20)
            .height(20)
            .fontColor(['#FF2D55'])
        } else {
          Blank().width(20)
        }
      }
      .width('100%')
      .height(52)
      .padding({ left: 14, right: 14 })
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF')

      Divider().color('#F0F0F0').strokeWidth(0.5)

      Stack() {
        Scroll(this.scrollController) {
          Column() {
            ForEach(this.messages, (message: ChatMessage) => {
              if (message.senderId === this.userSenderId) {
                this.buildUserBubble(message)
              } else {
                this.buildSellerBubble(message)
              }
            }, (message: ChatMessage): string => message.id)

            if (this.isAiLoading) {
              Row() {
                Image($r('app.media.card'))
                  .width(28)
                  .height(28)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(14)
                  .backgroundColor('#E8E8EE')
                  .margin({ right: 8 })

                Column() {
                  Text('智能客服')
                    .fontSize(11)
                    .fontColor('#999999')
                    .margin({ bottom: 4 })

                  Row() {
                    Text('AI正在思考中')
                      .fontSize(13)
                      .fontColor('#666666')

                    LoadingProgress()
                      .width(16)
                      .height(16)
                      .color('#FF2D55')
                      .margin({ left: 8 })
                  }
                }
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding({ left: 12, right: 40, top: 8, bottom: 8 })
            }

            Row()
              .height(16)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
      }
      .width('100%')
      .flexGrow(1)
      .backgroundColor('#F5F5F7')
      .align(Alignment.Top)

      if (this.isSmartService && this.messages.length <= 1 && !this.isAiLoading) {
        this.buildQuickQuestionsSection()
      }

      this.buildInputSection()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildUserBubble(message: ChatMessage) {
    Row() {
      Blank()

      Column() {
        Text(message.content)
          .fontSize(14)
          .fontColor('#333333')
          .padding({ left: 14, right: 14, top: 9, bottom: 9 })
          .backgroundColor('#FF2D55')
          .borderRadius({
            topLeft: 16,
            topRight: 16,
            bottomLeft: 4,
            bottomRight: 16
          })
          .constraintSize({ maxWidth: '75%' })

        Text(this.formatTime(message.timestamp))
          .fontSize(10)
          .fontColor('#BBBBBB')
          .margin({ top: 5 })
          .textAlign(TextAlign.End)
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding({ left: 40, right: 12, top: 8, bottom: 8 })
    .justifyContent(FlexAlign.End)
  }

  @Builder
  buildSellerBubble(message: ChatMessage) {
    Row() {
      Stack() {
        Image($r('app.media.card'))
          .width(34)
          .height(34)
          .objectFit(ImageFit.Cover)
          .borderRadius(17)
          .backgroundColor('#E8E8EE')

        if (this.isSmartService) {
          Text('AI')
            .fontSize(9)
            .fontColor('#FFFFFF')
            .backgroundColor('#FF2D55')
            .padding({ left: 3, right: 3, top: 0, bottom: 0 })
            .borderRadius(6)
            .position({ x: 18, y: 18 })
        }
      }
      .width(34)
      .height(34)
      .margin({ right: 8 })

      Column() {
        Text(message.senderName)
          .fontSize(11)
          .fontColor('#999999')
          .margin({ bottom: 4 })
          .textAlign(TextAlign.Start)

        Text(message.content)
          .fontSize(14)
          .fontColor('#333333')
          .padding({ left: 14, right: 14, top: 9, bottom: 9 })
          .backgroundColor('#FFFFFF')
          .borderRadius({
            topLeft: 16,
            topRight: 4,
            bottomLeft: 16,
            bottomRight: 16
          })

        Text(this.formatTime(message.timestamp))
          .fontSize(10)
          .fontColor('#BBBBBB')
          .margin({ top: 5 })
          .textAlign(TextAlign.Start)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ left: 12, right: 40, top: 8, bottom: 8 })
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  buildQuickQuestionsSection() {
    Column() {
      Text('常见问题 快捷提问')
        .fontSize(13)
        .fontColor('#888888')
        .margin({ bottom: 10 })
        .alignSelf(ItemAlign.Center)

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.quickQuestions, (q: QuickQuestion) => {
          Text(q.text + q.icon)
            .fontSize(13)
            .fontColor('#FF2D55')
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor('#FFF5F7')
            .borderRadius(18)
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.sendQuickQuestion(q.text);
            })
        }, (q: QuickQuestion): string => 'qq_' + q.text)
      }
      .width('100%')
      .padding({ left: 12, right: 12, bottom: 8 })
    }
    .width('100%')
    .backgroundColor('#FAFAFA')
  }

  @Builder
  buildInputSection() {
    Column() {
      Row() {
        TextInput({
          text: this.inputValue,
          placeholder: this.isAiLoading ? 'AI正在回复中...' : (this.isSmartService ? '输入您的问题...' : '请输入消息...')
        })
          .layoutWeight(1)
          .height(38)
          .backgroundColor('#FFFFFF')
          .borderRadius(19)
          .padding({ left: 16, right: 16 })
          .fontSize(14)
          .maxLength(500)
          .enabled(!this.isAiLoading)
          .onChange((value: string) => {
            this.inputValue = value;
          })
          .onSubmit(() => {
            this.sendMessage();
          })

        Button(this.isAiLoading ? '思考中' : '发送')
          .fontSize(13)
          .fontColor('#FFFFFF')
          .backgroundColor((this.inputValue.trim() !== '' && !this.isAiLoading) ? '#FF2D55' : '#DDDDDD')
          .height(36)
          .padding({ left: 16, right: 16 })
          .borderRadius(18)
          .margin({ left: 10 })
          .enabled(this.inputValue.trim() !== '' && !this.isAiLoading)
          .onClick(() => {
            this.sendMessage();
          })
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
    }
    .width('100%')
    .backgroundColor('#F5F5F7')
  }
}
