import CommonConstants from '../constants/CommonConstants';
import userInfoService from '../datasource/UserInfoService';
import HttpUtil from '../utils/HttpUtil';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import picker from '@ohos.file.picker';
import UserManager from '../manager/UserManager';

interface ProfileUpdateParams {
  avatar: string;
  username: string;
  email: string;
}

@Entry
@Component
export default struct EditProfilePage {
  @State username: string = userInfoService.getUserInfo().username;
  @State email: string = userInfoService.getUserInfo().email;
  @State avatar: Resource = userInfoService.getUserInfo().avatar;
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  // 保存个人信息
  async saveProfile() {
    // 输入验证
    if (!this.username.trim()) {
      this.errorMessage = '用户名不能为空';
      return;
    }

    if (!this.email.trim()) {
      this.errorMessage = '邮箱不能为空';
      return;
    }

    // 简单的邮箱格式验证
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(this.email)) {
      this.errorMessage = '邮箱格式不正确';
      return;
    }

    // 调用后端API保存
    this.isLoading = true;
    this.errorMessage = '';

    try {
      const avatarStr: string = (this.avatar !== undefined && typeof this.avatar === 'string') ? this.avatar : '';
      const success: boolean = await UserManager.updateProfile(this.username, this.email, avatarStr);

      if (success) {
        userInfoService.updateUserInfo({
          username: this.username,
          email: this.email,
          avatar: this.avatar
        });
        setTimeout(() => {
          router.back();
        }, 500);
      }
    } catch (error) {
      console.error('保存失败:', error);
      this.errorMessage = '网络错误，请重试';
    } finally {
      this.isLoading = false;
    }
  }

  // 更换头像
  async changeAvatar() {
    try {
      // 创建图片选择器
      const photoPicker = new picker.PhotoViewPicker();
      const result = await photoPicker.select();
      
      // 处理选择的图片
      if (result.photoUris && result.photoUris.length > 0) {
        // 在实际项目中，这里需要处理图片URI，可能需要加载图片
        // 由于模拟器环境限制，这里暂时使用默认头像作为示例
        // 实际设备上可以使用Image组件加载result.photoUris[0]
        
        // 模拟选择成功
        const avatars = [
          $r('app.media.account'),
          $r('app.media.icon'),
          $r('app.media.home_normal')
        ];
        const randomIndex = Math.floor(Math.random() * avatars.length);
        this.avatar = avatars[randomIndex];
      }
    } catch (error) {
      console.error('选择图片失败:', error);
    }
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Button() {
          Text('返回')
            .fontSize(16)
            .fontColor('#1C1C1E')
        }
        .backgroundColor('transparent')
        .onClick(() => {
          router.back();
        })
        
        Text('编辑个人资料')
          .fontSize($r('app.float.page_title_text_size'))
          .fontWeight(FontWeight.Bolder)
          .fontColor('#1C1C1E')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Blank()
          .width(60)
      }
      .width('100%')
      .height(60)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#F5F5F7')

      Scroll() {
        Column({ space: 20 }) {
          // 头像编辑
          Column() {
            Image(this.avatar)
              .width(100)
              .height(100)
              .borderRadius(50)
              .onClick(() => {
                this.changeAvatar();
              })
            Text('点击更换头像')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 10 })
          }
          .alignItems(HorizontalAlign.Center)
          .margin({ top: 30 })

          // 用户名编辑
          Column() {
            Text('用户名')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ bottom: 8 })
            TextInput({
              placeholder: '请输入用户名',
              text: this.username
            })
              .width('90%')
              .height(40)
              .padding({ left: 10, right: 10 })
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .onChange((value: string) => {
                this.username = value;
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)

          // 邮箱编辑
          Column() {
            Text('邮箱')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ bottom: 8 })
            TextInput({
              placeholder: '请输入邮箱',
              text: this.email
            })
              .width('90%')
              .height(40)
              .padding({ left: 10, right: 10 })
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .onChange((value: string) => {
                this.email = value;
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)

          // 错误信息显示
          if (this.errorMessage) {
            Text(this.errorMessage)
              .fontSize(14)
              .fontColor('#FF3B30')
              .textAlign(TextAlign.Center)
              .margin({ top: 10 })
          }

          // 保存按钮
          Button(this.isLoading ? '保存中...' : '保存')
            .width('80%')
            .height(45)
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor(this.isLoading ? '#ffff2d55' : '#ffff2d55')
            .borderRadius(22)
            .margin({ top: 40 })
            .enabled(!this.isLoading)
            .onClick(() => {
              this.saveProfile();
            })
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}