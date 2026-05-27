import promptAction from '@ohos.promptAction'

export class ToastUtil {
  static success(message: string, duration: 'short' | 'long' = 'short'): void {
    promptAction.showToast({
      message: message,
      duration: duration === 'long' ? 2000 : 1500,
      bottom: 100
    })
  }

  static error(message: string, duration: 'short' | 'long' = 'short'): void {
    promptAction.showToast({
      message: `错误: ${message}`,
      duration: duration === 'long' ? 2000 : 1500,
      bottom: 100
    })
  }

  static warning(message: string, duration: 'short' | 'long' = 'short'): void {
    promptAction.showToast({
      message: `警告: ${message}`,
      duration: duration === 'long' ? 2000 : 1500,
      bottom: 100
    })
  }

  static info(message: string, duration: 'short' | 'long' = 'short'): void {
    promptAction.showToast({
      message: message,
      duration: duration === 'long' ? 2000 : 1500,
      bottom: 100
    })
  }
}