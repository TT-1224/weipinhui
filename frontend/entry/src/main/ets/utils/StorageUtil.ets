import preferences from '@ohos.data.preferences'
import type { UserInfo } from '../model/User'
import { common } from '@kit.AbilityKit'

const PREF_NAME: string = 'wph_store'
const KEY_TOKEN: string = 'token'
const KEY_USER: string = 'user'

export class StorageUtil {
  private static async pref(): Promise<preferences.Preferences> {
    const ctx: common.UIAbilityContext = getContext() as common.UIAbilityContext
    return await preferences.getPreferences(ctx, PREF_NAME)
  }


  static async getToken(): Promise<string> {
    const p = await StorageUtil.pref()
    const t = await p.get(KEY_TOKEN, '')
    return typeof t === 'string' ? t : ''
  }

  static async setToken(token: string): Promise<void> {
    const p = await StorageUtil.pref()
    await p.put(KEY_TOKEN, token)
    await p.flush()
  }

  static async getUser(): Promise<UserInfo | undefined> {
    const p = await StorageUtil.pref()
    const raw = await p.get(KEY_USER, '')
    const s: string = typeof raw === 'string' ? raw : ''
    if (!s) {
      return undefined
    }
    try {
      return JSON.parse(s) as UserInfo
    } catch (e) {
      return undefined
    }
  }

  static async setUser(user?: UserInfo): Promise<void> {
    const p = await StorageUtil.pref()
    if (!user) {
      await p.put(KEY_USER, '')
      await p.flush()
      return
    }
    await p.put(KEY_USER, JSON.stringify(user))
    await p.flush()
  }

  static async clearAuth(): Promise<void> {
    const p = await StorageUtil.pref()
    await p.put(KEY_TOKEN, '')
    await p.put(KEY_USER, '')
    await p.flush()
  }

  static async getSearchHistory(): Promise<string[]> {
    const p = await StorageUtil.pref()
    const raw = await p.get('search_history', '')
    const s: string = typeof raw === 'string' ? raw : ''
    if (!s) {
      return []
    }
    try {
      return JSON.parse(s) as string[]
    } catch (e) {
      return []
    }
  }

  static async setSearchHistory(history: string[]): Promise<void> {
    const p = await StorageUtil.pref()
    await p.put('search_history', JSON.stringify(history))
    await p.flush()
  }

  static async clearSearchHistory(): Promise<void> {
    const p = await StorageUtil.pref()
    await p.put('search_history', JSON.stringify([]))
    await p.flush()
  }
}

