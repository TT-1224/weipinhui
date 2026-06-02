import router from '@ohos.router';
import HttpUtil from '../../utils/HttpUtil';
import ImageUtil from '../../utils/ImageUtil';
import promptAction from '@ohos.promptAction';
import CommonConstants from '../../constants/CommonConstants';
import { cardInfo1, cardInfo2, cardInfo3, cardInfo4, cardInfo5, cardInfo6, cardInfo7, cardInfo8, cardInfo9, cardInfo10, cardInfo11 } from '../../datasource/MockData';
import CartManager from '../../manager/CartManager';
import FavoriteManager from '../../manager/FavoriteManager';

interface GoodsDetailResponse {
  id: number;
  cardId: string;
  name: string;
  title: string;
  subTitle: string;
  brand: string;
  price: number;
  originPrice: number;
  marketPrice: number;
  cover: string;
  images: string;
  description: string;
  properColor: string;
  properSize: string;
  stock: number;
  soldCount: number;
  categoryId: number;
}

interface RouterParams {
  goodsId?: string;
  cardId?: string;
}

interface AddCartParams {
  goodsId: number;
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
struct CardDetailPage {
  @State goodsId: number = 0;
  @State goods: GoodsDetailResponse | null = null;
  @State isLoading: boolean = true;
  @State hasError: boolean = false;

  @State selectedColor: string = '';
  @State selectedSize: string = '';
  @State quantity: number = 1;
  @State isAddingCart: boolean = false;
  // 收藏状态（支持三个场景的核心变量）
  @State isFavorited: boolean = false;

  aboutToAppear(): void {
    const params: RouterParams = router.getParams() as RouterParams;
    const rawGoodsId: string = params && params.goodsId ? params.goodsId : '';
    const rawCardId: string = params && params.cardId ? params.cardId : '';

    if (rawGoodsId) {
      this.goodsId = parseInt(rawGoodsId, 10);
    } else if (rawCardId) {
      this.goodsId = this.findMockIndexByCardId(rawCardId);
      
      // ✅ 修复：如果cardId解析失败，先设为-1，等loadMockGoods后再修正
      if (this.goodsId < 0) {
        console.warn('⚠️ [CardDetailPage] cardId未找到:', rawCardId, '将使用默认值0');
        this.goodsId = 0; // 暂时使用0，loadMockGoods后会根据实际情况调整
      }
    }

    console.info('CardDetailPage - goodsId:', this.goodsId, 'rawGoodsId:', rawGoodsId, 'rawCardId:', rawCardId);

    // 初始化收藏状态并订阅变化
    this.initFavoriteStatus();
    
    this.loadMockGoods();
  }

  /**
   
   * - 从服务器查询当前商品的收藏状态
   * - 订阅FavoriteManager的状态变化（实现双向同步）
   */
  private async initFavoriteStatus(): Promise<void> {
    if (this.goodsId > 0) {
      try {
        // 查询当前商品是否已收藏
        this.isFavorited = await FavoriteManager.checkFavorited(this.goodsId);
        console.info('✅ [CardDetailPage] 初始化收藏状态 - goodsId:', this.goodsId, 'isFavorited:', this.isFavorited);
      } catch (e) {
        console.error('❌ [CardDetailPage] 初始化收藏状态失败:', e);
      }
      
      // 订阅FavoriteManager状态变化（实现双向同步）
      FavoriteManager.subscribe(() => {
        const newStatus: boolean = FavoriteManager.isFavorited(this.goodsId);
        if (this.isFavorited !== newStatus) {
          this.isFavorited = newStatus;
          console.info('✅ [CardDetailPage] 收藏状态更新 - goodsId:', this.goodsId, '新状态:', newStatus);
        }
      });
    }
  }

