import CommonConstants from '../constants/CommonConstants';
import { SystemNotification, ChatSession } from '../viewmodel/DataModels';
import { getSystemNotifications, getChatSessions, getTotalUnreadCount } from '../datasource/MockMessageService';
import router from '@ohos.router';

interface NotificationItem {
  id: string;
  title: string;
  content: string;
  timestamp: string;
  unreadCount: number;
}

interface SessionItem {
  sellerId: string;
  sellerName: string;
  avatar: Resource | string;
  lastMessage: string;
  timestamp: string;
  unreadCount: number;
}

@Entry
@Component
export default struct MessageListPage {
  @State systemNotifications: NotificationItem[] = [];
  @State chatSessions: SessionItem[] = [];
  @State totalUnreadCount: number = 0;
  @State searchValue: string = '';

  aboutToAppear(): void {
    this.loadData();
  }

  private loadData(): void {
    const rawNotifs: SystemNotification[] = getSystemNotifications();
    this.systemNotifications = rawNotifs.map((n: SystemNotification): NotificationItem => {
      return {
        id: n.id,
        title: n.title,
        content: n.content,
        timestamp: n.timestamp,
        unreadCount: n.unreadCount
      };
    });

    const rawSessions: ChatSession[] = getChatSessions();
    this.chatSessions = rawSessions.map((s: ChatSession): SessionItem => {
      return {
        sellerId: s.sellerId,
        sellerName: s.sellerName,
        avatar: $r('app.media.card'),
        lastMessage: s.lastMessage.content,
        timestamp: s.timestamp,
        unreadCount: s.unreadCount
      };
    });

    this.totalUnreadCount = getTotalUnreadCount();
  }

  private navigateToChatPage(session: SessionItem): void {
    router.pushUrl({
      url: 'pages/ChatPage',
      params: {
        sellerId: session.sellerId,
        sellerName: session.sellerName
      }
    });
  }

  private navigateToSmartService(): void {
    router.pushUrl({
      url: 'pages/ChatPage',
      params: {
        sellerId: 'smart_service_001',
        sellerName: '智能客服'
      }
    });
  }

