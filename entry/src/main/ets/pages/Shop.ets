import CommonConstants from '../constants/CommonConstants'
import { CardInfo } from '../viewmodel/DataModels';
import HttpUtil from '../utils/HttpUtil';
import ImageUtil from '../utils/ImageUtil';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import CartManager from '../manager/CartManager';

interface CartItem {
  id: number;
  userId: number;
  goodsId: number;
  quantity: number;
  checked: number;
  selectedProperColor: string;
  selectedProperSize: string;
  goods: GoodsInfo | null;
}

interface GoodsInfo {
  id: number;
  cardId: string;
  name: string;
  price: number;
  cover: Resource | string;
  subTitle: string;
  properColor?: string;
  properSize?: string;
  brand?: string;
}

interface CartListResponse {
  list: CartItem[];
  totalCount: number;
  totalAmount: number;
}

interface CardDetailPageParams {
  cardId: string;
  goodsId?: string;
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

interface CartUpdateBody {
  id: number
  quantity: number
}

@Entry
@Component
export default struct Shop {
  @State cartList: CartItem[] = [];
  @State selectedCardIds: string[] = [];
  @State shopNums: number = 0;
  @State allMoney: number = 0;
  @State isLoading: boolean = true;
  @State isAllSelected: boolean = false;
  @StorageLink('cartUpdateTime') @Watch('onCartUpdated') cartUpdateTime: number = 0;
  @StorageLink('cartCount') @Watch('onCartCountUpdated') cartCount: number = 0;

  aboutToAppear() {
    this.loadCartData();
    CartManager.subscribe(() => {
      this.onCartDataChanged();
    });
  }

  aboutToDisappear() {
    CartManager.unsubscribe(() => {
      this.onCartDataChanged();
    });
  }

  onCartDataChanged(): void {
    this.shopNums = CartManager.getCartCount();
    this.allMoney = CartManager.getTotalAmount();
  }

  onCartCountUpdated(): void {
    this.shopNums = this.cartCount;
  }

  onCartUpdated(): void {
    if (this.cartUpdateTime > 0) {
      this.loadCartData();
    }
  }

  async loadCartData() {
    this.isLoading = true;
    try {
      const rawData: CartListResponse = await HttpUtil.get<CartListResponse>('/api/cart/list');
      const rawList: object[] = rawData.list || [];

      const mappedList: CartItem[] = rawList.map((raw: object): CartItem => {
        const obj: Record<string, Object> = raw as Record<string, Object>;

        const colorVal: Object | undefined = obj['selectedProperColor'] || obj['selected_proper_color'] || obj['properColor'] || obj['proper_color'];
        const sizeVal: Object | undefined = obj['selectedProperSize'] || obj['selected_proper_size'] || obj['properSize'] || obj['proper_size'];

        let goodsInfo: GoodsInfo | null = null;
        if (obj['goods']) {
          const g: Record<string, Object> = obj['goods'] as Record<string, Object>;
          const gColor: Object | undefined = g['properColor'] || g['proper_color'];
          const gSize: Object | undefined = g['properSize'] || g['proper_size'];
          const gBrand: Object | undefined = g['brand'] || g['brandName'] || g['brand_name'];
          const goodsInfoData: GoodsInfo = {
            id: g['id'] ? Number(g['id']) : 0,
            cardId: g['cardId'] ? String(g['cardId']) : '',
            name: g['name'] ? String(g['name']) : '商品名称',
            price: g['price'] ? Number(g['price']) : 0,
            cover: g['cover'] ? (typeof g['cover'] === 'string' ? String(g['cover']) : $r('app.media.card')) : $r('app.media.card'),
            subTitle: g['subTitle'] ? String(g['subTitle']) : '',
            properColor: gColor ? String(gColor) : '',
            properSize: gSize ? String(gSize) : '',
            brand: gBrand ? String(gBrand) : ''
          };
          goodsInfo = goodsInfoData;
        }

        const cartItemData: CartItem = {
          id: obj['id'] ? Number(obj['id']) : 0,
          userId: obj['userId'] ? Number(obj['userId']) : 0,
          goodsId: obj['goodsId'] ? Number(obj['goodsId']) : 0,
          quantity: obj['quantity'] ? Number(obj['quantity']) : 1,
          checked: obj['checked'] ? Number(obj['checked']) : 0,
          selectedProperColor: colorVal ? String(colorVal) : '',
          selectedProperSize: sizeVal ? String(sizeVal) : '',
          goods: goodsInfo
        };
        return cartItemData;
      });

      this.cartList = mappedList;
      this.shopNums = rawData.totalCount || 0;
      this.allMoney = rawData.totalAmount || 0;

      this.selectedCardIds = this.cartList
        .filter((item: CartItem) => item.checked === 1)
        .map((item: CartItem) => String(item.id));

      this.isAllSelected = this.cartList.length > 0 &&
        this.selectedCardIds.length === this.cartList.length;
    } catch (error) {
      console.error('加载购物车失败:', error);
      this.cartList = [];
      this.shopNums = 0;
      this.allMoney = 0;
    } finally {
      this.isLoading = false;
    }
  }

