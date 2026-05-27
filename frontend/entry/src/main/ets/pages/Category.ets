import CommonConstants from '../constants/CommonConstants';
import router from '@ohos.router';
import HttpUtil from '../utils/HttpUtil';
import promptAction from '@ohos.promptAction';

interface CategoryItem {
  id: number;
  name: string;
  icon: string;
  sort: number;
}

interface GridItemData {
  name: string
  icon: string
}

interface SubCategory {
  name: string
}

const MOCK_CATEGORIES: CategoryItem[] = [
  { id: 1, name: '男装', icon: '', sort: 1 },
  { id: 2, name: '女装', icon: '', sort: 2 },
  { id: 3, name: '数码', icon: '', sort: 3 },
  { id: 4, name: '食品', icon: '', sort: 4 },
  { id: 5, name: '电器', icon: '', sort: 5 },
  { id: 6, name: '鞋包', icon: '', sort: 6 },
  { id: 7, name: '百货', icon: '', sort: 7 },
  { id: 8, name: '家居', icon: '', sort: 8 },
  { id: 9, name: '家纺', icon: '', sort: 9 },
  { id: 10, name: '美妆', icon: '', sort: 10 },
  { id: 11, name: '母婴', icon: '', sort: 11 },
  { id: 12, name: '运动', icon: '', sort: 12 },
  { id: 13, name: '图书', icon: '', sort: 13 },
  { id: 14, name: '配饰', icon: '', sort: 14 },
  { id: 15, name: '户外', icon: '', sort: 15 }
];

const MOCK_SUB_CATEGORIES: Record<string, SubCategory[]> = {
  '男装': [
    { name: 'T恤' }, { name: '衬衫' }, { name: '夹克外套' },
    { name: '牛仔裤' }, { name: '休闲裤' }, { name: '西装' },
    { name: '卫衣' }, { name: '毛衣针织' }, { name: '风衣大衣' }
  ],
  '女装': [
    { name: '连衣裙' }, { name: '上衣' }, { name: '半身裙' },
    { name: '牛仔裤' }, { name: '阔腿裤' }, { name: '短裙' },
    { name: '小西装' }, { name: '针织衫' }, { name: '羽绒服' }
  ],
  '数码': [
    { name: '智能手机' }, { name: '平板电脑' }, { name: '笔记本电脑' },
    { name: '智能手表' }, { name: '蓝牙耳机' }, { name: '相机' },
    { name: '充电宝' }, { name: '数据线' }, { name: '手机壳' }
  ],
  '食品': [
    { name: '坚果零食' }, { name: '进口零食' }, { name: '饼干糕点' },
    { name: '糖果巧克力' }, { name: '咖啡茶饮' }, { name: '粮油调味' },
    { name: '生鲜水果' }, { name: '乳品烘焙' }, { name: '酒水饮料' }
  ],
  '电器': [
    { name: '电视机' }, { name: '空调' }, { name: '洗衣机' },
    { name: '冰箱' }, { name: '厨房电器' }, { name: '生活家电' },
    { name: '个护健康' }, { name: '影音设备' }, { name: '智能家居' }
  ],
  '鞋包': [
    { name: '运动鞋' }, { name: '休闲鞋' }, { name: '高跟鞋' },
    { name: '单鞋' }, { name: '靴子' }, { name: '帆布鞋' },
    { name: '手提包' }, { name: '双肩包' }, { name: '钱包卡包' }
  ],
  '百货': [
    { name: '收纳整理' }, { name: '清洁用品' }, { name: '文具办公' },
    { name: '雨具伞具' }, { name: '宠物用品' }, { name: '汽车用品' },
    { name: '家居日用' }, { name: '五金工具' }, { name: '节日礼品' }
  ],
  '家居': [
    { name: '床品套件' }, { name: '沙发垫' }, { name: '窗帘窗纱' },
    { name: '地毯地垫' }, { name: '装饰画' }, { name: '花瓶花艺' },
    { name: '灯具灯饰' }, { name: '镜子' }, { name: '摆件挂件' }
  ],
  '家纺': [
    { name: '四件套' }, { name: '被子被芯' }, { name: '枕头枕芯' },
    { name: '床垫' }, { name: '毛毯' }, { name: '蚊帐凉席' },
    { name: '毛巾浴巾' }, { name: '靠垫抱枕' }, { name: '床幔' }
  ],
  '美妆': [
    { name: '面部护肤' }, { name: '彩妆' }, { name: '香水香氛' },
    { name: '身体护理' }, { name: '美发护发' }, { name: '美容工具' },
    { name: '男士护理' }, { name: '防晒隔离' }, { name: '面膜' }
  ],
  '母婴': [
    { name: '奶粉辅食' }, { name: '纸尿裤' }, { name: '童装童鞋' },
    { name: '玩具' }, { name: '孕产用品' }, { name: '喂养用品' },
    { name: '洗护用品' }, { name: '推车座椅' }, { name: '寝居服饰' }
  ],
  '运动': [
    { name: '跑步装备' }, { name: '健身器材' }, { name: '瑜伽舞蹈' },
    { name: '球类运动' }, { name: '骑行装备' }, { name: '游泳装备' },
    { name: '户外登山' }, { name: '运动服饰' }, { name: '运动配件' }
  ],
  '图书': [
    { name: '文学小说' }, { name: '经管励志' }, { name: '人文社科' },
    { name: '科技计算机' }, { name: '少儿读物' }, { name: '教育考试' },
    { name: '艺术设计' }, { name: '生活百科' }, { name: '期刊杂志' }
  ],
  '配饰': [
    { name: '项链吊坠' }, { name: '耳饰耳环' }, { name: '戒指手链' },
    { name: '胸针领结' }, { name: '帽子' }, { name: '围巾丝巾' },
    { name: '腰带皮带' }, { name: '墨镜眼镜' }, { name: '手套袖扣' }
  ],
  '户外': [
    { name: '帐篷睡袋' }, { name: '野炊烧烤' }, { name: '徒步背包' },
    { name: '冲锋衣裤' }, { name: '登山杖' }, { name: '头灯照明' },
    { name: '急救装备' }, { name: '钓鱼用具' }, { name: '露营桌椅' }
  ]
};

