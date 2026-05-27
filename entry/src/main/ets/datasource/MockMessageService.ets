import { ChatMessage, ChatSession, SystemNotification } from '../viewmodel/DataModels';

// 模拟系统通知数据
const mockSystemNotifications: SystemNotification[] = [
  {
    id: 'sys_001',
    title: '互动通知',
    content: '客服回复了信息',
    timestamp: '2024-06-08 14:30',
    unreadCount: 3
  },
  {
    id: 'sys_002',
    title: '商城助手',
    content: '在商城，大量商品折扣等待你领取...',
    timestamp: '2024-06-08 10:15',
    unreadCount: 1
  },
  {
    id: 'sys_003',
    title: '会员服务',
    content: '会员客服发送一条消息给你',
    timestamp: '2024-06-08 09:00',
    unreadCount: 1
  }
];

// 模拟聊天会话数据
const mockChatSessions: ChatSession[] = [
  {
    id: 'session_001',
    sellerId: 'seller_001',
    sellerName: '女装精品店',
    lastMessage: {
      id: 'msg_001',
      senderId: 'seller_001',
      senderName: '女装精品店',
      receiverId: 'user_001',
      content: '您的订单已发货，请注意查收',
      type: 'text',
      timestamp: '2024-06-08 16:45',
      isRead: false
    } as ChatMessage,
    unreadCount: 2,
    timestamp: '2024-06-08 16:45'
  },
  {
    id: 'session_002',
    sellerId: 'seller_002',
    sellerName: '时尚服饰店',
    lastMessage: {
      id: 'msg_002',
      senderId: 'user_001',
      senderName: '用户',
      receiverId: 'seller_002',
      content: '这件衣服有黑色吗？',
      type: 'text',
      timestamp: '2024-06-08 15:30',
      isRead: true
    } as ChatMessage,
    unreadCount: 0,
    timestamp: '2024-06-08 15:30'
  },
  {
    id: 'session_003',
    sellerId: 'seller_003',
    sellerName: '男装旗舰店',
    lastMessage: {
      id: 'msg_003',
      senderId: 'seller_003',
      senderName: '男装旗舰店',
      receiverId: 'user_001',
      content: '新品上市，欢迎选购',
      type: 'text',
      timestamp: '2024-06-08 14:15',
      isRead: false
    } as ChatMessage,
    unreadCount: 1,
    timestamp: '2024-06-08 14:15'
  }
];

// 模拟聊天消息数据
const mockChatMessages: Map<string, ChatMessage[]> = new Map<string, ChatMessage[]>([
  ['seller_001', [
      {
        id: 'msg_004',
        senderId: 'seller_001',
        senderName: '女装精品店',
        receiverId: 'user_001',
        content: '您好，欢迎光临女装精品店',
        type: 'text',
        timestamp: '2024-06-08 14:00',
        isRead: true
      } as ChatMessage,
      {
        id: 'msg_005',
        senderId: 'user_001',
        senderName: '用户',
        receiverId: 'seller_001',
        content: '请问这件商品有货吗？',
        type: 'text',
        timestamp: '2024-06-08 14:05',
        isRead: true
      } as ChatMessage,
      {
        id: 'msg_006',
        senderId: 'seller_001',
        senderName: '女装精品店',
        receiverId: 'user_001',
        content: '您好，有的，请问您需要什么尺码？',
        type: 'text',
        timestamp: '2024-06-08 14:10',
        isRead: true
      } as ChatMessage,
      {
        id: 'msg_007',
        senderId: 'user_001',
        senderName: '用户',
        receiverId: 'seller_001',
        content: '我需要M码',
        type: 'text',
        timestamp: '2024-06-08 14:15',
        isRead: true
      } as ChatMessage,
      {
        id: 'msg_008',
        senderId: 'seller_001',
        senderName: '女装精品店',
        receiverId: 'user_001',
        content: '好的，M码有现货',
        type: 'text',
        timestamp: '2024-06-08 16:40',
        isRead: false
      } as ChatMessage,
      {
        id: 'msg_001',
        senderId: 'seller_001',
        senderName: '女装精品店',
        receiverId: 'user_001',
        content: '您的订单已发货，请注意查收',
        type: 'text',
        timestamp: '2024-06-08 16:45',
        isRead: false
      } as ChatMessage
    ] as ChatMessage[]],
  ['seller_002', [
      {
        id: 'msg_009',
        senderId: 'seller_002',
        senderName: '时尚服饰店',
        receiverId: 'user_001',
        content: '您好，时尚服饰店为您服务',
        type: 'text',
        timestamp: '2024-06-08 15:00',
        isRead: true
      } as ChatMessage,
      {
        id: 'msg_010',
        senderId: 'user_001',
        senderName: '用户',
        receiverId: 'seller_002',
        content: '这件衣服有黑色吗？',
        type: 'text',
        timestamp: '2024-06-08 15:30',
        isRead: true
      } as ChatMessage
    ] as ChatMessage[]],
  ['seller_003', [
      {
        id: 'msg_011',
        senderId: 'seller_003',
        senderName: '男装旗舰店',
        receiverId: 'user_001',
        content: '新品上市，欢迎选购',
        type: 'text',
        timestamp: '2024-06-08 14:15',
        isRead: false
      } as ChatMessage
    ] as ChatMessage[]]
]);

