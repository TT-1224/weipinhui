import HttpUtil from '../utils/HttpUtil';
import promptAction from '@ohos.promptAction';

// ✅ 导出：供其他页面使用
export interface FavoriteItem {
  id: number;
  userId: number;
  goodsId: number;
  createTime: string;
}

interface FavoriteListResponse {
  list: FavoriteItem[];
  totalCount: number;
}

// ✅ 新增：检查收藏状态响应接口
interface CheckFavoritedResponse {
  isFavorited: boolean;
}

// ✅ 新增：收藏数量响应接口
interface FavoriteCountResponse {
  count: number;
}

// ✅ 新增：批量检查请求参数接口
interface BatchCheckRequest {
  goodsIds: number[];
}

export class FavoriteManager {
  private static instance: FavoriteManager | null = null;

  private favoriteList: FavoriteItem[] = [];
  private favoriteGoodsIdSet: Set<number> = new Set<number>();
  private totalCount: number = 0;
  private listeners: Array<() => void> = [];

  private constructor() {
    this.loadFromStorage();
  }

  public static getInstance(): FavoriteManager {
    if (!FavoriteManager.instance) {
      FavoriteManager.instance = new FavoriteManager();
    }
    return FavoriteManager.instance;
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
    AppStorage.setOrCreate('favoriteUpdateTime', Date.now());
    AppStorage.setOrCreate('favoriteCount', this.totalCount);
  }

  public getFavoriteCount(): number {
    return this.totalCount;
  }

  public getFavoriteList(): FavoriteItem[] {
    return [...this.favoriteList];
  }

  public getFavoriteGoodsIdSet(): Set<number> {
    return new Set(this.favoriteGoodsIdSet);
  }

  /**
   * 检查指定商品是否已收藏
   */
  public isFavorited(goodsId: number): boolean {
    return this.favoriteGoodsIdSet.has(goodsId);
  }

  /**
   * 刷新收藏数据（从服务器加载）
   * ✅ 注意：此方法由 FavoritePage.loadFavoriteData() 调用
   * 调用方负责设置防重入标志，避免循环通知
   */
  public async refreshFavoriteData(): Promise<void> {
    try {
      const data: FavoriteListResponse = await HttpUtil.get<FavoriteListResponse>('/api/favorite/list');
      
      this.favoriteList = data.list || [];
      this.totalCount = data.totalCount || 0;
      
      // 更新商品ID集合（用于快速查找）
      this.favoriteGoodsIdSet = new Set(this.favoriteList.map((item: FavoriteItem) => item.goodsId));
      
      // ✅ 通知监听者数据已更新
      // 注意：调用方（FavoritePage）应已设置 isRefreshing=true 防重入
      // 所以这次通知会被跳过，避免循环刷新
      this.notifyListeners();
      
      console.info('✅ [FavoriteManager] 收藏数据刷新完成, 数量:', this.totalCount);
    } catch (error) {
      console.error('❌ [FavoriteManager] 刷新收藏数据失败:', error);
    }
  }

  /**
   * 添加收藏
   */
  public async addFavorite(goodsId: number): Promise<boolean> {
    try {
      const emptyParams: Record<string, Object> = {};
      await HttpUtil.post<void>(`/api/favorite/add/${goodsId}`, emptyParams);

      // 更新本地数据
      this.favoriteGoodsIdSet.add(goodsId);
      this.totalCount++;
      
      // 添加到列表头部
      const newFavorite: FavoriteItem = {
        id: Date.now(), // 临时ID，刷新后会更新
        goodsId: goodsId,
        userId: 0,
        createTime: new Date().toISOString()
      };
      this.favoriteList.unshift(newFavorite);

      this.notifyListeners();

      const toastMsg1: promptAction.ShowToastOptions = { message: '已添加到收藏夹' };
      promptAction.showToast(toastMsg1);
      console.info('✅ [FavoriteManager] 添加收藏成功, goodsId:', goodsId);

      return true;
    } catch (error) {
      console.error('❌ [FavoriteManager] 添加收藏失败:', error);
      
      if (String(error).includes('409') || String(error).includes('已在收藏夹中')) {
        const toastMsg2: promptAction.ShowToastOptions = { message: '该商品已在收藏夹中' };
        promptAction.showToast(toastMsg2);
      } else {
        const toastMsg3: promptAction.ShowToastOptions = { message: '添加收藏失败' };
        promptAction.showToast(toastMsg3);
      }
      
      return false;
    }
  }

