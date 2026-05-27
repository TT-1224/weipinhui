
import CommonConstants from '../constants/CommonConstants';
import WomanPage from './components/WomanPage'
import ManPage from './components/ManPage'
import HomePage from './components/HomePage'
import SportPage from './components/SportPage'
import ComputerPage from './components/ComputerPage'
import Mine from './Mine'
import Shop from './Shop';
import Category from './Category';
import MessageListPage from './MessageListPage';
import router from '@ohos.router';
import CartManager from '../manager/CartManager';

@Entry
@Component
export default struct MainPage {
  @State currentIndex: number = CommonConstants.HOME_TAB_INDEX;
  @State changeValue: string = '';
  @State submitValue: string = '';
  private tabController: TabsController = new TabsController();
  @State enableFlag: boolean = true;
  private searchController: SearchController = new SearchController();
  @State topTabIndex: number = 0;
  @StorageLink('cartCount') cartCount: number = 0;

  // 跳转到搜索页面
  navigateToSearchPage(keyword: string) {
    router.pushUrl({
      url: 'pages/SearchPage',
      params: {
        keyword: keyword
      }
    });
  }

  // 底部Tab构造器
  @Builder TabBuilder(title: string, index: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Image(this.currentIndex === index ? selectedImg : normalImg)
          .width($r('app.float.mainPage_baseTab_size'))
          .height($r('app.float.mainPage_baseTab_size'))

        if (index === CommonConstants.SHOP_TAB_INDEX && this.cartCount > 0) {
          Text(this.cartCount > 99 ? '99+' : String(this.cartCount))
            .fontSize(10)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#FF2D55')
            .borderRadius(10)
            .width(18)
            .height(18)
            .textAlign(TextAlign.Center)
            .margin({ top: -2, right: -6 })
        }
      }
      Text(title)
        .margin({ top: $r('app.float.mainPage_baseTab_top') })
        .fontSize($r('app.float.main_tab_fontSize'))
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.currentIndex === index ? '#FF2D55' : '#8E8E93')
    }
    .justifyContent(FlexAlign.Center)
    .height($r('app.float.mainPage_barHeight'))
    .width(CommonConstants.FULL_PARENT)
    .onClick(() => {
      this.currentIndex = index;
      this.tabController.changeIndex(this.currentIndex);
    })
  }

  // 重置搜索框和顶部Tab的可见性
  resetVisibleAndLength(index: number) {
    this.enableFlag = (index === 0);
  }

  // 渲染搜索框
  @Builder renderSearchBar() {
    Row() {
      Row() {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .width(16)
          .height(16)
          .fontColor(['#999999', '#999999'])

        TextInput({ placeholder: '男士羽绒服', text: this.changeValue })
          .layoutWeight(1)
          .height(32)
          .backgroundColor(Color.Transparent)
          .placeholderColor('#CCCCCC')
          .fontSize(14)
          .onChange((value: string) => {
            this.changeValue = value;
          })
          .onSubmit((enterKey: EnterKeyType, event: SubmitEvent) => {
            this.submitValue = this.changeValue;
            this.navigateToSearchPage(this.changeValue);
          })
      }
      .height(36)
      .padding({ left: 12, right: 12 })
      .backgroundColor('#F0F0F0')
      .borderRadius(18)
      .layoutWeight(1)

      Text('搜索')
        .fontSize(15)
        .fontColor('#FF2D55')
        .margin({ left: 10 })
        .flexShrink(0)
        .onClick(() => {
          this.submitValue = this.changeValue;
          this.navigateToSearchPage(this.changeValue);
        })
    }
    .padding({ top: $r('app.float.home_grid_margin'), left: 12, right: 12, bottom: 8 })
    .backgroundColor('#F5F5F7')
    .shadow({
      radius: 8,
      color: '#12000000',
      offsetX: 0,
      offsetY: 1
    })
    .visibility(this.enableFlag ? Visibility.Visible : Visibility.None)
  }

  // 渲染顶部Tab
  @Builder renderTopTabs() {
    Column() {
      Tabs({ barPosition: BarPosition.Start }) {
        /*推荐页*/
        TabContent() { HomePage() }
          .tabBar(this.TopTabBuilder(CommonConstants.HOME_TITLE, 0))
        /*女装页*/
        TabContent() { WomanPage() }
          .tabBar(this.TopTabBuilder(CommonConstants.WOMAN_TITLE, 1))
        /*男装页*/
        TabContent() { ManPage() }
          .tabBar(this.TopTabBuilder(CommonConstants.MAN_TITLE, 2))
        /*运动页*/
        TabContent() { SportPage() }
          .tabBar(this.TopTabBuilder(CommonConstants.SPORT_TITLE, 3))
        /*电脑办公页*/
        TabContent() { ComputerPage() }
          .tabBar(this.TopTabBuilder(CommonConstants.TEC_TITLE, 4))
        /*其他*/
        TabContent() { }
          .tabBar(this.TopTabBuilder(CommonConstants.OTHER_TITLE, 5))
      }
      .barHeight('40vp')
      .vertical(false)
      .scrollable(true)
      .barMode(BarMode.Scrollable)
      .onChange((index: number) => {
        this.topTabIndex = index;
      })
      .width('100%')
      .backgroundColor('#F5F5F7')
      .animation({ duration: 300, curve: Curve.EaseInOut })
    }
    .width('100%')
    .layoutWeight(1)
    .visibility(this.enableFlag ? Visibility.Visible : Visibility.None)
    .animation({ duration: 300, curve: Curve.EaseInOut })
  }

  // 自定义顶部Tab项构造器
  @Builder TopTabBuilder(title: string, index: number) {
    Text(title)
      .fontSize(15)
      .fontWeight(this.topTabIndex === index ? FontWeight.Bold : FontWeight.Regular)
      .fontColor(this.topTabIndex === index ? '#FF2D55' : '#8E8E93')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
  }

  build() {
    Column() {
      // 搜索框
      this.renderSearchBar();

      // 内容区域
      Column() {
        // 底部Tab导航
        Tabs({ barPosition: BarPosition.End, controller: this.tabController }) {
          /*首页*/
          TabContent() {
            this.renderTopTabs()
          }
          .padding({ left: $r('app.float.mainPage_padding'), right: $r('app.float.mainPage_padding') })
          .tabBar(this.TabBuilder(CommonConstants.HOME_TITLE, CommonConstants.HOME_TAB_INDEX, $r('app.media.home_selected'), $r('app.media.home_normal')))

          /*分类*/
          TabContent() {
            Category()
          }
          .padding({ left: $r('app.float.mainPage_padding'), right: $r('app.float.mainPage_padding') })
          .tabBar(this.TabBuilder(CommonConstants.CATEGORY_TITLE, CommonConstants.CATEGORY_TAB_INDEX, $r('app.media.sub_selected'), $r('app.media.sub_normal')))

          /*购物车*/
          TabContent() {
            Shop()
          }
          .padding({ left: $r('app.float.mainPage_padding'), right: $r('app.float.mainPage_padding') })
          .tabBar(this.TabBuilder(CommonConstants.SHOP_TITLE, CommonConstants.SHOP_TAB_INDEX, $r('app.media.shopping_selected'), $r('app.media.shopping_normal')))

          /*信息*/
          TabContent() {
            MessageListPage()
          }
          .padding({ left: $r('app.float.mainPage_padding'), right: $r('app.float.mainPage_padding') })
          .tabBar(this.TabBuilder(CommonConstants.INFO_TITLE, CommonConstants.INFO_TAB_INDEX, $r('app.media.new_pink'), $r('app.media.new')))

          /*个人中心*/
          TabContent() {
            Mine()
          }
          .padding({ left: $r('app.float.mainPage_padding'), right: $r('app.float.mainPage_padding') })
          .tabBar(this.TabBuilder(CommonConstants.USER_TITLE, CommonConstants.USER_TAB_INDEX, $r('app.media.mine_selected'), $r('app.media.mine_normal')))
        }
        .vertical(false)
        .scrollable(true)
        .barMode(BarMode.Fixed)
        .onChange((index: number) => {
          this.resetVisibleAndLength(index);
        })
        .width('100%')
        .layoutWeight(1)
        .barBackgroundColor('#FFFFFF')
        .backgroundColor('#F5F5F7')
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F5F5F7')
    }
    .width('100%')
    .height(CommonConstants.FULL_PARENT)
    .backgroundColor('#F5F5F7')
  }
}