  private formatTime(timestamp: string): string {
    if (!timestamp) return '';
    const date: Date = new Date(timestamp);
    const now: Date = new Date();

    if (date.toDateString() === now.toDateString()) {
      return `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
    }
    const yesterday: Date = new Date(now);
    yesterday.setDate(yesterday.getDate() - 1);
    if (date.toDateString() === yesterday.toDateString()) {
      return '昨天';
    }
    return `${date.getMonth() + 1}-${date.getDate()}`;
  }

  build() {
    Column() {
      Row() {
        Text('消息')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank().width(28)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 12 })
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FF2D55')

      Scroll() {
        Column({ space: 0 }) {

          Row() {
            SymbolGlyph($r('sys.symbol.magnifyingglass'))
              .width(16)
              .height(16)
              .fontColor(['#999999'])

            TextInput({ placeholder: '搜索消息内容', text: this.searchValue })
              .layoutWeight(1)
              .height(34)
              .backgroundColor(Color.Transparent)
              .placeholderColor('#BBBBBB')
              .fontSize(14)
              .onChange((value: string) => {
                this.searchValue = value;
              })
              .onSubmit(() => {
                if (this.searchValue.trim()) {
                  router.pushUrl({ url: 'pages/SearchPage', params: { keyword: this.searchValue } });
                }
              })
          }
          .width('94%')
          .height(36)
          .padding({ left: 12, right: 12 })
          .backgroundColor('#FFFFFF')
          .borderRadius(18)
          .margin({ top: 8, bottom: 8, left: 12 })

          this.buildSmartServiceSection()
          this.buildSystemNotificationSection()
          this.buildChatSessionSection()
        }
      }
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F7')
  }

  @Builder
  buildSmartServiceSection() {
    Column() {
      Row() {
        SymbolGlyph($r('sys.symbol.star_fill'))
          .width(20)
          .height(20)
          .fontColor(['#FF2D55'])

        Text('智能客服')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1C1C1E')
          .margin({ left: 8 })

        Text('AI在线 · 即时响应')
          .fontSize(11)
          .fontColor('#FF2D55')
          .backgroundColor('#FFF0F3')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(4)
          .margin({ left: 8 })

        Blank()

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .width(14)
          .height(14)
          .fontColor(['#CCCCCC'])
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')
      .borderRadius(10)
      .onClick(() => {
        this.navigateToSmartService();
      })
    }
    .width('100%')
    .margin({ left: 12, right: 12, top: 0, bottom: 8 })
  }

  @Builder
  buildSystemNotificationSection() {
    Column() {
      Row() {
        Text('系统通知')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1C1C1E')

        Blank()

        if (this.systemNotifications.length > 0) {
          Text(`${this.systemNotifications.length}条`)
            .fontSize(12)
            .fontColor('#999999')
        }
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 12, bottom: 8 })

      ForEach(this.systemNotifications, (item: NotificationItem) => {
        Row() {
          SymbolGlyph($r('sys.symbol.bell_fill'))
            .width(22)
            .height(22)
            .fontColor(['#FF9500'])
            .margin({ right: 12 })

          Column() {
            Text(item.title)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1C1C1E')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')

            Text(item.content)
              .fontSize(12)
              .fontColor('#888888')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
              .margin({ top: 3 })
          }
          .layoutWeight(1)

          Column() {
            Text(this.formatTime(item.timestamp))
              .fontSize(11)
              .fontColor('#BBBBBB')

            if (item.unreadCount > 0) {
              Text(String(item.unreadCount))
                .fontSize(11)
                .fontColor('#FFFFFF')
                .backgroundColor('#FF3B30')
                .padding({ left: 7, right: 7, top: 1, bottom: 1 })
                .borderRadius(9)
                .margin({ top: 5 })
            }
          }
          .alignItems(HorizontalAlign.End)
          .margin({ right: 12 })
        }
        .width('100%')
        .padding({ left: 12, right: 0, top: 10, bottom: 10 })
        .backgroundColor('#FFFFFF')
        .borderRadius(10)
        .margin({ left: 12, right: 12, top: 4, bottom: 4 })
        .onClick(() => {
          console.log('点击系统通知:', item.title);
        })
      }, (item: NotificationItem): string => 'notif_' + item.id)
    }
    .width('100%')
    .margin({ left: 0, right: 0, top: 0, bottom: 8 })
  }

  @Builder
  buildChatSessionSection() {
    Column() {
      Row() {
        Text('聊天会话')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1C1C1E')

        Blank()

        if (this.totalUnreadCount > 0) {
          Text(`${this.totalUnreadCount}条未读`)
            .fontSize(11)
            .fontColor('#FF2D55')
            .backgroundColor('#FFF0F3')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4)
        }
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 12, bottom: 8 })

      ForEach(this.chatSessions, (session: SessionItem) => {
        Row() {
          Stack() {
            Image($r('app.media.card'))
              .width(44)
              .height(44)
              .objectFit(ImageFit.Cover)
              .borderRadius(22)
              .backgroundColor('#E8E8EE')

            if (session.unreadCount > 0) {
              Text(session.unreadCount > 99 ? '99+' : String(session.unreadCount))
                .fontSize(10)
                .fontColor('#FFFFFF')
                .backgroundColor('#FF2D55')
                .padding({ left: 5, right: 5, top: 1, bottom: 1 })
                .borderRadius(8)
                .position({ x: 26, y: -2 })
            }
          }
          .width(44)
          .height(44)
          .margin({ right: 10 })

          Column() {
            Row() {
              Text(session.sellerName)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1C1C1E')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)

              Text(this.formatTime(session.timestamp))
                .fontSize(11)
                .fontColor('#BBBBBB')
            }
            .width('100%')

            Text(session.lastMessage)
              .fontSize(12)
              .fontColor('#888888')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
              .margin({ top: 3 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 10, bottom: 10 })
        .backgroundColor('#FFFFFF')
        .borderRadius(10)
        .margin({ left: 12, right: 12, top: 4, bottom: 4 })
        .onClick(() => {
          this.navigateToChatPage(session);
        })
      }, (session: SessionItem): string => 'session_' + session.sellerId)
    }
    .width('100%')
    .layoutWeight(1)
  }
}
