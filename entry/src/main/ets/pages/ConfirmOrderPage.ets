import router from '@ohos.router';
import OrderManager, { OrderInfo } from '../manager/OrderManager';
import ImageUtil from '../utils/ImageUtil';
import promptAction from '@ohos.promptAction';
import { HttpUtil } from '../utils/HttpUtil';


interface ConfirmOrderItem {
  goodsId: number;
  goodsName: string;
  goodsImage: string | Resource;
  goodsPrice: number;
  quantity: number;
  properColor: string;
  properSize: string;
}

interface AddressInfo {
  id: number
  receiverName: string
  receiverPhone: string
  province: string
  city: string
  district: string
  detailAddress: string
  postalCode: string
  isDefault: number
}

interface ConfirmOrderParams {
  type: 'cart' | 'direct';
  cartIds?: number[];
  goodsId?: number;
  quantity: number;
  properColor?: string;
  properSize?: string;
  totalAmount: number;
  items: ConfirmOrderItem[];
  orderId?: number;
  addressId?: number; 
}

interface OrderDetailItem {
  id: number
  userId: number
  orderNo: string
  totalAmount: number
  status: number
  addressId: number
  createTime: string
  updateTime: string
}

interface OrderDetailResponse {
  order: OrderDetailItem
}

interface UpdateAddressRequest {
  addressId: number
}

@Entry
@Component
export default struct ConfirmOrderPage {
  @State orderItems: ConfirmOrderItem[] = [];
  @State totalAmount: number = 0;
  @State selectedPayMethod: string = 'wechat';
  @State isPaying: boolean = false;
  @State orderCreated: boolean = false;
  @State currentOrderId: number = 0;
  @State isRepayMode: boolean = false;

  @State selectedAddress: AddressInfo | null = null;
  @State isAddressLoading: boolean = false; // 新增：地址加载状态

  aboutToAppear(): void {
    const params: ConfirmOrderParams | undefined = router.getParams() as ConfirmOrderParams | undefined;

    if (params && params.totalAmount) {
      this.totalAmount = params.totalAmount;
    }

    if (params && params.items) {
      this.orderItems = params.items;
    }

    // 如果从地址页返回时携带了addressId，直接使用
    if (params && params.addressId && params.addressId > 0) {
      this.loadAddressById(params.addressId);
    }

    if (params && params.orderId) {
      this.currentOrderId = params.orderId;
      this.isRepayMode = true;
      this.orderCreated = true;
      // 待支付模式：加载订单关联的地址
      this.loadOrderAddress(params.orderId);
      return;
    }

    // ✅ 修复时序问题：先加载地址，完成后再创建订单
    this.loadDefaultAddress();
  }

  /**
   * 根据ID加载指定地址（从地址选择页返回时调用）
   */
  private async loadAddressById(addressId: number): Promise<void> {
    this.isAddressLoading = true;
    try {
      const addressList: AddressInfo[] = await HttpUtil.request<AddressInfo[]>({
        method: 'GET',
        path: '/api/address/list'
      });

      if (addressList && addressList.length > 0) {
        const found: AddressInfo | undefined = addressList.find((addr: AddressInfo) => addr.id === addressId);
        if (found) {
          this.selectedAddress = found;
          console.info('✅ [ConfirmOrder] 已选择地址:', found.receiverName);

          // 如果订单还未创建，创建新订单
          if (!this.orderCreated) {
            await this.createOrderWithAddress();
          } else {
            // 订单已存在，更新订单的收货地址
            await this.updateOrderAddress(found.id);
          }
        }
      }
    } catch (e) {
      console.error('❌ [ConfirmOrder] 加载指定地址失败:', e);
      promptAction.showToast({ message: '加载地址失败' });
    } finally {
      this.isAddressLoading = false;
    }
  }

