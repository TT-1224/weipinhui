import router from '@ohos.router';
import HttpUtil from '../utils/HttpUtil';
import ImageUtil from '../utils/ImageUtil';
import promptAction from '@ohos.promptAction';

interface ApiGoodsItem {
  id: number;
  cardId: string;
  name: string;
  subTitle: string;
  price: number;
  originPrice: number;
  cover: string;
  soldCount: number;
}

interface GoodsCardItem {
  id: number;
  image: Resource | string;
  name: string;
  desc: string;
  price: number;
  originPrice: number;
  discount: number;
  soldCount: number;
}

interface SearchResponse {
  list: ApiGoodsItem[];
  total: number;
}

interface SortOption {
  label: string;
  value: string;
}

@Entry
@Component
struct SearchResultPage {
  @State keyword: string = '';
  @State resultList: GoodsCardItem[] = [];
  @State isLoading: boolean = true;
  @State hasError: boolean = false;
  @State sortBy: string = 'default';
  private sortOptions: SortOption[] = [
    { label: '综合', value: 'default' },
    { label: '销量', value: 'sales' },
    { label: '价格升序', value: 'price_asc' },
    { label: '价格降序', value: 'price_desc' }
  ];
// → GoodsController.searchGoods() → GoodsService.searchGoods()
//  → MySQL LIKE 模糊搜索 goods.name 和 goods.sub_title
  aboutToAppear(): void {
    const params: Record<string, Object> | undefined = router.getParams() as Record<string, Object> | undefined;
    if (params && params['keyword']) {
      this.keyword = params['keyword'] as string;
    }
    this.search();
  }

  async search(): Promise<void> {
    if (!this.keyword) {
      this.isLoading = false;
      return;
    }

    this.isLoading = true;
    this.hasError = false;

    try {
      let url: string = '/api/goods/search?keyword=' + encodeURIComponent(this.keyword);
      if (this.sortBy !== 'default') {
        url += '&sort=' + this.sortBy;
      }

      const rawData: object[] = await HttpUtil.get<object[]>(url);

      let items: ApiGoodsItem[] = [];
      if (Array.isArray(rawData) && rawData.length > 0) {
        items = rawData.map((item: object): ApiGoodsItem => {
          const obj: Record<string, Object> = item as Record<string, Object>;
          return {
            id: obj['id'] ? Number(obj['id']) : 0,
            cardId: obj['cardId'] ? String(obj['cardId']) : '',
            name: obj['name'] ? String(obj['name']) : '',
            subTitle: obj['subTitle'] ? String(obj['subTitle']) : '',
            cover: obj['cover'] ? String(obj['cover']) : '',
            price: obj['price'] ? Number(obj['price']) : 0,
            originPrice: obj['originPrice'] ? Number(obj['originPrice']) : 0,
            soldCount: obj['soldCount'] ? Number(obj['soldCount']) : 0
          };
        });
      }

      if (this.sortBy === 'price_asc') {
        items.sort((a: ApiGoodsItem, b: ApiGoodsItem): number => a.price - b.price);
      } else if (this.sortBy === 'price_desc') {
        items.sort((a: ApiGoodsItem, b: ApiGoodsItem): number => b.price - a.price);
      } else if (this.sortBy === 'sales') {
        items.sort((a: ApiGoodsItem, b: ApiGoodsItem): number => b.soldCount - a.soldCount);
      }

      this.resultList = items.map((item: ApiGoodsItem): GoodsCardItem => {
        return {
          id: item.id,
          image: item.cover || '',
          name: item.name || '',
          desc: item.subTitle || '',
          price: item.price || 0,
          originPrice: item.originPrice || 0,
          discount: item.originPrice && item.originPrice > item.price
            ? Math.round((1 - item.price / item.originPrice) * 100) : 0,
          soldCount: item.soldCount || 0
        };
      });
    } catch (error) {
      console.error('搜索失败:', error);
      this.hasError = true;
    } finally {
      this.isLoading = false;
    }
  }

  private highlightKeyword(text: string): string {
    if (!text || !this.keyword) {
      return text;
    }
    const escapedKeyword: string = this.keyword.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    const regex: RegExp = new RegExp(escapedKeyword, 'gi');
    return text.replace(regex, (match: string): string => match);
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

        Text(this.keyword)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1C1C1E')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .maxLines(1)

        Blank().width(28)
      }
      .padding({ left: 16, right: 12 })
      .width('100%')
      .height(52)
      .backgroundColor('#FFFFFF')

