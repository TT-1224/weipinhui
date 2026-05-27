import { CardInfo, ProperColorData, SimpleCardInfo } from '../viewmodel/DataModels'

export let cardInfo1: CardInfo = new CardInfo(1, '5bdbe6b0-c34a-4c35-8c8f-19be0ef8104b', $r('app.string.woman_text_brand'), $r('app.media.man1'))
cardInfo1.price = 134
cardInfo1.desc = '[2026新款]秋冬男士牛仔裤男宽松直筒弹力休闲长裤子男装'
cardInfo1.proper = '黑色'
cardInfo1.size = 'M'
cardInfo1.numb = 1
cardInfo1.brand = '优衣库'

export let cardInfo2: CardInfo = new CardInfo(2, 'c8761280-4d67-4783-ab69-1c176b75fde0', $r('app.string.woman_text_brand'), $r('app.media.man2'))
cardInfo2.price = 124
cardInfo2.desc = '[2026新款]秋冬男士卫衣男宽松弹力休闲男装'
cardInfo2.proper = '黑色'
cardInfo2.size = 'M'
cardInfo2.numb = 1
cardInfo2.brand = 'ZARA'


export let cardInfo3: CardInfo = new CardInfo(3, '72464fc9-9448-43f3-9caf-2a3a6a2a07ed', $r('app.string.woman_text_brand'), $r('app.media.man3'))
cardInfo3.price = 99
cardInfo3.desc = '[2026新款]秋冬男士短袖男宽松弹力休闲男装'
cardInfo3.proper = '黑色'
cardInfo3.size = 'M'
cardInfo3.numb = 1
cardInfo3.brand = 'H&M'

export let cardInfo4: CardInfo = new CardInfo(4, '58fb40d9-4e36-4ff1-a1b8-7544b0334395', $r('app.string.woman_text_brand'), $r('app.media.man4'))
cardInfo4.price = 78
cardInfo4.desc = '[2026新款]秋冬男士羽绒服男修身男装'
cardInfo4.brand = '波司登'

export let cardInfo5: CardInfo = new CardInfo(5, '9c4b64d4-62c8-48e4-b685-97e8e5f50b21', $r('app.string.woman_text_brand'), $r('app.media.man5'))
cardInfo5.price = 123
cardInfo5.desc = '[2026新款]秋冬男士羽绒服男修身男装'
cardInfo5.brand = '鸭鸭'

export let cardInfo6: CardInfo = new CardInfo(6, '5b4d9098-0011-4383-9d5c-91f67ddfd83c', $r('app.string.woman_text_brand'), $r('app.media.man6'))
cardInfo6.price = 453
cardInfo6.desc = '[2026新款]秋冬男士羽绒服男修身男装'
cardInfo6.brand = '加拿大鹅'

export let cardInfo7: CardInfo = new CardInfo(7, '7b6fa990-e114-4361-a9ff-00d5a93bed07', $r('app.string.woman_text_brand'), $r('app.media.man7'))
cardInfo7.price = 765
cardInfo7.desc = '[2026新款]秋冬男士羽绒服男修身男装'
cardInfo7.brand = 'Moncler'

export let cardInfo8: CardInfo = new CardInfo(8, '8794cff1-094a-4b6d-8d04-d6238b806e77', $r('app.string.woman_text_brand'), $r('app.media.man8'))
cardInfo8.price = 66
cardInfo8.desc = '[2026新款]秋冬男士羽绒服男修身男装'
cardInfo8.brand = '李宁'

export let cardInfo9: CardInfo = new CardInfo(9, '8531161a-a2f9-4c06-8c94-18fd7bb16078', $r('app.string.woman_text_brand'), $r('app.media.man9'))
cardInfo9.price = 88
cardInfo9.desc = '[2026新款]秋冬男士羽绒服男修身男装'
cardInfo9.brand = '安踏'

export let cardInfo10: CardInfo = new CardInfo(10, '26b2a836-b826-4cb3-b247-119873ef4076', $r('app.string.woman_text_brand'), $r('app.media.man10'))
cardInfo10.price = 73
cardInfo10.desc = '[2026新款]秋冬男士羽绒服男修身男装'
cardInfo10.brand = '耐克'

export let cardInfo11: CardInfo = new CardInfo(11, '34f7f253-d136-4b88-87d7-724b5ec4d23c', $r('app.string.woman_text_brand'), $r('app.media.man11'))
cardInfo11.price = 90
cardInfo11.desc = '[2026新款]秋冬男士羽绒服男修身男装'
cardInfo11.brand = '阿迪达斯'

/*模拟瀑布流数据*/
export let mockCardInfo: Array<CardInfo> = [
  cardInfo1,cardInfo2,cardInfo3,cardInfo4,cardInfo5,cardInfo6,cardInfo7,cardInfo8,cardInfo9,cardInfo10,cardInfo11
]

export let properInfo1: ProperColorData = new ProperColorData(0, '', '烟黑', $r('app.media.man11'))
export let properInfo2: ProperColorData = new ProperColorData(1, '', '线灰', $r('app.media.man11'))
export let properInfo3: ProperColorData = new ProperColorData(2, '', '蓝色', $r('app.media.man11'))
export let properInfo4: ProperColorData = new ProperColorData(3, '', '深蓝', $r('app.media.man11'))
export let properInfo5: ProperColorData = new ProperColorData(4, '', '深灰', $r('app.media.man11'))

/*模拟商品颜色种类*/
export let mockProperColorData : Array<ProperColorData> = [
  properInfo1,properInfo2,properInfo3,properInfo4,properInfo5
]
/*模拟商品参数*/
export let mockProperSizeData : Array<number> = [
  28,29,30,31,32,33,34,36,38
]

export let sportCardInfo1: SimpleCardInfo = new SimpleCardInfo(0, '1', $r('app.media.s1'))
export let sportCardInfo2: SimpleCardInfo = new SimpleCardInfo(1, '2', $r('app.media.s2'))
export let sportCardInfo3: SimpleCardInfo = new SimpleCardInfo(2, '3', $r('app.media.s3'))
export let sportCardInfo4: SimpleCardInfo = new SimpleCardInfo(3, '4', $r('app.media.s4'))
/*模拟运动的数据*/
export let mockSportCardInfo : Array<SimpleCardInfo> = [
  sportCardInfo1, sportCardInfo2, sportCardInfo3, sportCardInfo4
]

export let tecCardInfo1: SimpleCardInfo = new SimpleCardInfo(0, '1', $r('app.media.tec1'))
export let tecCardInfo2: SimpleCardInfo = new SimpleCardInfo(1, '2', $r('app.media.tec2'))
export let tecCardInfo3: SimpleCardInfo = new SimpleCardInfo(2, '3', $r('app.media.tec3'))
export let tecCardInfo4: SimpleCardInfo = new SimpleCardInfo(3, '4', $r('app.media.tec4'))
export let tecCardInfo5: SimpleCardInfo = new SimpleCardInfo(4, '4', $r('app.media.tec5'))
/*模拟电脑、IT数据*/
export let mockTecCardInfo : Array<SimpleCardInfo> = [
  tecCardInfo1, tecCardInfo2, tecCardInfo3, tecCardInfo4, tecCardInfo5
]

/*模拟购物车数据*/
export let mockShopCardInfo: Array<CardInfo> = [
  cardInfo1,cardInfo2,cardInfo3
]


