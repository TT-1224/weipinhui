import router from '@ohos.router';
import OrderManager, { OrderInfo } from '../manager/OrderManager';
import ImageUtil from '../utils/ImageUtil';
import promptAction from '@ohos.promptAction';

interface OrderItem {
  id: number;
  orderId: number;
  goodsId: number;
  goodsName: string;
  goodsImage: string | Resource;
  goodsPrice: number;
  quantity: number;
  properColor: string;
  properSize: string;
}

interface ConfirmOrderItem {
  goodsId: number;
  goodsName: string;
  goodsImage: string | Resource;
  goodsPrice: number;
  quantity: number;
  properColor: string;
  properSize: string;
}

@Entry
@Component
export default struct OrderPage {
  @State currentTab: number = -1;
  @State orderList: OrderInfo[] = [];
  @State isLoading: boolean = true;
  @State orderDetailsMap: Map<number, OrderItem[]> = new Map();
  @State showReviewSheet: boolean = false;
  @State reviewOrderId: number = 0;
  @State reviewRating: number = 5;
  @State reviewContent: string = '';

  aboutToAppear(): void {
    const params: Record<string, Object> | undefined = router.getParams() as Record<string, Object> | undefined;
    if (params && params['status'] !== undefined) {
      this.currentTab = params['status'] as number;
    }
    this.loadOrders();
    OrderManager.subscribe(() => {
      this.onOrderDataChanged();
    });
  }

  aboutToDisappear() {
    OrderManager.unsubscribe(() => {
      this.onOrderDataChanged();
    });
  }

  private onOrderDataChanged(): void {
    this.loadOrders();
  }