@Entry
@Component
export default struct Category {
  @State categoryList: CategoryItem[] = [];
  @State currentCategoryIndex: number = 0;
  private leftScroller: Scroller = new Scroller();
  private rightScroller: Scroller = new Scroller();
  private isClickScrolling: boolean = false;

  aboutToAppear(): void {
    this.loadCategories();
    this.initMockCategories();
  }

  private initMockCategories(): void {
    this.categoryList = [...MOCK_CATEGORIES];
  }

  private async loadCategories(): Promise<void> {
    try {
      const data: object[] = await HttpUtil.get<object[]>('/api/goods/categories');
      if (Array.isArray(data) && data.length > 0) {
        const list: CategoryItem[] = data.map((item: object): CategoryItem => {
          const obj: Record<string, Object> = item as Record<string, Object>;
          return {
            id: obj['id'] ? Number(obj['id']) : 0,
            name: obj['name'] ? String(obj['name']) : '',
            icon: obj['icon'] ? String(obj['icon']) : '',
            sort: obj['sort'] ? Number(obj['sort']) : 0
          };
        });
        if (list.length > 0) {
          this.categoryList = list;
        }
      }
    } catch (error) {
      console.info('分类数据加载失败，使用本地默认分类');
    }
  }

  private onLeftCategoryClick(index: number): void {
    if (this.currentCategoryIndex === index) {
      return;
    }
    this.currentCategoryIndex = index;
    this.isClickScrolling = true;

    this.rightScroller.scrollToIndex(index + 1, true);

    setTimeout(() => {
      this.isClickScrolling = false;
    }, 350);
  }

