import router from '@ohos.router';
import HttpUtil from '../utils/HttpUtil';
import promptAction from '@ohos.promptAction';
import UserManager from '../manager/UserManager';

interface LoginParams {
  phone: string;
  password: string;
}

@Entry
@Component
export default struct LoginPage {
  @State phone: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State agreeProtocol: boolean = false;

  // 登录
  async handleLogin() {
    if (!this.validateInput()) return;

    this.isLoading = true;
    try {
      const success: boolean = await UserManager.login(this.phone, this.password);

      if (success) {
        setTimeout(() => {
          router.replaceUrl({ url: 'pages/Index' });
        }, 500);
      }
    } catch (error) {
      console.error('登录失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  validateInput(): boolean {
    const phoneRegex = /^1[3-9]\d{9}$/;
    if (!phoneRegex.test(this.phone)) {
      promptAction.showToast({ message: '请输入正确的手机号' });
      return false;
    }
    if (this.password.length < 6) {
      promptAction.showToast({ message: '密码长度至少6位' });
      return false;
    }
    if (!this.agreeProtocol) {
      promptAction.showToast({ message: '请先同意用户协议' });
      return false;
    }
    return true;
  }

  build() {
    Column() {
      // 顶部返回按钮
      Row() {
        Image($r('app.media.arrow'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.back();
          })
      }
      .width('100%')
      .padding({ left: 16, top: 16 })

      // Logo区域
      Column() {
        Text('电商购物APP')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF2D55')
          .margin({ bottom: 8 })
        Text('品质生活，从这里开始')
          .fontSize(14)
          .fontColor('#999999')
      }
      .width('100%')
      .margin({ top: 40, bottom: 40 })

      // 表单区域
      Column({ space: 20 }) {
        // 手机号输入框
        Column() {
          TextInput({ placeholder: '请输入手机号', text: this.phone })
            .type(InputType.Number)
            .maxLength(11)
            .height(48)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .padding({ left: 16 })
            .onChange((value: string) => {
              this.phone = value;
            })
        }
        .width('100%')

        // 密码输入框
        Column() {
          TextInput({ placeholder: '请输入密码', text: this.password })
            .type(InputType.Password)
            .height(48)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .padding({ left: 16 })
            .onChange((value: string) => {
              this.password = value;
            })
        }
        .width('100%')

        // 用户协议勾选
        Row() {
          Checkbox({ name: 'protocol', group: 'protocolGroup' })
            .select(this.agreeProtocol)
            .selectedColor('#FF2D55')
            .onChange((value: boolean) => {
              this.agreeProtocol = value;
            })
          Text('我已阅读并同意')
            .fontSize(12)
            .fontColor('#666666')
          Text('《用户协议》')
            .fontSize(12)
            .fontColor('#FF2D55')
        }
        .alignItems(VerticalAlign.Center)

        // 登录按钮
        Button(this.isLoading ? '登录中...' : '登录', { type: ButtonType.Capsule })
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#FF2D55')
          .enabled(!this.isLoading)
          .onClick(() => {
            this.handleLogin();
          })
      }
      .width('90%')
      .padding({ top: 30 })

      // 注册入口
      Row() {
        Text('还没有账号？')
          .fontSize(14)
          .fontColor('#999999')
        Text('立即注册')
          .fontSize(14)
          .fontColor('#FF2D55')
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            router.pushUrl({ url: 'pages/RegisterPage' });
          })
      }
      .margin({ top: 40 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
