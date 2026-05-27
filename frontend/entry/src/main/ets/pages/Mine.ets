import router from '@ohos.router';
import HttpUtil from '../utils/HttpUtil';
import { StorageUtil } from '../utils/StorageUtil';
import userInfoService from '../datasource/UserInfoService';
import promptAction from '@ohos.promptAction';
import UserManager from '../manager/UserManager';

interface UserInfoResponse {
  id: number;
  phone: string;
  nickname: string;
  avatar: string;
  email: string;
}

interface UserInfoUpdateParam {
  username: string;
  email: string;
  avatar?: Resource;
}

@Entry
@Component
struct Mine {
  @State isLoggedIn: boolean = false;
  @State username: string = '个人用户';
  @State email: string = 'gerenyonghu@163.com';
  @State avatar: Resource | string = $r('app.media.account');
  @State isLoadingUser: boolean = false;
  @StorageLink('userLoggedIn') @Watch('onUserStatusChanged') userLoggedIn: boolean = false;

  aboutToAppear(): void {
    this.initFromUserManager();
    UserManager.subscribe(() => {
      this.onUserInfoChanged();
    });
  }

  aboutToDisappear() {
    UserManager.unsubscribe(() => {
      this.onUserInfoChanged();
    });
  }

  private initFromUserManager(): void {
    this.isLoggedIn = UserManager.getIsLoggedIn();
    if (this.isLoggedIn) {
      const info = UserManager.getUserInfo();
      if (info) {
        this.username = info.nickname || '个人用户';
        this.email = info.email || '';
        this.avatar = info.avatar || $r('app.media.account');
      }
    }
  }

  private onUserStatusChanged(): void {
    this.isLoggedIn = this.userLoggedIn;
    if (this.isLoggedIn) {
      this.onUserInfoChanged();
    } else {
      this.username = '个人用户';
      this.email = 'gerenyonghu@163.com';
      this.avatar = $r('app.media.account');
    }
  }