  /**
   * 加载默认地址
   */
  private async loadDefaultAddress(): Promise<void> {
    this.isAddressLoading = true;
    try {
      const addressData: AddressInfo = await HttpUtil.request<AddressInfo>({
        method: 'GET',
        path: '/api/address/default'
      })

      if (addressData) {
        this.selectedAddress = addressData;
        console.info('✅ [ConfirmOrder] 加载默认地址成功:', addressData.receiverName);

        // ✅ 地址加载完成后，再创建订单（修复时序问题）
        if (!this.orderCreated && !this.isRepayMode) {
          await this.createOrderWithAddress();
        }
      } else {
        console.warn('⚠️ [ConfirmOrder] 无默认地址，等待用户选择');
      }
    } catch (e) {
      console.error('❌ [ConfirmOrder] 加载默认地址失败:', e)
    } finally {
      this.isAddressLoading = false;
    }
  }

  /**
   * 加载待支付订单的关联地址
   */
  private async loadOrderAddress(orderId: number): Promise<void> {
    this.isAddressLoading = true;
    try {
      // 获取订单详情以获取addressId
      const orderDetail: OrderDetailResponse =
        await HttpUtil.request<OrderDetailResponse>({
          method: 'GET',
          path: '/api/order/detail/' + orderId
        });

      if (orderDetail && orderDetail.order && orderDetail.order.addressId) {
        // 根据addressId加载完整地址信息
        await this.loadAddressById(orderDetail.order.addressId);
      } else {
        // 订单没有关联地址，尝试加载默认地址
        await this.loadDefaultAddress();
      }
    } catch (e) {
      console.error('❌ [ConfirmOrder] 加载订单地址失败:', e);
      // 降级处理：加载默认地址
      await this.loadDefaultAddress();
    } finally {
      this.isAddressLoading = false;
    }
  }

  /**
   * 使用当前选择的地址创建订单（统一入口）
   */
  private async createOrderWithAddress(): Promise<void> {
    if (!this.selectedAddress || !this.selectedAddress.id) {
      console.warn('⚠️ [ConfirmOrder] 无可用地址，暂不创建订单');
      return;
    }

    try {
      const params: ConfirmOrderParams | undefined = router.getParams() as ConfirmOrderParams | undefined;
      const orderType: string = (params && params.type) ? params.type : 'direct';

      let order: OrderInfo | null = null;

      if (orderType === 'cart') {
        const cartIds: number[] = (params && params.cartIds) ? params.cartIds : [];
        order = await OrderManager.createOrderFromCart(cartIds, this.selectedAddress.id);
      } else {
        const goodsId: number = (params && params.goodsId) ? params.goodsId : 0;
        const quantity: number = (params && params.quantity) ? params.quantity : 1;
        const properColor: string = (params && params.properColor) ? params.properColor : '';
        const properSize: string = (params && params.properSize) ? params.properSize : '';
        order = await OrderManager.createDirectOrder(goodsId, quantity, properColor, properSize, this.selectedAddress.id);
      }

      if (order !== null) {
        this.currentOrderId = order.id;
        this.orderCreated = true;
        console.info('✅ [ConfirmOrder] 订单创建成功，orderId:', order.id);
      }
    } catch (error) {
      console.error('❌ [ConfirmOrder] 创建订单失败:', error);
    }
  }

  /**
   * 更新订单的收货地址（用于待支付订单修改地址）
   */
  private async updateOrderAddress(newAddressId: number): Promise<void> {
    if (!this.currentOrderId || this.currentOrderId <= 0) {
      return;
    }

    try {
      // 调用后端接口更新订单地址
      const updateData: UpdateAddressRequest = { addressId: newAddressId };
      await HttpUtil.request<void>({
        method: 'PUT',
        path: '/api/order/updateAddress/' + this.currentOrderId,
        body: updateData
      });

      console.info('✅ [ConfirmOrder] 订单地址更新成功');
      promptAction.showToast({ message: '地址更新成功' });
    } catch (e) {
      console.error('❌ [ConfirmOrder] 更新订单地址失败:', e);
      promptAction.showToast({ message: '地址更新失败' });
    }
  }

  /**
   * 跳转到地址选择页面
   */
  private navigateToAddressSelection(): void {
    router.pushUrl({
      url: 'pages/AddressPage',
      params: {
        mode: 'select', // 标记为选择模式
        currentAddressId: this.selectedAddress?.id ?? 0
      }
    });
  }

