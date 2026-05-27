import HttpUtil from '../utils/HttpUtil';
import promptAction from '@ohos.promptAction';

interface UserInfo {
  id: number;
  phone: string;
  nickname: string;
  avatar: string | Resource;
  email: string;
}

interface LoginResponse {
  token: string;
  userId: number;
}

interface LoginRequestParams {
  phone: string;
  password: string;
}

interface ProfileUpdateParams {
  username: string;
  email: string;
  avatar?: string;
}

export class UserManager {
  private static instance: UserManager | null = null;

  private userInfo: UserInfo | null = null;
  private isLoggedIn: boolean = false;
  private listeners: Array<() => void> = [];

  private constructor() {
    this.checkInitialLoginStatus();
  }

  public static getInstance(): UserManager {
    if (!UserManager.instance) {
      UserManager.instance = new UserManager();
    }
    return UserManager.instance;
  }

  public subscribe(listener: () => void): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  public unsubscribe(listener: () => void): void {
    const index: number = this.listeners.indexOf(listener);
    if (index > -1) {
      this.listeners.splice(index, 1);
    }
  }

  private notifyListeners(): void {
    this.listeners.forEach((listener: () => void) => {
      listener();
    });
    AppStorage.setOrCreate('userUpdateTime', Date.now());
    AppStorage.setOrCreate('userLoggedIn', this.isLoggedIn);
  }

  public getUserInfo(): UserInfo | null {
    return this.userInfo;
  }

  public getIsLoggedIn(): boolean {
    return this.isLoggedIn;
  }

  public getUsername(): string {
    if (this.userInfo && this.userInfo.nickname) {
      return this.userInfo.nickname;
    }
    return '个人用户';
  }

  public getEmail(): string {
    if (this.userInfo && this.userInfo.email) {
      return this.userInfo.email;
    }
    return '';
  }

  public getAvatar(): Resource | string {
    if (this.userInfo && this.userInfo.avatar) {
      return this.userInfo.avatar;
    }
    return $r('app.media.account');
  }

  public getUserId(): number {
    if (this.userInfo) {
      return this.userInfo.id;
    }
    return 0;
  }

  private async checkInitialLoginStatus(): Promise<void> {
    try {
      const loggedIn: boolean = await HttpUtil.isLoggedIn();
      if (loggedIn) {
        await this.refreshUserInfo();
      }
    } catch (error) {
      console.error('检查初始登录状态失败:', error);
      this.isLoggedIn = false;
    }
  }

  public async login(phone: string, password: string): Promise<boolean> {
    try {
      const loginParams: LoginRequestParams = {
        phone: phone,
        password: password
      };
      const response: LoginResponse = await HttpUtil.post<LoginResponse>('/api/user/login', loginParams);

      if (response.token) {
        await HttpUtil.saveToken(response.token);
        await this.refreshUserInfo();

        promptAction.showToast({ message: '登录成功' });
        return true;
      }
      return false;
    } catch (error) {
      console.error('登录失败:', error);
      if (String(error).includes('401') || String(error).includes('密码')) {
        promptAction.showToast({ message: '手机号或密码错误' });
      } else {
        promptAction.showToast({ message: '登录失败，请重试' });
      }
      return false;
    }
  }

  public async refreshUserInfo(): Promise<void> {
    try {
      const data: UserInfo = await HttpUtil.get<UserInfo>('/api/user/info');

      let avatarValue: Resource | string = $r('app.media.account');
      if (data.avatar && typeof data.avatar === 'string' && (data.avatar as string).length > 0) {
        avatarValue = data.avatar as string;
      }

      this.userInfo = {
        id: data.id || 0,
        phone: data.phone || '',
        nickname: data.nickname || '',
        avatar: avatarValue,
        email: data.email || ''
      };
      this.isLoggedIn = true;

      this.notifyListeners();
    } catch (error) {
      console.error('刷新用户信息失败:', error);
      throw new Error(String(error));
    }
  }

  public async updateProfile(nickname: string, email: string, avatar?: string): Promise<boolean> {
    try {
      const params: ProfileUpdateParams = {
        username: nickname,
        email: email
      };

      if (avatar && avatar.length > 0) {
        params.avatar = avatar;
      }

      await HttpUtil.put<void>('/api/user/profile', params);

      await this.refreshUserInfo();

      promptAction.showToast({ message: '资料更新成功' });
      return true;
    } catch (error) {
      console.error('更新用户资料失败:', error);
      promptAction.showToast({ message: '更新失败，请重试' });
      return false;
    }
  }

  public logout(): void {
    this.userInfo = null;
    this.isLoggedIn = false;

    this.notifyListeners();
    promptAction.showToast({ message: '已退出登录' });
  }

  public clearLocalData(): void {
    this.userInfo = null;
    this.isLoggedIn = false;
    this.notifyListeners();
  }
}

export default UserManager.getInstance();