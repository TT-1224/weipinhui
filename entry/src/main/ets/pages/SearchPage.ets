import router from '@ohos.router';
import CommonConstants from '../constants/CommonConstants';
import { HotSearchItem } from '../viewmodel/DataModels';

@Entry
@Component
struct SearchPage {
  @State searchText: string = '';
  @State historyData: string[] = [];
  @State showClearConfirm: boolean = false;
  @State guessKeywords: string[] = ['男士外套', '冬季新品', '潮流男装', '运动裤', '牛仔裤', '卫衣'];
  @State hotSearchList: HotSearchItem[] = [
    { id: 1, rank: 1, keyword: '男士牛仔裤', hot: true },
    { id: 2, rank: 2, keyword: '冬季羽绒服', hot: true },
    { id: 3, rank: 3, keyword: '休闲卫衣', hot: true },
    { id: 4, rank: 4, keyword: '潮流外套', hot: false },
    { id: 5, rank: 5, keyword: '运动裤', hot: false },
    { id: 6, rank: 6, keyword: '男装短袖', hot: false },
    { id: 7, rank: 7, keyword: '休闲长裤', hot: false },
    { id: 8, rank: 8, keyword: '针织衫', hot: false }
  ];
  private searchTimer: number = -1;

// 用户输入关键词 → 点击搜索
//     ↓
// addToHistory() → saveHistory() (AppStorage持久化)
//     ↓
// router.pushUrl('pages/SearchResultPage', { keyword })

  aboutToAppear(): void {
    this.loadHistory();
  }

  private loadHistory(): void {
    const saved: string | null = AppStorage.get('searchHistory') as string | null;
    if (saved) {
      try {
        this.historyData = JSON.parse(saved) as string[];
      } catch (e) {
        this.historyData = [];
      }
    }
  }

  private saveHistory(): void {
    AppStorage.setOrCreate('searchHistory', JSON.stringify(this.historyData));
  }

  performSearch(keyword?: string): void {
    const query: string = keyword || this.searchText;
    if (!query.trim()) {
      return;
    }
    this.addToHistory(query.trim());
    this.saveHistory();

    router.pushUrl({
      url: 'pages/SearchResultPage',
      params: { keyword: query.trim() }
    });
  }

  addToHistory(keyword: string): void {
    const index: number = this.historyData.indexOf(keyword);
    if (index > -1) {
      this.historyData.splice(index, 1);
    }
    this.historyData.unshift(keyword);
    if (this.historyData.length > 10) {
      this.historyData.pop();
    }
    this.saveHistory();
  }

  removeHistoryItem(index: number): void {
    this.historyData.splice(index, 1);
    this.saveHistory();
  }

  clearAllHistory(): void {
    this.showClearConfirm = false;
    this.historyData = [];
    this.saveHistory();
  }

  onSearchInputChanged(value: string): void {
    this.searchText = value;
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

        Row() {
          SymbolGlyph($r('sys.symbol.magnifyingglass'))
            .width(16)
            .height(16)
            .fontColor(['#999999', '#999999'])

          TextInput({ placeholder: '搜索商品', text: this.searchText })
            .layoutWeight(1)
            .height(32)
            .backgroundColor(Color.Transparent)
            .placeholderColor('#CCCCCC')
            .fontSize(14)
            .onChange((value: string) => {
              this.onSearchInputChanged(value);
            })
            .onSubmit((enterKey: EnterKeyType, event: SubmitEvent) => {
              this.performSearch();
            })
        }
        .height(36)
        .padding({ left: 10, right: 10 })
        .backgroundColor('#F0F0F0')
        .borderRadius(18)
        .layoutWeight(1)

        Text('搜索')
          .fontSize(15)
          .fontColor('#FF2D55')
          .margin({ left: 8 })
          .flexShrink(0)
          .onClick(() => {
            this.performSearch();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 12, right: 12 })
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF')
      .constraintSize({ maxWidth: '100%' })

      Scroll() {
        Column() {
          if (this.historyData.length > 0) {
            this.buildHistorySection()
          }

          this.buildGuessSection()
          this.buildHotSearchSection()
        }
        .padding({ left: 16, right: 16, top: 12, bottom: 30 })
      }
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F7')
  }