  /**
   * 页面显示时触发（从AddressPage返回时会触发）
   * 用于处理地址选择返回的参数
   */
  onPageShow(): void {
    console.info('[ConfirmOrder] onPageShow 触发');

    // 检查是否有从地址选择页返回的参数
    const params: ConfirmOrderParams | undefined = router.getParams() as ConfirmOrderParams | undefined;

    if (params && params.addressId && params.addressId > 0) {
      console.info('[ConfirmOrder] 检测到从地址页返回，addressId:', params.addressId);

      // 如果返回的addressId与当前选中的不同，才更新
      if (!this.selectedAddress || this.selectedAddress.id !== params.addressId) {
        this.loadAddressById(params.addressId);
      }
    }
  }

  onBackPress(): boolean {
    if (this.isPaying) {
      return true;
    }

    if (this.orderCreated && !this.isRepayMode) {
      promptAction.showDialog({
        title: '确认退出',
        message: '订单已保存到"我的订单-待付款"，可随时回来支付',
        buttons: [
          { text: '继续支付', color: '#FF2D55' },
          { text: '确认退出', color: '#8E8E93' }
        ]
      }).then((result: promptAction.ShowDialogSuccessResponse) => {
        if (result.index === 1) {
          router.back();
        }
      });
    } else {
      router.back();
    }
    return true;
  }

  build() {
    Column() {
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .width(24)
          .height(24)
          .fontColor(['#1C1C1E', '#FFFFFF'])
          .onClick(() => {
            if (this.isPaying) {
              return;
            }
            if (this.orderCreated && !this.isRepayMode) {
              promptAction.showDialog({
                title: '确认退出',
                message: '订单已保存到"我的订单-待付款"，可随时回来支付',
                buttons: [
                  { text: '继续支付', color: '#FF2D55' },
                  { text: '确认退出', color: '#8E8E93' }
                ]
              }).then((result: promptAction.ShowDialogSuccessResponse) => {
                if (result.index === 1) {
                  router.back();
                }
              });
            } else {
              router.back();
            }
          })

        Text(this.isRepayMode ? '确认付款' : '确认订单')
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

      Scroll() {
        Column({ space: 12 }) {
          this.buildAddressSelectionSection()
          this.buildOrderItemsSection()
          this.buildPaymentMethodSection()
          this.buildOrderSummarySection()
          this.buildSubmitButton()
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 30 })
      }
      .scrollBar(BarState.Auto)
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F7')
  }