  /**
   * 取消收藏
   */
  public async removeFavorite(goodsId: number): Promise<boolean> {
    try {
      await HttpUtil.delete<void>(`/api/favorite/${goodsId}`);

      // 更新本地数据
      this.favoriteGoodsIdSet.delete(goodsId);
      this.totalCount--;
      
      // 从列表中移除
      this.favoriteList = this.favoriteList.filter((item: FavoriteItem) => item.goodsId !== goodsId);

      this.notifyListeners();

      promptAction.showToast({ message: '已取消收藏' });
      console.info('✅ [FavoriteManager] 取消收藏成功, goodsId:', goodsId);

      return true;
    } catch (error) {
      console.error('❌ [FavoriteManager] 取消收藏失败:', error);
      promptAction.showToast({ message: '取消收藏失败' });
      return false;
    }
  }

  /**
   * 检查单个商品收藏状态（从服务器实时查询）
   */
  public async checkFavorited(goodsId: number): Promise<boolean> {
    try {
      const data: CheckFavoritedResponse = await HttpUtil.get<CheckFavoritedResponse>(`/api/favorite/check/${goodsId}`);
      
      // 同步更新本地缓存
      if (data.isFavorited) {
        this.favoriteGoodsIdSet.add(goodsId);
      } else {
        this.favoriteGoodsIdSet.delete(goodsId);
      }
      
      return data.isFavorited;
    } catch (error) {
      console.error('❌ [FavoriteManager] 检查收藏状态失败:', error);
      return false;
    }
  }

  /**
   * 批量检查商品收藏状态
   */
  public async batchCheckFavorited(goodsIds: number[]): Promise<Map<number, boolean>> {
    try {
      const batchParams: BatchCheckRequest = { goodsIds: goodsIds };
      const data: Map<number, boolean> = await HttpUtil.post<Map<number, boolean>>('/api/favorite/batchCheck', batchParams);
      
      // 同步更新本地缓存
      data.forEach((isFavorited: boolean, id: number) => {
        if (isFavorited) {
          this.favoriteGoodsIdSet.add(id);
        } else {
          this.favoriteGoodsIdSet.delete(id);
        }
      });
      
      return data;
    } catch (error) {
      console.error('❌ [FavoriteManager] 批量检查收藏状态失败:', error);
      return new Map();
    }
  }

  /**
   * 获取收藏数量（从服务器）
   */
  public async loadFavoriteCount(): Promise<number> {
    try {
      const data: FavoriteCountResponse = await HttpUtil.get<FavoriteCountResponse>('/api/favorite/count');
      this.totalCount = data.count || 0;
      return this.totalCount;
    } catch (error) {
      console.error('❌ [FavoriteManager] 加载收藏数量失败:', error);
      return 0;
    }
  }

  /**
   * 从本地存储加载
   */
  private loadFromStorage(): void {
    // 首次加载时从服务器获取
    this.refreshFavoriteData();
  }

  /**
   * 清空本地数据
   */
  public clearLocalData(): void {
    this.favoriteList = [];
    this.favoriteGoodsIdSet.clear();
    this.totalCount = 0;
    this.notifyListeners();
  }

  /**
   * 切换收藏状态（添加/取消）
   */
  public async toggleFavorite(goodsId: number): Promise<boolean> {
    if (this.isFavorited(goodsId)) {
      return await this.removeFavorite(goodsId);
    } else {
      return await this.addFavorite(goodsId);
    }
  }
}

export default FavoriteManager.getInstance();
