// UserInfoService.ets
// 用户信息管理服务，用于存储和共享用户头像信息

export interface UserInfo {
  avatar: Resource;
  username: string;
  email: string;
}

class UserInfoService {
  private static instance: UserInfoService;
  private userInfo: UserInfo;

  private constructor() {
    // 初始化默认用户信息
    this.userInfo = {
      avatar: $r('app.media.account'),
      username: '个人用户',
      email: 'gerenyonghu@163.com'
    };
  }

  public static getInstance(): UserInfoService {
    if (!UserInfoService.instance) {
      UserInfoService.instance = new UserInfoService();
    }
    return UserInfoService.instance;
  }

  // 获取用户信息
  public getUserInfo(): UserInfo {
    return this.userInfo;
  }

  // 更新用户头像
  public updateAvatar(avatar: Resource): void {
    this.userInfo.avatar = avatar;
  }

  // 更新用户名称
  public updateUsername(username: string): void {
    this.userInfo.username = username;
  }

  // 更新用户邮箱
  public updateEmail(email: string): void {
    this.userInfo.email = email;
  }

  // 更新用户信息
  public updateUserInfo(info: Partial<UserInfo>): void {
    if (info.avatar !== undefined) {
      this.userInfo.avatar = info.avatar;
    }
    if (info.username !== undefined) {
      this.userInfo.username = info.username;
    }
    if (info.email !== undefined) {
      this.userInfo.email = info.email;
    }
  }
}

export default UserInfoService.getInstance();