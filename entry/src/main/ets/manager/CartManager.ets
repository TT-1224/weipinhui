import HttpUtil from '../utils/HttpUtil';
import promptAction from '@ohos.promptAction';

interface CartItemInfo {
  id: number;
  cartId: string;
  goodsId: number;
  name: string;
  price: number;
  cover: Resource | string;
  quantity: number;
  properColor: string;
  properSize: string;
}

interface AddToCartParams {
  goodsId: number;
  quantity: number;
  properColor: string;
  properSize: string;
}

interface CartListResponse {
  list: CartItemInfo[];
  totalCount: number;
  totalAmount: number;
}

interface UpdateCartParams {
  cartId: string;
  checked: number;
}

interface RemoveCartParams {
  cartId: string;
}

export class CartManager {
  private static instance: CartManager | null = null;
  private cartItems: CartItemInfo[] = [];
  private totalCount: number = 0;
  private totalAmount: number = 0;
  private listeners: Array<() => void> = [];

  private constructor() {
    this.loadCartFromStorage();
  }

  public static getInstance(): CartManager {
    if (!CartManager.instance) {
      CartManager.instance = new CartManager();
    }
    return CartManager.instance;
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
    AppStorage.setOrCreate('cartUpdateTime', Date.now());
    AppStorage.setOrCreate('cartCount', this.totalCount);
  }

  public getCartCount(): number {
    return this.totalCount;
  }

  public getTotalAmount(): number {
    return this.totalAmount;
  }

  public getCartItems(): CartItemInfo[] {
    return [...this.cartItems];
  }

  private loadCartFromStorage(): void {
    const storedTime: number = AppStorage.get<number>('cartUpdateTime') || 0;
    if (storedTime > 0) {
      this.refreshCartData();
    }
  }

  public async refreshCartData(): Promise<void> {
    try {
      const data: CartListResponse = await HttpUtil.get<CartListResponse>('/api/cart/list');
      this.cartItems = data.list || [];
      this.totalCount = data.totalCount || 0;
      this.totalAmount = data.totalAmount || 0;
      this.notifyListeners();
    } catch (error) {
      console.error('刷新购物车数据失败:', error);
    }
  }

  public async addToCart(params: AddToCartParams): Promise<void> {
    try {
      await HttpUtil.post<void>('/api/cart/add', params);

      this.totalCount += params.quantity;
      this.totalAmount += params.quantity * 0;

      await this.refreshCartData();

      promptAction.showToast({ message: '已加入购物车' });
    } catch (error) {
      console.error('加入购物车失败:', error);
      if (String(error).includes('401') || String(error).includes('未登录')) {
        promptAction.showToast({ message: '请先登录' });
      } else {
        promptAction.showToast({ message: '加入购物车失败' });
      }
      throw new Error(String(error));
    }
  }

  public async updateCartItem(cartId: string, checked: boolean): Promise<boolean> {
    try {
      const params: UpdateCartParams = { cartId: cartId, checked: checked ? 1 : 0 };
      await HttpUtil.put<void>('/api/cart/update', params);
      await this.refreshCartData();
      return true;
    } catch (error) {
      console.error('更新购物车项失败:', error);
      promptAction.showToast({ message: '操作失败' });
      return false;
    }
  }

  public async removeCartItem(cartId: string): Promise<boolean> {
    try {
      const params: RemoveCartParams = { cartId: cartId };
      await HttpUtil.delete<void>('/api/cart/remove', params);
      promptAction.showToast({ message: '删除成功' });
      await this.refreshCartData();
      return true;
    } catch (error) {
      console.error('删除购物车项失败:', error);
      promptAction.showToast({ message: '删除失败' });
      return false;
    }
  }

  public clearLocalData(): void {
    this.cartItems = [];
    this.totalCount = 0;
    this.totalAmount = 0;
    this.notifyListeners();
  }
}

export default CartManager.getInstance();