  private findMockIndexByCardId(cardId: string): number {
    const mockData = [
      '5bdbe6b0-c34a-4c35-8c8f-19be0ef8104b',
      'c8761280-4d67-4783-ab69-1c176b75fde0',
      '72464fc9-9448-43f3-9caf-2a3a6a2a07ed',
      '58fb40d9-4e36-4ff1-a1b8-7544b0334395',
      '9c4b64d4-62c8-48e4-b685-97e8e5f50b21',
      '5b4d9098-0011-4383-9d5c-91f67ddfd83c',
      '7b6fa990-e114-4361-a9ff-00d5a93bed07',
      '8794cff1-094a-4b6d-8d04-d6238b806e77',
      '8531161a-a2f9-4c06-8c94-18fd7bb16078',
      '26b2a836-b826-4cb3-b247-119873ef4076',
      '34f7f253-d136-4b88-87d7-724b5ec4d23c'
    ];
    return mockData.indexOf(cardId);
  }

  async loadGoodsDetail(): Promise<void> {
    if (this.goodsId <= 0) {
      this.loadMockGoods();
      this.isLoading = false;
      return;
    }

    this.isLoading = true;
    try {
      const data: GoodsDetailResponse = await HttpUtil.get<GoodsDetailResponse>('/api/goods/detail/' + this.goodsId);
      this.goods = data;
      if (data.properColor) {
        this.selectedColor = data.properColor;
      }
      if (data.properSize) {
        this.selectedSize = data.properSize;
      }
    } catch (error) {
      console.error('加载商品详情失败，使用本地数据:', error);
      this.loadMockGoods();
    } finally {
      this.isLoading = false;
    }
  }

  private loadMockGoods(): void {
    const mockDataList = [cardInfo1, cardInfo2, cardInfo3, cardInfo4, cardInfo5, cardInfo6, cardInfo7, cardInfo8, cardInfo9, cardInfo10, cardInfo11];
    
    // ✅ 修复：确保currentIndex在有效范围内
    let currentIndex: number = this.goodsId;
    if (currentIndex < 0 || currentIndex >= mockDataList.length) {
      currentIndex = 0; // 默认使用第一个商品
      console.warn('⚠️ [CardDetailPage] goodsId超出范围:', this.goodsId, '修正为0');
    }
    
    console.info('loadMockGoods - currentIndex:', currentIndex, 'goodsId:', this.goodsId);
    
    const currentCardInfo = mockDataList[currentIndex];
    console.info('loadMockGoods - currentCardInfo:', currentCardInfo.cardId, currentCardInfo.desc);

    const mockName: string = typeof currentCardInfo.desc === 'string' ? currentCardInfo.desc : '品质保证，正品行货';
    const mockPrice: number = currentCardInfo.price || 134;
    const mockProper: string = typeof currentCardInfo.proper === 'string' ? currentCardInfo.proper : '黑色';
    const mockSize: string = typeof currentCardInfo.size === 'string' ? currentCardInfo.size : String(currentCardInfo.size) || 'M';
    const mockBrand: string = currentCardInfo.brand || '唯品会';

    let coverName: string = '';
    if (currentIndex === 0) coverName = 'man1';
    else if (currentIndex === 1) coverName = 'man2';
    else if (currentIndex === 2) coverName = 'man3';
    else if (currentIndex === 3) coverName = 'man4';
    else if (currentIndex === 4) coverName = 'man5';
    else if (currentIndex === 5) coverName = 'man6';
    else if (currentIndex === 6) coverName = 'man7';
    else if (currentIndex === 7) coverName = 'man8';
    else if (currentIndex === 8) coverName = 'man9';
    else if (currentIndex === 9) coverName = 'man10';
    else if (currentIndex === 10) coverName = 'man11';

    console.info('loadMockGoods - coverName:', coverName, 'mockName:', mockName);

    const mock: GoodsDetailResponse = {
      id: currentIndex + 1,
      cardId: currentCardInfo.cardId,
      name: mockName,
      title: '',
      subTitle: '',
      brand: mockBrand,
      price: mockPrice,
      originPrice: Math.round(mockPrice * 1.3),
      marketPrice: Math.round(mockPrice * 1.5),
      cover: coverName,
      images: coverName,
      description: '【品质保障】严选优质商品，正品行货，支持7天无理由退换。商品经过严格质检，确保每一件都符合高品质标准。',
      properColor: mockProper,
      properSize: mockSize,
      stock: 99,
      soldCount: 1280,
      categoryId: 1
    };
    this.goods = mock;
    
    // ✅ 关键修复：同步更新goodsId为实际商品ID
    // 原因：mock对象的id是 currentIndex+1，可能与传入的goodsId不一致
    // 必须使用实际赋值的goods.id，否则后续收藏等操作会失败
    if (this.goods && this.goods.id > 0) {
      const oldGoodsId: number = this.goodsId;
      this.goodsId = this.goods.id;
      
      if (oldGoodsId !== this.goodsId) {
        console.info('✅ [CardDetailPage] goodsId已修正:', oldGoodsId, '→', this.goodsId);
        
        // 如果goodsId发生了变化，需要重新初始化收藏状态
        this.initFavoriteStatus();
      }
    }
    
    this.selectedColor = mock.properColor;
    this.selectedSize = mock.properSize;
    this.isLoading = false;
  }