  build() {
    Column() {
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .width(24)
          .height(24)
          .fontColor(['#333333'])
          .onClick(() => {
            router.back();
          })

        Text('商品分类')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1C1C1E')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .width(22)
          .height(22)
          .fontColor(['#666666'])
          .onClick(() => {
            router.pushUrl({ url: 'pages/SearchPage', params: { keyword: '' } });
          })
      }
      .width('100%')
      .height(52)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      Divider().color('#F0F0F0').strokeWidth(0.5)

      Row() {
        List({ scroller: this.leftScroller, initialIndex: 0 }) {
          ForEach(this.categoryList, (category: CategoryItem, index: number) => {
            ListItem() {
              Text(category.name)
                .fontSize(this.currentCategoryIndex === index ? 16 : 14)
                .fontWeight(this.currentCategoryIndex === index ? FontWeight.Bold : FontWeight.Regular)
                .fontColor(this.currentCategoryIndex === index ? $r('app.color.tab_selected') : '#555555')
                .width('100%')
                .height(50)
                .textAlign(TextAlign.Center)
                .padding({ left: 12 })
                .backgroundColor(this.currentCategoryIndex === index ? Color.White : Color.Transparent)
            }
            .onClick(() => {
              this.onLeftCategoryClick(index);
            })
          }, (category: CategoryItem, index: number): string => 'cat_' + String(category.id))
        }
        .width('80vp')
        .height('100%')
        .backgroundColor('#F8F8F8')
        .divider({ strokeWidth: 0.5, color: '#EEEEEE' })

        List({ scroller: this.rightScroller, initialIndex: 0 }) {
          ListItem() {
            this.buildTopSection()
          }

          ForEach(this.categoryList, (category: CategoryItem, idx: number) => {
            ListItem() {
              this.buildCategorySection(category.name, idx)
            }
          }, (category: CategoryItem, idx: number): string => 'sec_' + String(category.id))

          ListItem() {
            Column().height(20)
          }
        }
        .layoutWeight(1)
        .backgroundColor('#FFFFFF')
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)
        .chainAnimation(true)
        .onScrollIndex((start: number) => {
          if (this.isClickScrolling) {
            return;
          }
          const catIdx: number = start - 1;
          if (catIdx >= 0 && catIdx < this.categoryList.length &&
            this.currentCategoryIndex !== catIdx) {
            this.currentCategoryIndex = catIdx;
            this.leftScroller.scrollToIndex(catIdx, true);
          }
        })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  buildTopSection() {
    Column() {
      Row() {
        Text('为您推荐')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1C1C1E')

        Text('排行榜')
          .fontSize(15)
          .fontColor('#888888')
          .margin({ left: 20 })
      }
      .width('100%')
      .padding({ left: 12, right: 12, bottom: 14 })

      Row() {
        this.buildCircleButton('#FF6B35', '人气商品')
        this.buildCircleButton('#4A90D9', '人气商家')
        this.buildCircleButton('#50C9A3', '人气买家')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .padding({ bottom: 16 })

      this.buildGridSection('为您推荐', [
        { name: '数码手机', icon: 'phone' } as GridItemData,
        { name: '充电器', icon: 'battery' } as GridItemData,
        { name: '蓝牙耳机', icon: 'headphone' } as GridItemData,
        { name: '平板电脑', icon: 'tablet' } as GridItemData,
        { name: '智能手表', icon: 'watch' } as GridItemData,
        { name: '移动电源', icon: 'power' } as GridItemData
      ])
    }
    .width('100%')
    .padding({ top: 10, right: 12, left: 12, bottom: 8 })
  }

  @Builder
  buildCircleButton(color: string, text: string) {
    Column() {
      Text(text.substring(0, 2))
        .fontSize(13)
        .fontColor(Color.White)
      Text(text.substring(2))
        .fontSize(11)
        .fontColor(Color.White)
        .margin({ top: 2 })
    }
    .width(70)
    .height(70)
    .borderRadius(35)
    .backgroundColor(color)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildGridSection(title: string, items: GridItemData[]) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1C1C1E')
        .width('100%')
        .padding({ left: 4, bottom: 12 })

      Grid() {
        ForEach(items, (item: GridItemData, index: number) => {
          GridItem() {
            Column() {
              Image($r('app.media.card'))
                .width(48)
                .height(48)
                .objectFit(ImageFit.Cover)
                .borderRadius(10)
                .backgroundColor('#F0F0F0')

              Text(item.name)
                .fontSize(12)
                .fontColor('#333333')
                .margin({ top: 6 })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .onClick(() => {
              promptAction.showToast({
                message: '功能开发中',
                duration: 1500
              });
            })
          }
        }, (item: GridItemData, index: number): string => title + '_' + String(index))
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsGap(16)
      .columnsGap(12)
      .width('100%')
    }
    .width('100%')
    .padding({ bottom: 16 })
  }

  @Builder
  buildCategorySection(title: string, idx: number) {
    Column() {
      Row() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1C1C1E')

        Text('查看更多 >')
          .fontSize(12)
          .fontColor('#999999')
          .layoutWeight(1)
          .textAlign(TextAlign.End)
      }
      .width('100%')
      .padding({ left: 4, bottom: 12 })

      Grid() {
        ForEach(MOCK_SUB_CATEGORIES[title] || [], (sub: SubCategory, goodsIdx: number) => {
          GridItem() {
            Column() {
              Image($r('app.media.card'))
                .width(60)
                .height(60)
                .objectFit(ImageFit.Cover)
                .borderRadius(10)
                .backgroundColor('#F5F5F7')

              Text(sub.name)
                .fontSize(12)
                .fontColor('#555555')
                .margin({ top: 8 })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              promptAction.showToast({
                message: '功能开发中',
                duration: 1500
              });
            })
          }
        }, (sub: SubCategory, goodsIdx: number): string => title + '_' + String(goodsIdx))
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsGap(18)
      .columnsGap(10)
      .width('100%')
    }
    .width('100%')
    .padding({ top: 16, right: 12, left: 12, bottom: 8 })
  }
}