      Divider().color('#F0F0F0').strokeWidth(0.5)

      Row() {
        Text(`共找到 ${this.resultList.length} 个相关商品`)
          .fontSize(13)
          .fontColor('#8E8E93')

        Blank()

        ForEach(this.sortOptions, (option: SortOption) => {
          Text(option.label)
            .fontSize(13)
            .fontColor(this.sortBy === option.value ? '#FF2D55' : '#666666')
            .fontWeight(this.sortBy === option.value ? FontWeight.Medium : FontWeight.Regular)
            .margin({ left: 14 })
            .onClick(() => {
              if (this.sortBy !== option.value) {
                this.sortBy = option.value;
                this.search();
              }
            })
        }, (option: SortOption): string => option.value)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 6 })

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(36)
            .height(36)
            .color('#FF2D55')
          Text('正在搜索 "' + this.keyword + '"...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 12 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.hasError) {
        Column() {
          SymbolGlyph($r('sys.symbol.exclamationmark_triangle'))
            .width(48)
            .height(48)
            .fontColor(['#FF9500', '#FFB340'])
          Text('搜索失败，请检查网络连接')
            .fontSize(15)
            .fontColor('#8E8E93')
            .margin({ top: 12 })
          Button('重新搜索', { type: ButtonType.Capsule })
            .margin({ top: 18 })
            .height(36)
            .padding({ left: 20, right: 20 })
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#FF2D55')
            .borderRadius(18)
            .onClick(() => {
              this.search();
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.resultList.length === 0) {
        Column() {
          SymbolGlyph($r('sys.symbol.magnifyingglass'))
            .width(64)
            .height(64)
            .fontColor(['#D1D1D6', '#48484A'])

          Text('未找到 "' + this.keyword + '" 相关商品')
            .fontSize(15)
            .fontColor('#8E8E93')
            .margin({ top: 16 })
            .textAlign(TextAlign.Center)

          Text('试试换个关键词或检查拼写')
            .fontSize(13)
            .fontColor('#BBBBBB')
            .margin({ top: 6 })

          Button('返回搜索', { type: ButtonType.Capsule })
            .margin({ top: 22 })
            .height(36)
            .padding({ left: 20, right: 20 })
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#007AFF')
            .borderRadius(18)
            .onClick(() => {
              router.back();
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.resultList, (item: GoodsCardItem, index?: number) => {
              Row() {
                Image(ImageUtil.getGoodsImage(item.image))
                  .width('96vp')
                  .height('96vp')
                  .objectFit(ImageFit.Cover)
                  .borderRadius(10)
                  .backgroundColor('#F5F5F5')

                Column({ space: 6 }) {
                  Text(item.name)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#1C1C1E')
                    .width('100%')
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  if (item.desc && item.desc.length > 0) {
                    Text(item.desc)
                      .fontSize(12)
                      .fontColor('#8E8E93')
                      .width('100%')
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }

                  Row() {
                    Text('¥' + item.price.toFixed(2))
                      .fontSize(17)
                      .fontColor('#FF2D55')
                      .fontWeight(FontWeight.Bold)

                    if (item.discount > 0) {
                      Text('¥' + item.originPrice.toFixed(2))
                        .fontSize(12)
                        .fontColor('#BBBBBB')
                        .decoration({ type: TextDecorationType.LineThrough })
                        .margin({ left: 6 })
                    }

                    Blank()

                    if (item.discount > 0) {
                      Text(`${item.discount}折`)
                        .fontSize(10)
                        .fontColor('#FFFFFF')
                        .backgroundColor('#FF2D55')
                        .padding({ left: 4, right: 4, top: 1, bottom: 1 })
                        .borderRadius(3)
                    }
                  }
                  .width('100%')

                  if (item.soldCount > 0) {
                    Text(`已售${item.soldCount}件`)
                      .fontSize(11)
                      .fontColor('#AAAAAA')
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 })
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({
                radius: 4,
                color: '#0A000000',
                offsetX: 0,
                offsetY: 1
              })
              .onClick(() => {
                if (item.id > 0) {
                  router.pushUrl({
                    url: 'pages/components/CardDetailPage',
                    params: { goodsId: String(item.id) }
                  });
                }
              })
            }, (item: GoodsCardItem, index?: number): string => 'result_' + String(item.id ?? index))
          }
          .padding({ left: 12, right: 12, top: 6, bottom: 20 })
        }
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)
        .layoutWeight(1)
        .align(Alignment.Top)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F7')
  }
}