  private async addToCart(): Promise<void> {
    if (!this.goods) return;

    this.isAddingCart = true;
    try {
      await CartManager.addToCart({
        goodsId: this.goods.id,
        quantity: this.quantity,
        properColor: this.selectedColor,
        properSize: this.selectedSize
      });

      setTimeout(() => {
        router.back();
      }, 500);
    } catch (error) {
      console.error('加入购物车失败:', error);
    } finally {
      this.isAddingCart = false;
    }
  }

  private buyNow(): void {
    if (!this.goods) return;

    const currentStock: number = this.goods.stock || 0;
    if (this.quantity > currentStock) {
      promptAction.showToast({ message: '库存不足，当前仅剩' + currentStock + '件' });
      return;
    }

    const totalPrice: number = this.goods.price * this.quantity;

    const orderItems: ConfirmOrderItem[] = [{
      goodsId: this.goods.id,
      goodsName: this.goods.name,
      goodsImage: this.goods.cover || '',
      goodsPrice: this.goods.price,
      quantity: this.quantity,
      properColor: this.selectedColor,
      properSize: this.selectedSize
    }];

    router.pushUrl({
      url: 'pages/ConfirmOrderPage',
      params: {
        type: 'direct',
        goodsId: this.goods.id,
        quantity: this.quantity,
        properColor: this.selectedColor,
        properSize: this.selectedSize,
        totalAmount: totalPrice,
        items: orderItems
      }
    });
  }

  /**
   *   切换收藏状态（支持场景1、场景2、场景3）
   * - 调用FavoriteManager.toggleFavorite()
   * - 修复：不再手动更新isFavorited，完全由subscribe回调统一管理
   * - 避免双重更新导致的状态反转问题
   */
  private async toggleFavorite(): Promise<void> {
    if (!this.goods || this.goodsId <= 0) {
      promptAction.showToast({ message: '商品信息无效' });
      return;
    }

    try {
      // 调用toggleFavorite切换状态
      const success: boolean = await FavoriteManager.toggleFavorite(this.goodsId);
      
      if (success) {
        //  关键修复：不再手动更新 this.isFavorited！
        // 原因：FavoriteManager.toggleFavorite() 内部会：
        // 1. 更新本地缓存（favoriteGoodsIdSet）
        // 2. 调用 notifyListeners() 触发所有订阅者
        // 3. subscribe 回调会自动更新 this.isFavorited
        // 
        // 如果这里再手动执行 this.isFavorited = !this.isFavorited
        // 会导致状态被翻转两次，回到原值！
        
        console.info('✅ [CardDetailPage] 收藏操作成功 - goodsId:', this.goodsId, '等待回调更新UI');
      }
    } catch (e) {
      console.error('❌ [CardDetailPage] 切换收藏失败:', e);
    }
  }