  private onUserInfoChanged(): void {
    this.isLoggedIn = UserManager.getIsLoggedIn();
    this.username = UserManager.getUsername();
    this.email = UserManager.getEmail();
    this.avatar = UserManager.getAvatar();

    const updateData: UserInfoUpdateParam = {
      username: this.username,
      email: this.email
    };
    if (typeof this.avatar !== 'string') {
      updateData.avatar = this.avatar as Resource;
    }
    userInfoService.updateUserInfo(updateData);
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 0 }) {
          this.HeaderSectionBuilder()
          this.OrderSectionBuilder()
          this.MenuSectionBuilder()
          this.ActionButtonBuilder()
          Blank()
            .height(20)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .flexGrow(1)
      .backgroundColor('#F5F6FA')
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F7')
  }

  @Builder
  HeaderSectionBuilder(): void {
    Column() {
      Row({ space: 16 }) {
        Image(this.avatar)
          .width(68)
          .height(68)
          .borderRadius(34)
          .objectFit(ImageFit.Cover)
          .border({ width: 2, color: '#FFFFFF' })
          .onClick(() => {
            if (this.isLoggedIn) {
              router.pushUrl({ url: 'pages/EditProfilePage' });
            } else {
              router.pushUrl({ url: 'pages/LoginPage' });
            }
          })

        Column({ space: 4 }) {
          Text(this.isLoggedIn ? this.username : '点击登录')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1C1C1E')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          if (this.isLoggedIn) {
            Text(this.email || '已登录')
              .fontSize(13)
              .fontColor('#8E8E93')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          } else {
            Text('登录后享受更多服务')
              .fontSize(13)
              .fontColor('#8E8E93')
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .width(18)
          .height(18)
          .fontColor(['#CCCCCC', '#FFFFFF'])
      }
      .width('100%')
      .padding({ left: 20, right: 16, top: 24, bottom: 24 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 0, topRight: 0, bottomLeft: 16, bottomRight: 16 })
    .shadow({ radius: 8, color: '#14000000', offsetY: 2 })
    .onClick(() => {
      if (this.isLoggedIn) {
        router.pushUrl({ url: 'pages/EditProfilePage' });
      } else {
        router.pushUrl({ url: 'pages/LoginPage' });
      }
    })
  }

  @Builder
  OrderSectionBuilder(): void {
    Column() {
      Row() {
        Text('我的订单')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1C1C1E')

        Blank()

        Text('查看全部')
          .fontSize(13)
          .fontColor('#8E8E93')

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .width(14)
          .height(14)
          .fontColor(['#CCCCCC', '#FFFFFF'])
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 12 })
      .onClick(() => {
        router.pushUrl({
          url: 'pages/OrderPage'
        });
      })

      Row() {
        this.OrderIconItemBuilder($r('app.media.pay'), '待付款', 0)
        this.OrderIconItemBuilder($r('app.media.order'), '待发货', 1)
        this.OrderIconItemBuilder($r('app.media.storage'), '待收货', 2)
        this.OrderIconItemBuilder($r('app.media.talk'), '待评价', 3)
      }
      .width('100%')
      .padding({ bottom: 16 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ top: 10, left: 10, right: 10 })
    .shadow({ radius: 6, color: '#10000000', offsetY: 1 })
  }

  @Builder
  OrderIconItemBuilder(icon: Resource, label: string, status?: number): void {
    Column({ space: 6 }) {
      Image(icon)
        .width(26)
        .height(26)
        .fillColor('#333333')

      Text(label)
        .fontSize(11)
        .fontColor('#666666')
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      if (status !== undefined) {
        router.pushUrl({
          url: 'pages/OrderPage',
          params: { status: status }
        });
      } else {
        router.pushUrl({
          url: 'pages/OrderPage'
        });
      }
    })
  }

  @Builder
  MenuSectionBuilder(): void {
    Column() {
      this.MenuItemRowBuilder($r('app.media.order'), '我的订单', '查看全部订单', () => {
        router.pushUrl({
          url: 'pages/OrderPage'
        });
      })
      Divider().color('#F0F0F0').margin({ left: 48 })
      this.MenuItemRowBuilder($r('app.media.love'), '我的收藏', '收藏的商品和店铺', () => {
        router.pushUrl({
          url: 'pages/FavoritePage'
        });
      })
      Divider().color('#F0F0F0').margin({ left: 48 })
      this.MenuItemRowBuilder($r('app.media.storage'), '收货地址', '管理收货地址', () => {
        router.pushUrl({
          url: 'pages/AddressPage'
        });
      })
      Divider().color('#F0F0F0').margin({ left: 48 })
      this.MenuItemRowBuilder($r('app.media.talk'), '客服中心', '在线客服咨询', () => {
        promptAction.showToast({ message: '客服功能开发中...' })
      })
      Divider().color('#F0F0F0').margin({ left: 48 })
      this.MenuItemRowBuilder($r('app.media.about'), '关于我们', '版本信息与帮助', () => {
        promptAction.showToast({ message: '关于页面开发中...' })
      })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ top: 10, left: 10, right: 10 })
    .shadow({ radius: 6, color: '#10000000', offsetY: 1 })
  }

  @Builder
  MenuItemRowBuilder(icon: Resource, title: string, subtitle: string, onClick: () => void): void {
    Row() {
      Image(icon)
        .width(22)
        .height(22)
        .fillColor('#333333')

      Column({ space: 2 }) {
        Text(title)
          .fontSize(15)
          .fontColor('#1C1C1E')
        Text(subtitle)
          .fontSize(12)
          .fontColor('#AAAAAA')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .width(14)
        .height(14)
        .fontColor(['#CCCCCC', '#FFFFFF'])
    }
    .width('100%')
    .height(54)
    .padding({ left: 16, right: 16 })
    .onClick(onClick)
  }

  @Builder
  ActionButtonBuilder(): void {
    Column() {
      if (this.isLoggedIn) {
        Button('退出登录', { type: ButtonType.Capsule })
          .width('100%')
          .height(46)
          .fontSize(16)
          .fontColor('#FF3B30')
          .backgroundColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)
          .border({ width: 1, color: '#FFD0D0' })
          .margin({ top: 30, bottom: 20 })
          .onClick(() => {
            promptAction.showDialog({
              title: '退出登录',
              message: '确定要退出当前账号吗？退出后需要重新登录才能使用购物车等功能。',
              buttons: [
                { text: '取消', color: '#999999' },
                { text: '确定退出', color: '#FF3B30' }
              ]
            }).then((result: promptAction.ShowDialogSuccessResponse) => {
              if (result.index === 1) {
                StorageUtil.clearAuth();
                UserManager.logout();
              }
            })
          })
      } else {
        Button('立即登录', { type: ButtonType.Capsule })
          .width('100%')
          .height(46)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor('#FF2D55')
          .fontWeight(FontWeight.Medium)
          .margin({ top: 30, bottom: 20 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/LoginPage' });
          })
      }
    }
    .width('100%')
    .padding({ left: 10, right: 10 })
  }
}

export default Mine;
