import HttpUtil from '../utils/HttpUtil';
import promptAction from '@ohos.promptAction';

export interface OrderInfo {
  id: number;
  orderNo: string;
  userId: number;
  totalAmount: number;
  status: number; // 0待付款/1待发货/2待收货/3待评价/4已取消
  remark: string;
  createTime: string;
  updateTime: string;
}

interface OrderItem {
  id: number;
  orderId: number;
  goodsId: number;
  goodsName: string;
  goodsImage: string | Resource;
  goodsPrice: number;
  quantity: number;
  properColor: string;
  properSize: string;
}

interface OrderDetail {
  order: OrderInfo;
  items: OrderItem[];
}

interface CreateCartOrderParams {
  cartIds: number[];
  addressId?: number;
  remark?: string;
}

interface CreateDirectOrderParams {
  goodsId: number;
  quantity: number;
  properColor: string;
  properSize: string;
  addressId?: number;
}

interface UpdateStatusParams {
  status: number;
}

export class OrderManager {
  private static instance: OrderManager | null = null;

  private orderList: OrderInfo[] = [];
  private orderCountMap: Record<number, number> = { 0: 0, 1: 0, 2: 0 };
  private listeners: Array<() => void> = [];

  private constructor() {}

  public static getInstance(): OrderManager {
    if (!OrderManager.instance) {
      OrderManager.instance = new OrderManager();
    }
    return OrderManager.instance;
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
    AppStorage.setOrCreate('orderUpdateTime', Date.now());
  }

  public getOrderList(): OrderInfo[] {
    return [...this.orderList];
  }

  public getOrderCountByStatus(status: number): number {
    return this.orderCountMap[status] || 0;
  }

  /**
   * 从购物车创建订单
   * @param cartIds 购物车项ID列表
   * @param addressId 收货地址ID（必填）
   * @param remark 订单备注
   */
  public async createOrderFromCart(cartIds: number[], addressId: number, remark?: string): Promise<OrderInfo | null> {
    try {
      if (!addressId || addressId <= 0) {
        promptAction.showToast({ message: '请选择收货地址' })
        return null
      }

      const params: CreateCartOrderParams = {
        cartIds: cartIds,
        addressId: addressId,
        remark: remark || ''
      };

      const order: OrderInfo = await HttpUtil.post<OrderInfo>('/api/order/create', params);

      promptAction.showToast({ message: '订单创建成功' });

      await this.refreshOrderData();

      return order;
    } catch (error) {
      console.error('创建订单失败:', error);
      if (String(error).includes('401') || String(error).includes('未登录')) {
        promptAction.showToast({ message: '请先登录' });
      } else {
        promptAction.showToast({ message: '创建订单失败' });
      }
      return null;
    }
  }

  /**
   * 立即购买创建订单
   * @param goodsId 商品ID
   * @param quantity 购买数量
   * @param properColor 颜色规格
   * @param properSize 尺码规格
   * @param addressId 收货地址ID（必填）
   */
  public async createDirectOrder(goodsId: number, quantity: number,
                                   properColor: string, properSize: string,
                                   addressId: number): Promise<OrderInfo | null> {
    try {
      if (!addressId || addressId <= 0) {
        promptAction.showToast({ message: '请选择收货地址' })
        return null
      }

      const params: CreateDirectOrderParams = {
        goodsId: goodsId,
        quantity: quantity,
        properColor: properColor,
        properSize: properSize,
        addressId: addressId
      };

      const order: OrderInfo = await HttpUtil.post<OrderInfo>('/api/order/direct', params);

      promptAction.showToast({ message: '订单创建成功' });

      await this.refreshOrderData();

      return order;
    } catch (error) {
      console.error('创建订单失败:', error);
      promptAction.showToast({ message: '创建订单失败' });
      return null;
    }
  }

  /**
   * 获取订单列表（按状态筛选）
   */
  public async getOrderListByStatus(status?: number): Promise<OrderInfo[]> {
    try {
      let url: string = '/api/order/list';
      if (status !== undefined && status >= -1) {
        url += '?status=' + status;
      }

      const data: OrderInfo[] = await HttpUtil.get<OrderInfo[]>(url);

      if (status === undefined || status === -1) {
        this.orderList = data || [];
      }

      return data || [];
    } catch (error) {
      console.error('获取订单列表失败:', error);
      return [];
    }
  }

  /**
   * 获取订单详情
   */
  public async getOrderDetail(orderId: number): Promise<OrderDetail | null> {
    try {
      const data: OrderDetail = await HttpUtil.get<OrderDetail>('/api/order/detail/' + orderId);
      return data;
    } catch (error) {
      console.error('获取订单详情失败:', error);
      return null;
    }
  }

  /**
   * 更新订单状态
   */
  public async updateOrderStatus(orderId: number, status: number): Promise<boolean> {
    try {
      const params: UpdateStatusParams = { status: status };
      await HttpUtil.put<void>('/api/order/status/' + orderId, params);

      let statusText: string = '';
      switch (status) {
        case 0:
          statusText = '待付款';
          break;
        case 1:
          statusText = '待发货';
          break;
        case 2:
          statusText = '待收货';
          break;
        case 3:
          statusText = '待评价';
          break;
        default:
          statusText = '';
      }

      if (statusText.length > 0) {
        promptAction.showToast({ message: '订单状态更新为：' + statusText });
      }

      await this.refreshOrderData();

      return true;
    } catch (error) {
      console.error('更新订单状态失败:', error);
      promptAction.showToast({ message: '操作失败' });
      return false;
    }
  }

  /**
   * 删除订单（取消）
   */
  public async deleteOrder(orderId: number): Promise<boolean> {
    try {
      await HttpUtil.delete<void>('/api/order/' + orderId);

      promptAction.showToast({ message: '订单已取消' });

      await this.refreshOrderData();

      return true;
    } catch (error) {
      console.error('删除订单失败:', error);
      promptAction.showToast({ message: '删除失败' });
      return false;
    }
  }

  /**
   * 刷新订单数据（包括列表和统计）
   */
  public async refreshOrderData(): Promise<void> {
    try {
      const listPromise: Promise<OrderInfo[]> = this.getOrderListByStatus(-1);
      const countPromise: Promise<Record<number, number>> = this.loadOrderCount();

      const results: [OrderInfo[], Record<number, number>] = await Promise.all([listPromise, countPromise]);
      const list: OrderInfo[] = results[0];
      const countMap: Record<number, number> = results[1];

      this.orderList = list;
      this.orderCountMap = countMap;

      this.notifyListeners();
    } catch (error) {
      console.error('刷新订单数据失败:', error);
    }
  }

  /**
   * 加载各状态订单数量统计
   */
  private async loadOrderCount(): Promise<Record<number, number>> {
    try {
      const data: Record<number, number> = await HttpUtil.get<Record<number, number>>('/api/order/count');
      return data || { 0: 0, 1: 0, 2: 0 };
    } catch (error) {
      console.error('加载订单统计失败:', error);
      return { 0: 0, 1: 0, 2: 0 };
    }
  }

  /**
   * 获取订单状态文本
   */
  public getStatusText(status: number): string {
    switch (status) {
      case 0:
        return '待付款';
      case 1:
        return '待发货';
      case 2:
        return '待收货';
      case 3:
        return '待评价';
      case 4:
        return '已取消';
      default:
        return '未知';
    }
  }

  /**
   * 清空本地数据
   */
  public clearLocalData(): void {
    this.orderList = [];
    this.orderCountMap = { 0: 0, 1: 0, 2: 0 };
    this.notifyListeners();
  }
}

export default OrderManager.getInstance();