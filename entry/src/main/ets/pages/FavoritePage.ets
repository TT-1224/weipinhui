import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import FavoriteManager from '../manager/FavoriteManager'
import type { FavoriteItem } from '../manager/FavoriteManager'
import HttpUtil from '../utils/HttpUtil'
import ImageUtil from '../utils/ImageUtil'

interface GoodsInfo {
  id: number
  name: string
  price: number
  originPrice: number
  cover: string
  brand: string
}

@Entry
@ComponentV2
struct FavoritePage {
  @Local favoriteList: FavoriteItem[] = []
  @Local goodsMap: Map<number, GoodsInfo> = new Map()
  @Local isLoading: boolean = false
  @Local totalCount: number = 0
  
  // ✅ 新增：防重入标志（防止循环刷新导致页面闪烁）
  @Local isRefreshing: boolean = false

  aboutToAppear() {
    this.loadFavoriteData()
    this.subscribeToManager()
  }

  aboutToDisappear() {
    FavoriteManager.unsubscribe(this.onDataChange)
  }

  private onDataChange: () => void = () => {
    // ✅ 关键修复：防重入检查
    // 如果正在从服务器加载数据，跳过本次通知避免循环
    if (this.isRefreshing) {
      console.info('⏭️ [FavoritePage] 正在加载中，跳过通知');
      return;
    }
    
    // ✅ 使用增量更新而不是全量刷新
    this.incrementalUpdateFromCache();
  }

  private subscribeToManager(): void {
    FavoriteManager.subscribe(this.onDataChange)
  }

  /**
   * ✅ 新增：从本地缓存增量更新（不请求服务器）
   * 用于响应 FavoriteManager 的本地状态变化通知
   */
  private incrementalUpdateFromCache(): void {
    console.info('📝 [FavoritePage] 增量更新 - 从缓存读取数据');
    
    // 直接读取本地缓存（不触发网络请求）
    this.favoriteList = FavoriteManager.getFavoriteList();
    this.totalCount = FavoriteManager.getFavoriteCount();
    
    // 如果列表为空，直接显示空视图
    if (this.favoriteList.length === 0) {
      this.goodsMap = new Map();
      return;
    }
    
    // 增量更新商品详情（只加载新增的商品）
    this.incrementalLoadGoodsDetails();
  }
  
  /**
   * ✅ 新增：增量加载商品详情（只加载缺失的）
   */
  private async incrementalLoadGoodsDetails(): Promise<void> {
    const missingGoodsIds: number[] = [];
    
    // 找出需要加载的商品（不在当前goodsMap中的）
    for (const item of this.favoriteList) {
      if (!this.goodsMap.has(item.goodsId)) {
        missingGoodsIds.push(item.goodsId);
      }
    }
    
    // 如果没有缺失的商品，无需加载
    if (missingGoodsIds.length === 0) {
      return;
    }
    
    console.info('📦 [FavoritePage] 增量加载商品详情, 数量:', missingGoodsIds.length);
    
    try {
      const newGoodsMap: Map<number, GoodsInfo> = new Map(this.goodsMap); // 复制现有数据
      
      for (const goodsId of missingGoodsIds) {
        try {
          const goods: GoodsInfo = await HttpUtil.get<GoodsInfo>(`/api/goods/detail/${goodsId}`);
          newGoodsMap.set(goodsId, goods);
        } catch (e) {
          console.error('❌ 加载商品详情失败, goodsId:', goodsId, e);
        }
      }
      
      this.goodsMap = newGoodsMap;
      console.info('✅ [FavoritePage] 增量加载完成');
    } catch (e) {
      console.error('❌ [FavoritePage] 增量加载失败:', e);
    }
  }

  /**
   * 全量加载（首次进入或下拉刷新时使用）
   * 会请求服务器获取最新数据
   */
  private async loadFavoriteData(): Promise<void> {
    // ✅ 防重入：如果正在加载，不再重复执行
    if (this.isRefreshing) {
      console.info('⏭️ [FavoritePage] 已在加载中，跳过重复请求');
      return;
    }
    
    this.isRefreshing = true;
    this.isLoading = true;
    
    try {
      console.info('🔄 [FavoritePage] 开始全量加载收藏数据...');
      
      // 刷新收藏数据（会触发网络请求）
      await FavoriteManager.refreshFavoriteData();
      
      // 获取最新数据到本地变量
      this.favoriteList = FavoriteManager.getFavoriteList();
      this.totalCount = FavoriteManager.getFavoriteCount();
      
      // 加载商品详情
      if (this.favoriteList.length > 0) {
        await this.fullLoadGoodsDetails();
      } else {
        this.goodsMap = new Map();
      }
      
      console.info('✅ [FavoritePage] 收藏数据加载完成, 数量:', this.totalCount);
    } catch (e) {
      console.error('❌ [FavoritePage] 加载收藏数据失败:', e);
      promptAction.showToast({ message: '加载失败' });
    } finally {
      this.isLoading = false;
      this.isRefreshing = false; // ✅ 重置防重入标志
    }
  }

  /**
   * 全量加载所有商品详情
   */
  private async fullLoadGoodsDetails(): Promise<void> {
    const goodsIds: number[] = this.favoriteList.map((item: FavoriteItem): number => item.goodsId);
    
    try {
      const newGoodsMap: Map<number, GoodsInfo> = new Map();
      
      for (const goodsId of goodsIds) {
        try {
          const goods: GoodsInfo = await HttpUtil.get<GoodsInfo>(`/api/goods/detail/${goodsId}`);
          newGoodsMap.set(goodsId, goods);
        } catch (e) {
          console.error('加载商品详情失败, goodsId:', goodsId, e);
        }
      }
      
      this.goodsMap = newGoodsMap;
    } catch (e) {
      console.error('批量加载商品详情失败:', e);
    }
  }