  @Builder
  buildAddressSelectionSection() {
    Column() {
      Row() {
        Text('收货地址')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1C1C1E')

        if (this.selectedAddress) {
          Text('默认')
            .fontSize(11)
            .fontColor('#FF2D55')
            .backgroundColor('#FFF0F3')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(4)
            .margin({ left: 8 })
        }

        Blank()

        // ✅ 新增：显示更换地址按钮
        if (this.selectedAddress && !this.isPaying) {
          Text('更换')
            .fontSize(13)
            .fontColor('#FF2D55')
            .onClick(() => {
              this.navigateToAddressSelection();
            })
        }

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .width(16)
          .height(16)
          .fontColor(['#CCCCCC', '#FFFFFF'])
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      Divider().color('#F0F0F0').strokeWidth(1).margin({ top: 10, bottom: 10 })

      if (this.isAddressLoading) {
        Row() {
          LoadingProgress()
            .color('#FF2D55')
            .width(20)
            .height(20)
          Text('加载地址中...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ left: 12 })
        }
        .width('100%')
        .padding({ top: 20, bottom: 20 })
        .justifyContent(FlexAlign.Center)
      } else if (this.selectedAddress) {
        Column({ space: 6 }) {
          Row() {
            Text(this.selectedAddress.receiverName)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')

            Text(this.selectedAddress.receiverPhone)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .margin({ left: 12 })

            Blank()
          }
          .width('100%')

          Text(`${this.selectedAddress.province}${this.selectedAddress.city}${this.selectedAddress.district}${this.selectedAddress.detailAddress}`)
            .fontSize(13)
            .fontColor('#666666')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      } else {
        Row() {
          Text('📍')
            .fontSize(18)

          Text('请选择收货地址')
            .fontSize(14)
            .fontColor('#FF2D55')
            .margin({ left: 8 })

          Blank()

          Text('去设置 >')
            .fontSize(13)
            .fontColor('#FF2D55')
        }
        .width('100%')
        .padding({ top: 12, bottom: 12 })
        .justifyContent(FlexAlign.Start)
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .padding(16)
    .borderRadius(12)
    .onClick(() => {
      // ✅ 统一跳转到地址选择页面
      this.navigateToAddressSelection();
    })
  }

  @Builder
  buildOrderItemsSection() {
    Column() {
      Row() {
        Text('商品信息')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1C1C1E')

        Text(`共${this.orderItems.length}件商品`)
          .fontSize(13)
          .fontColor('#8E8E93')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      Divider().color('#F0F0F0').strokeWidth(1).margin({ top: 10, bottom: 10 })

      ForEach(this.orderItems, (item: ConfirmOrderItem, index?: number) => {
        Row() {
          Image(ImageUtil.getGoodsImage(item.goodsImage))
            .width('80vp')
            .height('80vp')
            .objectFit(ImageFit.Cover)
            .borderRadius(8)

          Column() {
            Text(item.goodsName)
              .fontSize(14)
              .fontColor('#1C1C1E')
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('200vp')
              .margin({ bottom: 4 })

            Row() {
              Text(`${item.properColor} / ${item.properSize}`)
                .fontSize(12)
                .fontColor('#8E8E93')

              Blank()

              Text(`x${item.quantity}`)
                .fontSize(13)
                .fontColor('#666666')
            }
            .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 12 })
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#FFFFFF')
        .borderRadius(10)
        .shadow({
          radius: 6,
          color: '#0A000000',
          offsetX: 0,
          offsetY: 1
        })
      }, (item: ConfirmOrderItem, index?: number): string => 'order_item_' + String(index))
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .padding(16)
    .borderRadius(12)
  }

  @Builder
  buildPaymentMethodSection() {
    Column() {
      Row() {
        Text('支付方式')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1C1C1E')

        Blank()
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      Divider().color('#F0F0F0').strokeWidth(1).margin({ top: 10, bottom: 15 })

      Row() {
        Column() {
          Text(this.selectedPayMethod === 'wechat' ? '✓' : '')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .width(22)
            .height(22)
            .textAlign(TextAlign.Center)
            .backgroundColor(this.selectedPayMethod === 'wechat' ? '#07C160' : '#E5E5EA')
            .borderRadius(11)
        }

        Text('微信支付')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1C1C1E')
          .margin({ left: 12 })

        Blank()

        Text('推荐使用')
          .fontSize(11)
          .fontColor('#07C160')
      }
      .width('100%')
      .padding(14)
      .backgroundColor('#FFFFFF')
      .borderRadius(10)
      .alignItems(VerticalAlign.Center)
      .border({
        width: this.selectedPayMethod === 'wechat' ? 2 : 1,
        color: this.selectedPayMethod === 'wechat' ? '#07C160' : '#E5E5EA'
      })
      .onClick(() => {
        this.selectedPayMethod = 'wechat';
      })

      Row() {
        Column() {
          Text(this.selectedPayMethod === 'alipay' ? '✓' : '')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .width(22)
            .height(22)
            .textAlign(TextAlign.Center)
            .backgroundColor(this.selectedPayMethod === 'alipay' ? '#1677FF' : '#E5E5EA')
            .borderRadius(11)
        }

        Text('支付宝')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1C1C1E')
          .margin({ left: 12 })

        Blank()

        Text('安全快捷')
          .fontSize(11)
          .fontColor('#1677FF')
      }
      .width('100%')
      .padding(14)
      .backgroundColor('#FFFFFF')
      .borderRadius(10)
      .alignItems(VerticalAlign.Center)
      .border({
        width: this.selectedPayMethod === 'alipay' ? 2 : 1,
        color: this.selectedPayMethod === 'alipay' ? '#1677FF' : '#E5E5EA'
      })
      .margin({ top: 10 })
      .onClick(() => {
        this.selectedPayMethod = 'alipay';
      })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .padding(16)
    .borderRadius(12)
    .margin({ top: 12 })
  }

  @Builder
  buildOrderSummarySection() {
    Column() {
      Row() {
        Text('商品金额')
          .fontSize(14)
          .fontColor('#666666')
        Blank()
        Text(`¥${this.totalAmount.toFixed(2)}`)
          .fontSize(14)
          .fontColor('#1C1C1E')
      }
      .width('100%')

      Row() {
        Text('运费')
          .fontSize(14)
          .fontColor('#666666')
        Blank()
        Text('免运费')
          .fontSize(14)
          .fontColor('#34C759')
      }
      .width('100%')
      .margin({ top: 10 })

      Divider().color('#F0F0F0').strokeWidth(1).margin({ top: 12, bottom: 12 })

      Row() {
        Text('实付金额')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1C1C1E')
        Blank()
        Text(`¥${this.totalAmount.toFixed(2)}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF2D55')
      }
      .width('100%')
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .padding(16)
    .borderRadius(12)
  }

  @Builder
  buildSubmitButton() {
    // ✅ 优化：增加地址校验提示
    Button(
      this.isPaying
        ? '支付中...'
        : (!this.selectedAddress
        ? '请先选择收货地址'
        : `确认支付 ¥${this.totalAmount.toFixed(2)}`),
      { type: ButtonType.Capsule }
    )
      .width('100%')
      .height(48)
      .fontSize(17)
      .fontColor('#FFFFFF')
      .fontWeight(FontWeight.Medium)
      .backgroundColor(!this.isPaying && this.orderCreated && (this.selectedAddress !== null && this.selectedAddress!.id > 0) ? '#FF2D55' : '#CCCCCC')
      .enabled(!this.isPaying && this.orderCreated && (this.selectedAddress !== null && this.selectedAddress!.id > 0))
      .borderRadius(24)
      .onClick(async () => {
        if (!(!this.isPaying && this.orderCreated && (this.selectedAddress !== null && this.selectedAddress!.id > 0))) {
          if (!this.selectedAddress) {
            promptAction.showToast({ message: '请先选择收货地址' });
            this.navigateToAddressSelection();
          }
          return;
        }
        await this.handleConfirmPay();
      })
  }

  private async handleConfirmPay(): Promise<void> {
    if (this.isPaying || !this.orderCreated) return;

    // ✅ 最终校验：确保有有效地址
    if (!this.selectedAddress || !this.selectedAddress.id) {
      promptAction.showToast({ message: '请先选择收货地址' });
      this.navigateToAddressSelection();
      return;
    }

    this.isPaying = true;

    try {
      await this.simulatePayment();
    } catch (error) {
      console.error('支付失败:', error);
      this.isPaying = false;
    }
  }

  private async simulatePayment(): Promise<void> {
    try {
      await new Promise<void>((resolve: () => void) => {
        setTimeout(resolve, 1500);
      });

      const payMethodName: string = this.selectedPayMethod === 'wechat' ? '微信支付' : '支付宝';

      const success: boolean = await OrderManager.updateOrderStatus(this.currentOrderId, 1);

      if (success) {
        promptAction.showToast({ message: `${payMethodName}支付成功！` });

        setTimeout(() => {
          router.replaceUrl({
            url: 'pages/OrderPage',
            params: { status: 1 }
          });
        }, 800);
      } else {
        promptAction.showToast({ message: '支付失败，请重试' });
        this.isPaying = false;
      }
    } catch (error) {
      console.error('支付失败:', error);

      promptAction.showToast({ message: '支付已取消，订单保留在待付款中' });

      setTimeout(() => {
        router.replaceUrl({
          url: 'pages/OrderPage',
          params: { status: 0 }
        });
      }, 500);

      this.isPaying = false;
    }
  }
}
