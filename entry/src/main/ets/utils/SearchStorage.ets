import preferences from '@ohos.data.preferences';

const PREFERENCE_NAME = 'search_preferences';
const HISTORY_KEY = 'search_history';

// 基于preferences的持久化存储方案（已注释）
/*
export class SearchStorage {
  private static instance: SearchStorage;
  private preferences: preferences.Preferences | null = null;

  private constructor() {}

  public static getInstance(): SearchStorage {
    if (!SearchStorage.instance) {
      SearchStorage.instance = new SearchStorage();
    }
    return SearchStorage.instance;
  }

  // 初始化preferences
  public async init(): Promise<void> {
    try {
      this.preferences = await preferences.getPreferences(globalThis.abilityContext, PREFERENCE_NAME);
    } catch (error) {
      console.error('Failed to get preferences: ', error);
    }
  }

  // 保存历史记录
  public async saveHistory(history: string[]): Promise<void> {
    if (!this.preferences) {
      await this.init();
    }
    if (this.preferences) {
      try {
        await this.preferences.put(HISTORY_KEY, history);
        await this.preferences.flush();
      } catch (error) {
        console.error('Failed to save history: ', error);
      }
    }
  }

  // 获取历史记录
  public async getHistory(): Promise<string[]> {
    if (!this.preferences) {
      await this.init();
    }
    if (this.preferences) {
      try {
        const history = await this.preferences.get(HISTORY_KEY, []);
        return history as string[];
      } catch (error) {
        console.error('Failed to get history: ', error);
      }
    }
    return [];
  }

  // 清除历史记录
  public async clearHistory(): Promise<void> {
    if (!this.preferences) {
      await this.init();
    }
    if (this.preferences) {
      try {
        await this.preferences.delete(HISTORY_KEY);
        await this.preferences.flush();
      } catch (error) {
        console.error('Failed to clear history: ', error);
      }
    }
  }
}
*/
