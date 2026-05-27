export class CardInfo {
  id: number = 0;
  cardId: string = '';
  name: string | Resource = ''
  image: Resource | null = null;
  price: number = 0;
  desc: string | Resource = '';
  proper: string | Resource = '';
  size: string | number = '';
  numb: number = 0;
  brand: string = '';

  constructor(id: number = 0, cardId: string, name: string | Resource = '', image: Resource | null = null) {
    this.id = id;
    this.cardId = cardId;
    this.name = name;
    this.image = image;
  }
}

export class ProperColorData {
  id: number = 0;
  cardId: string = '';
  name: string | Resource = ''
  image: Resource | null = null;

  constructor(id: number = 0, cardId: string, name: string | Resource = '', image: Resource | null = null) {
    this.id = id;
    this.cardId = cardId;
    this.name = name;
    this.image = image;
  }
}

export class SimpleCardInfo {
  id: number = 0;
  name: string | Resource = ''
  image: Resource | null = null;

  constructor(id: number = 0, name: string | Resource = '', image: Resource | null = null) {
    this.id = id;
    this.name = name;
    this.image = image;
  }
}

// 热搜榜单项类型
export interface HotSearchItem {
  id: number;
  rank: number;
  keyword: string;
  hot: boolean;
}

// 聊天消息接口
export interface ChatMessage {
  id: string;
  senderId: string;
  senderName: string;
  receiverId: string;
  content: string;
  type: 'text' | 'image' | 'voice';
  timestamp: string;
  isRead: boolean;
}

// 聊天会话接口
export interface ChatSession {
  id: string;
  sellerId: string;
  sellerName: string;
  lastMessage: ChatMessage;
  unreadCount: number;
  timestamp: string;
}

// 系统通知接口
export interface SystemNotification {
  id: string;
  title: string;
  content: string;
  timestamp: string;
  unreadCount: number;
}