
import router from '@ohos.router';
import CommonConstants from '../../constants/CommonConstants';
import { WaterFlowDataSource } from '../../datasource/WaterFlowDataSource'
import ItemData from '../../viewmodel/ItemData';
@Component
export default struct ManPage {
  @State maxSize: number = 320;
  @State fontSize: number = 24;
  scroller: Scroller = new Scroller();
  datasource: WaterFlowDataSource = new WaterFlowDataSource();
  private itemHeightArray: number[] = [];
  @State num : number = 0;

  @Builder itemFoot() {
    Column() {
      Text('已经到底啦~')
        .fontSize(12)
        .fontColor('#999999')
        .backgroundColor(Color.Transparent)
        .width(CommonConstants.FULL_PARENT)
        .height(40)
        .textAlign(TextAlign.Center)
        .align(Alignment.Center)
        .margin({ top: 10, bottom: 10 })
    }
  }

  getSize(): number {
    let size = this.maxSize - Math.round(Math.random() * 40);
    return size;
  }

  getItemSizeArray(): void {
    for (let i = 0; i < 15; i++) {
      this.itemHeightArray.push(this.getSize())
    }
  }

  aboutToAppear() {
    this.getItemSizeArray()
  }

  build() {
    WaterFlow({ footer: () => this.itemFoot() }) {
      LazyForEach(this.datasource, (item: ItemData, index: number) => {
        FlowItem() {
          Column() {
            Image(item.img)
              .objectFit(ImageFit.Cover)
              .width('100%')
              .height(this.itemHeightArray[index] * 0.65)
              .borderRadius({ topLeft: 12, topRight: 12 })

            Column() {
              if (item.brandName) {
                Text(item.brandName)
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
                  .margin({ top: 8, bottom: 4 })
              }

              Row() {
                Text(`¥`)
                  .fontSize(12)
                  .fontColor('#FF2D55')
                  .fontWeight(FontWeight.Bold)

                Text(`${typeof item.cardPrice === 'number' ? item.cardPrice.toFixed(0) : '0'}`)
                  .fontSize(18)
                  .fontColor('#FF2D55')
                  .fontWeight(FontWeight.Bold)

                if (typeof item.cardPrice === 'number' && item.cardPrice > 100) {
                  Text(`¥${(item.cardPrice * 1.3).toFixed(0)}`)
                    .fontSize(11)
                    .fontColor('#999999')
                    .decoration({ type: TextDecorationType.LineThrough })
                    .margin({ left: 6 })
                }

                Blank()
              }
              .width('100%')
              .alignItems(VerticalAlign.Bottom)
            }
            .padding({ left: 10, right: 10, bottom: 10 })
            .alignItems(HorizontalAlign.Start)
          }
          .borderRadius(12)
          .backgroundColor('#FFFFFF')
          .shadow({
            radius: 8,
            color: '#0D000005',
            offsetX: 0,
            offsetY: 2
          })
          .onClick(() => {
            const cardId = item.others ? String(item.others) : '';
            router.pushUrl({
              url: 'pages/components/CardDetailPage',
              params: { cardId: cardId }
            })
          })
        }
        .height(this.itemHeightArray[index])
        .width('100%')
      }, (item: ItemData, index: number) => index.toString())
    }
    .columnsTemplate("1fr 1fr")
    .itemConstraintSize({
      minWidth: 0,
      maxWidth: '100%',
      minHeight: 0,
      maxHeight: '100%'
    })
    .columnsGap(10)
    .rowsGap(10)
    .onReachEnd(() => {
      console.info('已到达底部');
    })
    .padding({ left: 10, right: 10, top: 8, bottom: 8 })
    .width('100%')
    .height(CommonConstants.FULL_PARENT)
    .layoutDirection(FlexDirection.Column)
    .backgroundColor('#F5F5F7')
  }
}