// 模拟卖家回复内容
const mockSellerReplies: string[] = [
  '您好，有什么可以帮助您的吗？',
  '好的，我马上为您查询',
  '请问您需要什么尺码/颜色？',
  '稍等，我帮您确认一下库存',
  '您的订单正在处理中',
  '感谢您的咨询，祝您购物愉快',
  '这件商品目前有促销活动，您可以考虑一下',
  '好的，我会尽快为您安排发货'
];

// 获取系统通知
export function getSystemNotifications(): SystemNotification[] {
  return mockSystemNotifications;
}

// 获取聊天会话列表
export function getChatSessions(): ChatSession[] {
  // 按时间倒序排序
  return [...mockChatSessions].sort((a, b) => {
    return new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime();
  });
}

// 获取聊天消息
export function getChatMessages(sellerId: string): ChatMessage[] {
  return mockChatMessages.get(sellerId) || [];
}

// 添加聊天消息
export function addChatMessage(sellerId: string, message: ChatMessage): void {
  if (!mockChatMessages.has(sellerId)) {
    mockChatMessages.set(sellerId, []);
  }
  const messages = mockChatMessages.get(sellerId)!;
  messages.push(message);
  
  // 更新会话列表中的最后一条消息
  const session = mockChatSessions.find(s => s.sellerId === sellerId);
  if (session) {
    session.lastMessage = message;
    session.timestamp = message.timestamp;
    if (message.senderId !== 'user_001') {
      session.unreadCount++;
    }
  }
}

// 模拟卖家回复
export function simulateSellerReply(sellerId: string, receiverId: string): ChatMessage {
  const randomReply = mockSellerReplies[Math.floor(Math.random() * mockSellerReplies.length)];
  const replyMessage: ChatMessage = {
    id: `msg_${Date.now()}`,
    senderId: sellerId,
    senderName: mockChatSessions.find(s => s.sellerId === sellerId)?.sellerName || '卖家',
    receiverId: receiverId,
    content: randomReply,
    type: 'text',
    timestamp: new Date().toISOString().slice(0, 19).replace('T', ' '),
    isRead: false
  };
  
  addChatMessage(sellerId, replyMessage);
  return replyMessage;
}

// 标记会话为已读
export function markSessionAsRead(sellerId: string): void {
  const session = mockChatSessions.find(s => s.sellerId === sellerId);
  if (session) {
    session.unreadCount = 0;
    
    // 标记该会话的所有消息为已读
    const messages = mockChatMessages.get(sellerId);
    if (messages) {
      messages.forEach(msg => {
        if (msg.senderId !== 'user_001') {
          msg.isRead = true;
        }
      });
    }
  }
}

// 获取未读消息总数
export function getTotalUnreadCount(): number {
  return mockChatSessions.reduce((total, session) => total + session.unreadCount, 0) +
         mockSystemNotifications.reduce((total, notification) => total + notification.unreadCount, 0);
}