  build() {
    Column() {
      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#999999')
          LoadingProgress()
            .width(40)
            .height(40)
            .margin({ top: 16 })
            .color('#FF2D55')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (!this.goods) {
        Column({ space: 16 }) {
          Row() {
            Image($r('app.media.back'))
              .width(20)
              .height(20)
              .onClick(() => {
                router.back()
              })
          }
          .padding(12)
          .width('100%')
          .justifyContent(FlexAlign.Start)

          Text('商品信息加载失败')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1C1C1E')

          Text('请返回后重试')
            .fontSize(14)
            .fontColor('#8E8E93')

          Button('重试', { type: ButtonType.Capsule })
            .margin({ top: 20 })
            .onClick(() => {
              this.loadGoodsDetail();
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Scroll() {
          Column() {
            this.PageTitleBuilder()
            this.ImageSectionBuilder()
            this.PriceSectionBuilder()
            this.SpecSectionBuilder()
            this.BottomActionBarBuilder()
          }
          .alignItems(HorizontalAlign.Center)
        }
        .backgroundColor('#EDF2F5')
        .padding({ left: 10, right: 10, top: 8, bottom: 8 })
        .height('100%')
        .align(Alignment.Top)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  PageTitleBuilder() {
    Row() {
      Image($r('app.media.back'))
        .width(20)
        .height(20)
        .onClick(() => {
          router.back()
        })
      Text('商品详情')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1C1C1E')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      // ：收藏按钮（爱心图标）
      // 未收藏：♡ 灰色空心
      // 已收藏：❤️ 粉色实心
      SymbolGlyph(this.isFavorited ? 
        $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'))
        .width(24)
        .height(24)
        .fontColor([this.isFavorited ? '#FF2D55' : '#8E8E93', '#FFFFFF'])
        .onClick(() => {
          this.toggleFavorite();
        })
    }
    .padding(12)
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
  }

  @Builder
  ImageSectionBuilder() {
    Image(ImageUtil.getGoodsImage(this.goods!.cover))
      .width('100%')
      .height('280vp')
      .objectFit(ImageFit.Cover)
      .borderRadius(14)
      .backgroundColor('#F5F5F5')
  }

  @Builder
  PriceSectionBuilder() {
    Column({ space: 8 }) {
      Row() {
        Text('¥' + this.goods!.price.toFixed(2))
          .fontSize(24)
          .fontColor('#FF2D55')
          .fontWeight(FontWeight.Bold)

        if (this.goods!.originPrice && this.goods!.originPrice > this.goods!.price) {
          Text('¥' + this.goods!.originPrice.toFixed(2))
            .fontSize(14)
            .fontColor('#8E8E93')
            .decoration({ type: TextDecorationType.LineThrough })
            .margin({ left: 10 })
        }

        Blank()

        Text('已售' + this.goods!.soldCount)
          .fontSize(12)
          .fontColor('#8E8E93')
      }
      .width('100%')

      Text(this.goods!.name)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1C1C1E')
        .width('100%')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (this.goods!.brand) {
        Text(this.goods!.brand)
          .fontSize(13)
          .fontColor('#FF2D55')
          .width('100%')
          .margin({ top: 4 })
      }
    }
    .padding({ left: 14, right: 14, top: 16, bottom: 12 })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .shadow({ radius: 10, color: '#12000000', offsetY: 1 })
    .width(CommonConstants.FULL_PARENT)
  }

  @Builder
  SpecSectionBuilder() {
    Column({ space: 16 }) {
      Text('颜色')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1C1C1E')
        .width('100%')

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(['黑色', '白色', '灰色', '蓝色', '红色'], (color: string) => {
          Text(color)
            .fontSize(13)
            .fontColor(this.selectedColor === color ? '#FF2D55' : '#333333')
            .backgroundColor(this.selectedColor === color ? '#FFF0F3' : '#F5F5F5')
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .borderRadius(16)
            .border({
              width: this.selectedColor === color ? 1.5 : 0.5,
              color: this.selectedColor === color ? '#FF2D55' : '#DDDDDD'
            })
            .margin({ right: 10, bottom: 8 })
            .onClick(() => {
              this.selectedColor = color;
            })
        }, (color: string) => color)
      }
      .width('100%')

      Text('尺码')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1C1C1E')
        .width('100%')
        .margin({ top: 8 })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(['XS', 'S', 'M', 'L', 'XL', 'XXL'], (size: string) => {
          Text(size)
            .fontSize(13)
            .fontColor(this.selectedSize === size ? '#FF2D55' : '#333333')
            .backgroundColor(this.selectedSize === size ? '#FFF0F3' : '#F5F5F5')
            .padding({ left: 20, right: 20, top: 8, bottom: 8 })
            .borderRadius(16)
            .border({
              width: this.selectedSize === size ? 1.5 : 0.5,
              color: this.selectedSize === size ? '#FF2D55' : '#DDDDDD'
            })
            .margin({ right: 10, bottom: 8 })
            .onClick(() => {
              this.selectedSize = size;
            })
        }, (size: string) => size)
      }
      .width('100%')

      Text('数量')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1C1C1E')
        .width('100%')
        .margin({ top: 8 })

      Row() {
        Button('-', { type: ButtonType.Capsule })
          .width(32)
          .height(32)
          .fontSize(16)
          .fontColor('#333333')
          .backgroundColor('#F5F5F5')
          .enabled(this.quantity > 1)
          .onClick(() => {
            if (this.quantity > 1) {
              this.quantity--;
            }
          })

        Text(this.quantity.toString())
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1C1C1E')
          .width(50)
          .textAlign(TextAlign.Center)

        Button('+', { type: ButtonType.Capsule })
          .width(32)
          .height(32)
          .fontSize(16)
          .fontColor('#333333')
          .backgroundColor('#F5F5F5')
          .enabled(this.quantity < (this.goods?.stock || 99))
          .onClick(() => {
            if (this.quantity < (this.goods?.stock || 99)) {
              this.quantity++;
            }
          })

        Blank()

        Text('库存 ' + (this.goods?.stock || 0))
          .fontSize(12)
          .fontColor('#8E8E93')
      }
      .width('100%')
      .height(40)

      if (this.goods!.description) {
        Text('商品详情')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1C1C1E')
          .width('100%')
          .margin({ top: 16 })

        Text(this.goods!.description)
          .fontSize(13)
          .fontColor('#666666')
          .width('100%')
          .lineHeight(20)
      }
    }
    .padding(14)
    .borderRadius(14)
    .backgroundColor(Color.White)
    .width(CommonConstants.FULL_PARENT)
  }

  @Builder
  BottomActionBarBuilder() {
    Column() {
      Row() {
        Text('总计：')
          .fontSize(14)
          .fontColor('#666666')
        Text('¥' + ((this.goods?.price || 0) * this.quantity).toFixed(2))
          .fontSize(20)
          .fontColor('#FF2D55')
          .fontWeight(FontWeight.Bold)
        Blank()
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 12 })

      Row() {
        Button('加入购物车', { type: ButtonType.Capsule })
          .height(44)
          .fontSize(15)
          .fontColor('#FF2D55')
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#FFFFFF')
          .border({ width: 1.5, color: '#FF2D55' })
          .layoutWeight(1)
          .enabled(!this.isAddingCart)
          .onClick(() => {
            this.addToCart();
          })

        Button(this.isAddingCart ? '添加中...' : '立即购买', { type: ButtonType.Capsule })
          .height(44)
          .fontSize(15)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#FF2D55')
          .layoutWeight(1)
          .margin({ left: 12 })
          .enabled(!this.isAddingCart)
          .onClick(() => {
            this.buyNow();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 8 })
    }
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .shadow({ radius: 10, color: '#12000000', offsetY: -2 })
  }
}