  @Builder
  buildHistorySection() {
    Column() {
      Row() {
        Text('历史搜索')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1C1C1E')
          .layoutWeight(1)

        if (!this.showClearConfirm) {
          Text('清空')
            .fontSize(13)
            .fontColor('#999999')
            .onClick(() => {
              this.showClearConfirm = true;
            })
        } else {
          Row({ space: 12 }) {
            Text('取消')
              .fontSize(13)
              .fontColor('#999999')
              .onClick(() => {
                this.showClearConfirm = false;
              })

            Text('确认清空')
              .fontSize(13)
              .fontColor('#FF3B30')
              .onClick(() => {
                this.clearAllHistory();
              })
          }
        }
      }
      .width('100%')

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.historyData, (item: string, index: number) => {
          Row() {
            Text(item)
              .fontSize(13)
              .fontColor('#333333')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            SymbolGlyph($r('sys.symbol.xmark_circle_fill'))
              .width(14)
              .height(14)
              .fontColor(['#CCCCCC', '#CCCCCC'])
              .margin({ left: 6 })
              .onClick(() => {
                this.removeHistoryItem(index);
              })
          }
          .padding({ left: 14, right: 10, top: 7, bottom: 7 })
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ top: 10, right: 10 })
          .onClick(() => {
            this.performSearch(item);
          })
        }, (item: string, index: number): string => 'history_' + String(index))
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .margin({ bottom: 20 })
  }

  @Builder
  buildGuessSection() {
    Column() {
      Row() {
        Text('猜你想搜')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1C1C1E')
        Blank()
      }
      .width('100%')

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.guessKeywords, (item: string) => {
          Text(item)
            .fontSize(13)
            .fontColor('#555555')
            .padding({ left: 14, right: 14, top: 7, bottom: 7 })
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .margin({ top: 10, right: 10 })
            .onClick(() => {
              this.performSearch(item);
            })
        }, (item: string): string => item)
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .margin({ bottom: 24 })
  }

  @Builder
  buildHotSearchSection() {
    Column() {
      Row() {
        Text('热搜榜单')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1C1C1E')
        Blank()

        Row() {
          SymbolGlyph($r('sys.symbol.flame_fill'))
            .width(14)
            .height(14)
            .fontColor(['#FF6B35', '#FF6B35'])
          Text('实时更新')
            .fontSize(11)
            .fontColor('#FF6B35')
            .margin({ left: 4 })
        }
      }
      .width('100%')

      Column() {
        ForEach(this.hotSearchList, (item: HotSearchItem) => {
          Row() {
            Text(item.rank.toString())
              .fontSize(item.rank <= 3 ? 17 : 15)
              .fontWeight(item.rank <= 3 ? FontWeight.Bold : FontWeight.Regular)
              .fontColor(item.rank === 1 ? '#FF2D55' : item.rank === 2 ? '#FF9500' : item.rank === 3 ? '#FFB800' : '#BBBBBB')
              .width(22)

            Text(item.keyword)
              .fontSize(14)
              .fontColor('#1C1C1E')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)

            if (item.hot) {
              Text('热')
                .fontSize(10)
                .fontColor('#FFFFFF')
                .backgroundColor('#FF2D55')
                .padding({ left: 5, right: 5, top: 2, bottom: 2 })
                .borderRadius(4)
                .margin({ left: 8 })
            }

            SymbolGlyph($r('sys.symbol.chevron_right'))
              .width(14)
              .height(14)
              .fontColor(['#CCCCCC', '#CCCCCC'])
              .margin({ left: 6 })
          }
          .width('100%')
          .height(48)
          .alignItems(VerticalAlign.Center)
          .padding({ right: 4 })
          .onClick(() => {
            this.performSearch(item.keyword);
          })
        }, (item: HotSearchItem): string => 'hot_' + String(item.id))
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .padding({ left: 12, right: 4 })
      .margin({ top: 12 })
    }
    .width('100%')
  }
}