  private isSelected(id: number): boolean {
    return this.selectedCardIds.indexOf(String(id)) > -1;
  }

  private async updateSelectedCard(id: number, selected: boolean): Promise<void> {
    const success: boolean = await CartManager.updateCartItem(String(id), selected);

    if (success) {
      const index: number = this.selectedCardIds.indexOf(String(id));
      if (selected && index < 0) {
        this.selectedCardIds = [...this.selectedCardIds, String(id)];
      } else if (!selected && index > -1) {
        this.selectedCardIds.splice(index, 1);
        this.selectedCardIds = [...this.selectedCardIds];
      }
      this.updateAllSelectedStatus();
      this.recalculateTotal();
    }
  }

  private async toggleSelectAll(): Promise<void> {
    if (this.isAllSelected) {
      for (let i: number = 0; i < this.cartList.length; i++) {
        await CartManager.updateCartItem(String(this.cartList[i].id), false);
      }
      this.selectedCardIds = [];
    } else {
      const newIds: string[] = [];
      for (let i: number = 0; i < this.cartList.length; i++) {
        await CartManager.updateCartItem(String(this.cartList[i].id), true);
        newIds.push(String(this.cartList[i].id));
      }
      this.selectedCardIds = newIds;
    }
    this.isAllSelected = !this.isAllSelected;
    this.recalculateTotal();
  }

  private updateAllSelectedStatus(): void {
    this.isAllSelected = this.cartList.length > 0 &&
      this.selectedCardIds.length === this.cartList.length;
  }

  private recalculateTotal(): void {
    let total: number = 0;
    let count: number = 0;
    for (let i: number = 0; i < this.cartList.length; i++) {
      const item: CartItem = this.cartList[i];
      if (item.checked === 1 && item.goods) {
        total += item.goods.price * item.quantity;
        count += item.quantity;
      }
    }
    this.allMoney = total;
    this.shopNums = count;
  }

  private async updateQuantity(cartItem: CartItem, delta: number): Promise<void> {
    const newQty: number = cartItem.quantity + delta;
    if (newQty < 1 || newQty > 99) {
      return;
    }
    try {
      const body: CartUpdateBody = { id: cartItem.id, quantity: newQty };
      await HttpUtil.put<object>('/api/cart/update', body);
      cartItem.quantity = newQty;
      this.recalculateTotal();
    } catch (e) {
      promptAction.showToast({ message: '更新数量失败' });
    }
  }

  private async removeCartItem(id: number): Promise<void> {
    AlertDialog.show({
      title: '确认删除',
      message: '确定要从购物车中移除该商品吗？',
      primaryButton: {
        value: '删除',
        fontColor: '#FF3B30',
        action: async () => {
          const success: boolean = await CartManager.removeCartItem(String(id));
          if (success) {
            promptAction.showToast({ message: '已删除' });
            await this.loadCartData();
          }
        }
      },
      secondaryButton: {
        value: '再想想',
        action: () => {}
      }
    });
  }

  private navigateToCardDetail(goods: GoodsInfo): void {
    if (!goods) {
      return;
    }
    router.pushUrl({
      url: 'pages/components/CardDetailPage',
      params: {
        cardId: goods.cardId,
        goodsId: String(goods.id)
      } as CardDetailPageParams
    });
  }