  private async removeFavorite(goodsId: number): Promise<void> {
    try {
      const success: boolean = await FavoriteManager.removeFavorite(goodsId)
      
      if (success) {
        // 从本地列表移除
        this.favoriteList = this.favoriteList.filter((item: FavoriteItem) => item.goodsId !== goodsId)
        this.goodsMap.delete(goodsId)
        this.totalCount--
        
        promptAction.showToast({ message: '已取消收藏' })
      }
    } catch (e) {
      console.error('取消收藏失败:', e)
    }
  }

  build() {
    Column() {
      // 导航栏
      this.buildNavigationBar()

      if (this.isLoading) {
        this.buildLoadingView()
      } else if (this.favoriteList.length === 0) {
        this.buildEmptyView()
      } else {
        this.buildFavoriteListView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F7')
  }

  @Builder
  buildNavigationBar() {
    Row() {
      SymbolGlyph($r('sys.symbol.chevron_left'))
        .width(24)
        .height(24)
        .fontColor(['#333333', '#FFFFFF'])
        .onClick(() => {
          router.back()
        })

      Text('我的收藏')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Text(`共${this.totalCount}件`)
        .fontSize(14)
        .fontColor('#666666')
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  buildLoadingView() {
    Column() {
      LoadingProgress()
        .color('#FF2D55')
        .width(40)
        .height(40)
      Text('加载中...')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 12 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildEmptyView() {
    Column() {
      Text('❤️')
        .fontSize(60)
      Text('暂无收藏商品')
        .fontSize(16)
        .fontColor('#999999')
        .margin({ top: 20 })
      Text('去逛逛，发现心仪好物吧~')
        .fontSize(13)
        .fontColor('#BBBBBB')
        .margin({ top: 8 })

      Button('去逛逛')
        .width('60%')
        .height(44)
        .fontSize(15)
        .fontColor('#FFFFFF')
        .backgroundColor('#FF2D55')
        .borderRadius(22)
        .margin({ top: 30 })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/Shop'
          })
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildFavoriteListView() {
    List({ space: 12 }) {
      ForEach(this.favoriteList, (item: FavoriteItem) => {
        ListItem() {
          this.buildFavoriteCard(item)
        }
      })
    }
    .width('100%')
    .layoutWeight(1)
    .padding(16)
    .alignListItem(ListItemAlign.Start)
  }

  @Builder
  buildFavoriteCard(item: FavoriteItem) {
    Column() {
      if (this.getGoodsInfo(item.goodsId)) {
        // ✅ 修复：使用ImageUtil转换cover字段为正确的资源路径
        // 后端返回的cover是'man1.jpg'格式，需要转换为实际资源
        Image(ImageUtil.getGoodsImage(this.getGoodsInfo(item.goodsId)!.cover))
          .width('100%')
          .height(200)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: 12, topRight: 12 })
          .onClick(() => {
            this.navigateToGoodsDetail(this.getGoodsInfo(item.goodsId)!.id)
          })

        // 商品信息
        Column() {
          Text(this.getGoodsInfo(item.goodsId)!.name)
            .fontSize(14)
            .fontColor('#333333')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')

          Row() {
            Text(`¥${this.getGoodsInfo(item.goodsId)!.price.toFixed(2)}`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF2D55')

            if (this.getGoodsInfo(item.goodsId)!.originPrice && this.getGoodsInfo(item.goodsId)!.originPrice > this.getGoodsInfo(item.goodsId)!.price) {
              Text(`¥${this.getGoodsInfo(item.goodsId)!.originPrice.toFixed(2)}`)
                .fontSize(12)
                .fontColor('#999999')
                .decoration({ type: TextDecorationType.LineThrough, color: '#999999' })
                .margin({ left: 8 })
            }

            Blank()

            // 删除按钮
            SymbolGlyph($r('sys.symbol.trash'))
              .width(20)
              .height(20)
              .fontColor(['#FF3B30', '#FFFFFF'])
              .onClick(() => {
                this.confirmRemove(item.goodsId)
              })
          }
          .width('100%')
          .margin({ top: 12 })
        }
        .width('100%')
        .padding(12)
        .alignItems(HorizontalAlign.Start)
      } else {
        // 商品信息加载中/已下架
        Column() {
          Text('商品信息加载中...')
            .fontSize(14)
            .fontColor('#999999')
          
          Button('移除')
            .type(ButtonType.Normal)
            .fontSize(13)
            .fontColor('#FF3B30')
            .backgroundColor('#F5F5F5')
            .height(32)
            .margin({ top: 12 })
            .onClick(() => {
              this.confirmRemove(item.goodsId)
            })
        }
        .width('100%')
        .height(250)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#FAFAFA')
        .borderRadius(12)
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: '#12000000',
      offsetX: 0,
      offsetY: 2
    })
  }

  /**
   * ✅ 新增：获取商品信息的辅助方法（避免在@Builder中使用const）
   */
  private getGoodsInfo(goodsId: number): GoodsInfo | undefined {
    return this.goodsMap.get(goodsId);
  }

  private navigateToGoodsDetail(goodsId: number): void {
    router.pushUrl({
      url: 'pages/CardDetailPage',
      params: {
        cardId: goodsId.toString()
      }
    })
  }

  private confirmRemove(goodsId: number): void {
    promptAction.showDialog({
      title: '确认删除',
      message: '确定要从收藏夹移除该商品吗？',
      buttons: [
        { text: '取消', color: '#8E8E93' },
        { text: '确定', color: '#FF3B30' }
      ]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        this.removeFavorite(goodsId)
      }
    })
  }
}
