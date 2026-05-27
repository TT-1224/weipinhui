import router from '@ohos.router';
import HttpUtil from '../utils/HttpUtil';
import promptAction from '@ohos.promptAction';

interface RegisterParams {
  phone: string;
  password: string;
  nickname: string | undefined;
}

@Entry
@Component
export default struct RegisterPage {
  @State phone: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State nickname: string = '';
  @State isLoading: boolean = false;
  @State agreeProtocol: boolean = false;

  // 注册
  async handleRegister() {
    if (!this.validateInput()) return;

    this.isLoading = true;
    try {
      const registerData: RegisterParams = {
        phone: this.phone,
        password: this.password,
        nickname: this.nickname || undefined
      };
      await HttpUtil.post<void>('/api/user/register', registerData);

      promptAction.showToast({ message: '注册成功，请登录' });
      router.replaceUrl({ url: 'pages/LoginPage' });
    } catch (error) {
      promptAction.showToast({ message: '网络错误，请重试' });
      console.error('注册失败:', error);
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

    if (this.password !== this.confirmPassword) {
      promptAction.showToast({ message: '两次密码不一致' });
      return false;
    }

    if (this.nickname.length > 20) {
      promptAction.showToast({ message: '昵称不能超过20个字符' });
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
        Text('注册账号')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 8 })
        Text('创建您的电商购物APP账户')
          .fontSize(14)
          .fontColor('#999999')
      }
      .width('100%')
      .margin({ top: 30, bottom: 30 })

      // 表单区域
      Column({ space: 16 }) {
        // 手机号输入框
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

        // 昵称输入框（可选）
        TextInput({ placeholder: '请输入昵称（选填）', text: this.nickname })
          .type(InputType.Normal)
          .maxLength(20)
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .padding({ left: 16 })
          .onChange((value: string) => {
            this.nickname = value;
          })

        // 密码输入框
        TextInput({ placeholder: '请设置密码(6-20位)', text: this.password })
          .type(InputType.Password)
          .maxLength(20)
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .padding({ left: 16 })
          .onChange((value: string) => {
            this.password = value;
          })

        // 确认密码输入框
        TextInput({ placeholder: '请再次输入密码', text: this.confirmPassword })
          .type(InputType.Password)
          .maxLength(20)
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .padding({ left: 16 })
          .onChange((value: string) => {
            this.confirmPassword = value;
          })

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
          Text('和')
            .fontSize(12)
            .fontColor('#666666')
          Text('《隐私政策》')
            .fontSize(12)
            .fontColor('#FF2D55')
        }
        .alignItems(VerticalAlign.Center)

        // 注册按钮
        Button(this.isLoading ? '注册中...' : '注册', { type: ButtonType.Capsule })
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#FF2D55')
          .enabled(!this.isLoading)
          .onClick(() => {
            this.handleRegister();
          })
      }
      .width('90%')

      // 登录入口
      Row() {
        Text('已有账号？')
          .fontSize(14)
          .fontColor('#999999')
        Text('立即登录')
          .fontSize(14)
          .fontColor('#FF2D55')
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            router.replaceUrl({ url: 'pages/LoginPage' });
          })
      }
      .margin({ top: 40 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