  build() {
    Column() {
      if (this.isLoading) {
        this.buildLoadingView()
      } else if (this.cartList.length === 0) {
        this.buildEmptyView()
      } else {
        this.buildContentView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F7')
  }

  @Builder
  buildLoadingView() {
    Column() {
      ForEach([1, 2, 3], (_: number) => {
        Row() {
          Row()
            .width(22)
            .height(22)
            .borderRadius(11)
            .backgroundColor('#EEEEEE')

          Row()
            .width(90)
            .height(90)
            .borderRadius(12)
            .backgroundColor('#EEEEEE')

          Column() {
            Row()
              .width('70%')
              .height(16)
              .borderRadius(4)
              .backgroundColor('#EEEEEE')
              .margin({ bottom: 10 })

            Row() {
              Row().width(50).height(14).borderRadius(4).backgroundColor('#EEEEEE')
              Blank()
              Row().width(40).height(14).borderRadius(4).backgroundColor('#EEEEEE')
            }
            .width('100%')

            Row()
              .width('40%')
              .height(12)
              .borderRadius(4)
              .backgroundColor('#EEEEEE')
              .margin({ top: 8 })
          }
          .layoutWeight(1)
          .margin({ left: 12 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding(16)
        .margin({ bottom: 12 })
        .backgroundColor(Color.White)
        .borderRadius(14)
      }, (_: number, index: number): string => 'skel_' + String(index))
    }
    .layoutWeight(1)
    .padding({ top: 60, left: 16, right: 16 })
  }

  @Builder
  buildEmptyView() {
    Column() {
      Column() {
        SymbolGlyph($r('sys.symbol.cart'))
          .width(80)
          .height(80)
          .fontColor(['#CCCCCC'])

        Text('购物车是空的')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .margin({ top: 20 })

        Text('快去挑选心仪的商品吧~')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 8 })

        Button('去逛逛', { type: ButtonType.Capsule })
          .width(160)
          .height(42)
          .fontSize(16)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#FF2D55')
          .margin({ top: 32 })
          .onClick(() => {
            router.replaceUrl({ url: 'pages/Index' });
          })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildContentView() {
    Column() {
      Row() {
        Text('购物车')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1C1C1E')

        Text(this.cartList.length + '件商品')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ left: 6 })
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .backgroundColor('#FFFFFF')

      List({ space: 8, initialIndex: 0 }) {
        ForEach(this.cartList, (cartItem: CartItem, index: number) => {
          ListItem() {
            this.buildCartItem(cartItem, index)
          }
        }, (cartItem: CartItem, index: number): string => String(cartItem.id))
      }
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .padding({ left: 10, right: 10, top: 6 })
      .layoutWeight(1)

      this.buildBottomBar()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildCartItem(cartItem: CartItem, _index: number) {
    Row() {
      Stack({ alignContent: Alignment.Center }) {
        if (this.isSelected(cartItem.id)) {
          Row()
            .width(20)
            .height(20)
            .borderRadius(10)
            .backgroundColor('#FF2D55')

          SymbolGlyph($r('sys.symbol.checkmark'))
            .width(12)
            .height(12)
            .fontColor(['#FFFFFF'])
        } else {
          Row()
            .width(20)
            .height(20)
            .borderRadius(10)
            .borderWidth(1.8)
            .borderColor('#CCCCCC')
        }
      }
      .onClick(async () => {
        await this.updateSelectedCard(cartItem.id, !this.isSelected(cartItem.id))
      })

      Image(cartItem.goods && cartItem.goods.cover ? ImageUtil.getGoodsImage(cartItem.goods.cover) : $r('app.media.card'))
        .objectFit(ImageFit.Cover)
        .width(85)
        .height(85)
        .borderRadius(10)
        .margin({ left: 10 })
        .onClick(() => {
          if (cartItem.goods) {
            this.navigateToCardDetail(cartItem.goods as GoodsInfo);
          }
        })

      Column() {
        Text(cartItem.goods ? cartItem.goods.name : '商品名称')
          .fontSize(13)
          .fontColor('#1C1C1E')
          .fontWeight(FontWeight.Medium)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .onClick(() => {
            if (cartItem.goods) {
              this.navigateToCardDetail(cartItem.goods as GoodsInfo);
            }
          })

        if (cartItem.selectedProperSize || cartItem.selectedProperColor) {
          Text((cartItem.selectedProperColor ? cartItem.selectedProperColor : '') +
            (cartItem.selectedProperSize ? ' ' + cartItem.selectedProperSize : ''))
            .fontSize(11)
            .fontColor('#999999')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 6 })
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4)
            .backgroundColor('#F5F5F7')
        }

        Row() {
          Text('¥' + (cartItem.goods ? cartItem.goods.price.toFixed(2) : '0.00'))
            .fontSize(15)
            .fontColor('#FF2D55')
            .fontWeight(FontWeight.Bold)

          Blank()

          Text('×' + String(cartItem.quantity))
            .fontSize(14)
            .fontColor('#888888')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .margin({ top: 8 })
        .alignItems(VerticalAlign.Center)
      }
      .layoutWeight(1)
      .margin({ left: 10 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 8, color: '#00000008', offsetY: 2 })
  }

  @Builder
  buildBottomBar() {
    Column() {
      Divider().color('#F0F0F0').strokeWidth(0.5)

      Row() {
        Row() {
          Row()
            .width(20)
            .height(20)
            .borderRadius(10)
            .borderWidth(2)
            .borderColor(this.isAllSelected ? Color.Transparent : '#DDDDDD')
            .backgroundColor(this.isAllSelected ? '#FF2D55' : Color.Transparent)
            .onClick(() => {
              this.toggleSelectAll();
            })

          if (this.isAllSelected) {
            SymbolGlyph($r('sys.symbol.checkmark'))
              .width(12)
              .height(12)
              .fontColor(['#FFFFFF'])
              .position({ x: 4, y: 4 })
          }

          Text('全选')
            .fontSize(13)
            .fontColor('#333333')
            .margin({ left: 6 })
        }
        .onClick(() => {
          this.toggleSelectAll();
        })

        Blank()

        Row() {
          Column() {
            Text('合计:')
              .fontSize(12)
              .fontColor('#666666')

            Text('¥' + this.allMoney.toFixed(2))
              .fontSize(17)
              .fontColor('#FF2D55')
              .fontWeight(FontWeight.Bold)
          }
          .alignItems(HorizontalAlign.End)

          Text('已选' + this.shopNums + '件')
            .fontSize(11)
            .fontColor('#999999')
            .margin({ left: 8, top: 4 })
        }

        Button('结算(' + this.shopNums + ')', { type: ButtonType.Capsule })
          .height(38)
          .padding({ left: 18, right: 18 })
          .fontSize(14)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.shopNums > 0 ? '#FF2D55' : '#DDDDDD')
          .enabled(this.shopNums > 0)
          .margin({ left: 10 })
          .onClick(() => {
            this.handleCheckout();
          })
      }
      .width('100%')
      .padding({ left: 12, right: 8, top: 6, bottom: 6 })
    }
    .backgroundColor('#FFFFFF')
    .layoutWeight(0)
  }

  private handleCheckout(): void {
    if (this.shopNums === 0) {
      promptAction.showToast({ message: '请选择商品' });
      return;
    }

    const selectedItems: CartItem[] = this.cartList.filter((item: CartItem) => item.checked === 1);
    if (selectedItems.length === 0) {
      promptAction.showToast({ message: '请选择商品' });
      return;
    }

    AlertDialog.show({
      title: '确认订单',
      message: '您一共选购了 ' + this.shopNums + ' 件商品，总计 ¥' + Number(this.allMoney.toFixed(2)) + '。确定提交订单吗？',
      primaryButton: {
        value: '确定提交',
        fontColor: '#FF2D55',
        action: () => {
          const orderItems: ConfirmOrderItem[] = selectedItems.map((item: CartItem): ConfirmOrderItem => {
            const orderItem: ConfirmOrderItem = {
              goodsId: item.goodsId,
              goodsName: item.goods ? item.goods.name : '商品名称',
              goodsImage: item.goods && item.goods.cover ? item.goods.cover : $r('app.media.card'),
              goodsPrice: item.goods ? item.goods.price : 0,
              quantity: item.quantity,
              properColor: item.selectedProperColor || '',
              properSize: item.selectedProperSize || ''
            };
            return orderItem;
          });

          router.pushUrl({
            url: 'pages/ConfirmOrderPage',
            params: {
              type: 'cart',
              cartIds: selectedItems.map((item: CartItem): number => item.id),
              totalAmount: this.allMoney,
              items: orderItems
            }
          });
        }
      },
      secondaryButton: {
        value: '继续逛逛',
        action: () => {}
      }
    });
  }
}