  private async loadOrders(): Promise<void> {
    this.isLoading = true;
    try {
      const list: OrderInfo[] = await OrderManager.getOrderListByStatus(this.currentTab);
      this.orderList = list;

      for (const order of list) {
        const detail = await OrderManager.getOrderDetail(order.id);
        if (detail && detail.items) {
          this.orderDetailsMap.set(order.id, detail.items as OrderItem[]);
        }
      }
    } catch (error) {
      console.error('加载订单失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  private switchTab(index: number): void {
    if (this.currentTab !== index) {
      this.currentTab = index;
      this.loadOrders();
    }
  }

  private getStatusColor(status: number): ResourceColor {
    switch (status) {
      case 0:
        return '#FF9500';
      case 1:
        return '#007AFF';
      case 2:
        return '#34C759';
      case 3:
        return '#FF9500';
      case 4:
        return '#FF3B30';
      default:
        return '#8E8E93';
    }
  }

  private getStatusText(status: number): string {
    return OrderManager.getStatusText(status);
  }

  build() {
    Column() {
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .width(24)
          .height(24)
          .fontColor(['#1C1C1E', '#FFFFFF'])
          .onClick(() => {
            router.back();
          })

        Text('我的订单')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1C1C1E')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('')
          .width(24)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      Row({ space: 16 }) {
        this.buildTabItem(-1, '全部')
        this.buildTabItem(0, '待付款')
        this.buildTabItem(1, '待发货')
        this.buildTabItem(2, '待收货')
        this.buildTabItem(3, '待评价')
      }
      .width('100%')
      .height(48)
      .backgroundColor('#FFFFFF')
      .padding({ left: 12, right: 12 })
      .justifyContent(FlexAlign.SpaceAround)

      Divider()
        .color('#F5F5F7')
        .strokeWidth(1)

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#007AFF')
            .margin({ top: 100 })
          Text('加载中...')
            .fontSize(14)
            .fontColor('#8E8E93')
            .margin({ top: 12 })
        }
        .width('100%')
        .height('100%')
        .layoutWeight(1)
      } else if (this.orderList.length === 0) {
        Column() {
          SymbolGlyph($r('sys.symbol.doc_text'))
            .width(80)
            .height(80)
            .fontColor(['#C7C7CC', '#48484A'])
            .margin({ top: 100 })
          Text('暂无订单')
            .fontSize(16)
            .fontColor('#8E8E93')
            .margin({ top: 16 })
          Text('去逛逛吧~')
            .fontSize(14)
            .fontColor('#007AFF')
            .margin({ top: 8 })
            .onClick(() => {
              router.back();
            })
        }
        .width('100%')
        .height('100%')
        .layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.orderList, (order: OrderInfo, index?: number) => {
              this.buildOrderCard(order)
            }, (order: OrderInfo, index?: number): string => 'order_' + String(order.id ?? index))
          }
          .width('100%')
          .padding(12)
          .alignItems(HorizontalAlign.Start)
        }
        .scrollBar(BarState.Auto)
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
        .align(Alignment.Top)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F7')
    .bindSheet($$this.showReviewSheet, this.buildReviewSheet(), {
      height: 380,
      dragBar: true,
      backgroundColor: '#FFFFFF',
      showClose: true,
      onDisappear: () => {
        this.showReviewSheet = false;
      }
    })
  }

  @Builder
  buildTabItem(status: number, title: string) {
    Column() {
      Text(title)
        .fontSize(15)
        .fontWeight(this.currentTab === status ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.currentTab === status ? '#FF2D55' : '#1C1C1E')

      if (this.currentTab === status) {
        Row()
          .width(24)
          .height(3)
          .borderRadius(1.5)
          .backgroundColor('#FF2D55')
          .margin({ top: 4 })
      } else {
        Row()
          .width(24)
          .height(3)
          .margin({ top: 4 })
      }
    }
    .onClick(() => {
      this.switchTab(status);
    })
  }

  @Builder
  buildOrderCard(order: OrderInfo) {
    Column() {
      Row() {
        Column() {
          Text('订单号: ' + order.orderNo)
            .fontSize(13)
            .fontColor('#8E8E93')
          Text(order.createTime || '')
            .fontSize(11)
            .fontColor('#C7C7CC')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(this.getStatusText(order.status))
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getStatusColor(order.status))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Top)
      .padding({ bottom: 10 })

      Divider().color('#F0F0F0').strokeWidth(1)

      if (this.orderDetailsMap.has(order.id) && this.orderDetailsMap.get(order.id)!.length > 0) {
        ForEach(this.orderDetailsMap.get(order.id)!, (item: OrderItem) => {
          Row() {
            Image(ImageUtil.getGoodsImage(item.goodsImage))
              .width('70vp')
              .height('70vp')
              .objectFit(ImageFit.Cover)
              .borderRadius(8)

            Column() {
              Text(item.goodsName)
                .fontSize(13)
                .fontColor('#1C1C1E')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width('180vp')

              Row() {
                Text(item.properColor + ' / ' + item.properSize)
                  .fontSize(11)
                  .fontColor('#8E8E93')

                Blank()

                Text('x' + item.quantity)
                  .fontSize(12)
                  .fontColor('#666666')
              }
              .width('100%')
              .margin({ top: 4 })

              Text('¥' + item.goodsPrice.toFixed(2))
                .fontSize(13)
                .fontColor('#FF2D55')
                .fontWeight(FontWeight.Medium)
                .margin({ top: 2 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 10 })
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })
        }, (item: OrderItem): string => 'item_' + String(item.id))
      }

      Divider().color('#F0F0F0').strokeWidth(1).margin({ top: 8 })

      Row() {
        Text('共' + (this.orderDetailsMap.get(order.id) ? this.orderDetailsMap.get(order.id)!.length : 1) + '件商品')
          .fontSize(13)
          .fontColor('#8E8E93')
        Blank()
        Text('实付: ¥' + Number(order.totalAmount.toFixed(2)))
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF2D55')
      }
      .width('100%')
      .margin({ top: 8 })

      Row({ space: 10 }) {
        if (order.status === 0) {
          Button('取消订单')
            .fontSize(13)
            .fontColor('#8E8E93')
            .backgroundColor('#F5F5F7')
            .height(32)
            .padding({ left: 16, right: 16 })
            .borderRadius(16)
            .onClick(() => {
              this.handleCancelOrder(order.id);
            })

          Button('确认付款')
            .fontSize(13)
            .fontColor('#FFFFFF')
            .backgroundColor('#FF2D55')
            .height(32)
            .padding({ left: 16, right: 16 })
            .borderRadius(16)
            .onClick(() => {
              this.handleRepay(order);
            })
        } else if (order.status === 2) {
          Button('确认收货')
            .fontSize(13)
            .fontColor('#FFFFFF')
            .backgroundColor('#007AFF')
            .height(32)
            .padding({ left: 16, right: 16 })
            .borderRadius(16)
            .onClick(() => {
              this.handleConfirmReceive(order.id);
            })
        } else if (order.status === 3) {
          Button('去评价')
            .fontSize(13)
            .fontColor('#FFFFFF')
            .backgroundColor('#FF9500')
            .height(32)
            .padding({ left: 16, right: 16 })
            .borderRadius(16)
            .onClick(() => {
              this.handleReview(order);
            })

          Button('删除订单')
            .fontSize(13)
            .fontColor('#FF3B30')
            .backgroundColor('#FFF0F0')
            .height(32)
            .padding({ left: 16, right: 16 })
            .borderRadius(16)
            .onClick(() => {
              this.handleDeleteOrder(order.id);
            })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .margin({ top: 12 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .padding(16)
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: '#0A000000',
      offsetX: 0,
      offsetY: 2
    })
  }

  private handleCancelOrder(orderId: number): void {
    promptAction.showDialog({
      title: '取消订单',
      message: '确定要取消该订单吗？',
      buttons: [
        { text: '再想想', color: '#8E8E93' },
        { text: '确定取消', color: '#FF3B30' }
      ]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        this.deleteOrderAsync(orderId);
      }
    });
  }

  private handleRepay(order: OrderInfo): void {
    const items: OrderItem[] | undefined = this.orderDetailsMap.get(order.id);
    const orderItems: ConfirmOrderItem[] = items ? items.map((item: OrderItem): ConfirmOrderItem => {
      return {
        goodsId: item.goodsId,
        goodsName: item.goodsName,
        goodsImage: item.goodsImage || '',
        goodsPrice: item.goodsPrice,
        quantity: item.quantity,
        properColor: item.properColor,
        properSize: item.properSize
      };
    }) : [];

    router.pushUrl({
      url: 'pages/ConfirmOrderPage',
      params: {
        type: 'direct',
        orderId: order.id,
        totalAmount: order.totalAmount,
        items: orderItems
      }
    });
  }

  private async deleteOrderAsync(orderId: number): Promise<void> {
    await OrderManager.deleteOrder(orderId);
  }

  private handleConfirmReceive(orderId: number): void {
    promptAction.showDialog({
      title: '确认收货',
      message: '确定已收到商品吗？',
      buttons: [
        { text: '取消', color: '#8E8E93' },
        { text: '确认收货', color: '#007AFF' }
      ]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        this.confirmReceiveAsync(orderId);
      }
    });
  }

  private async confirmReceiveAsync(orderId: number): Promise<void> {
    await OrderManager.updateOrderStatus(orderId, 3);
  }

  private handleDeleteOrder(orderId: number): void {
    promptAction.showDialog({
      title: '删除订单',
      message: '确定要删除该订单吗？此操作不可恢复。',
      buttons: [
        { text: '取消', color: '#8E8E93' },
        { text: '确定删除', color: '#FF3B30' }
      ]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        this.deleteOrderAsync(orderId);
      }
    });
  }

  private handleReview(order: OrderInfo): void {
    this.reviewOrderId = order.id;
    this.reviewRating = 5;
    this.reviewContent = '';
    this.showReviewSheet = true;
  }

  private async handleSubmitReview(): Promise<void> {
    if (this.reviewContent.trim().length === 0) {
      promptAction.showToast({ message: '请输入评价内容' });
      return;
    }

    promptAction.showToast({ message: `评价成功！${this.reviewRating}星好评` });

    this.showReviewSheet = false;

    await OrderManager.updateOrderStatus(this.reviewOrderId, 4);
  }

  @Builder
  buildReviewSheet() {
    Column() {
      Text('发表评价')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1C1C1E')
        .margin({ bottom: 20 })

      Row() {
        Text('商品评分')
          .fontSize(15)
          .fontColor('#1C1C1E')

        Blank()

        ForEach([1, 2, 3, 4, 5], (star: number) => {
          Text('★')
            .fontSize(28)
            .fontColor(star <= this.reviewRating ? '#FF9500' : '#E5E5EA')
            .onClick(() => {
              this.reviewRating = star;
            })
        }, (star: number): string => 'star_' + String(star))
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      TextArea({ placeholder: '分享您的购物体验吧~', text: this.reviewContent })
        .width('100%')
        .height(120)
        .backgroundColor('#F5F5F7')
        .borderRadius(10)
        .padding(12)
        .onChange((value: string) => {
          this.reviewContent = value;
        })

      Button('提交评价', { type: ButtonType.Capsule })
        .width('100%')
        .height(44)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#FF9500')
        .borderRadius(22)
        .margin({ top: 16 })
        .onClick(async () => {
          await this.handleSubmitReview();
        })
    }
    .width('100%')
    .padding(20)
  }
}
