import hilog from "@ohos.hilog"

const DOMAIN = 0x0002

@Component
export struct ClassificationContent {
  @State selection: number = 0
  @State classificationNames: string[] = [
    '推荐', 'Xiaomi手机', 'REDMI手机', '手机配件', '平板',
    '智能穿戴', '电脑办公', '电视', '空调', '洗衣机',
    '冰箱', '厨房大电', '小家电', '智能家居', '出行运动',
    '车周边', '日用百货', '小米服务', '儿童用品', '有品精选'
  ]

  @Builder
  buildClassification(index: number, name: string | Resource) {
    Row() {
      Column()
        .backgroundColor(index == this.selection ? $r('app.color.theme') : Color.Transparent)
        .width(3)
        .height(20)
      Blank().width(10)
      Text(name)
        .fontColor(index == this.selection ? $r('app.color.font') : $r('app.color.font_sub'))
        .layoutWeight(1)
        .textAlign(TextAlign.Start)
        .fontWeight(index == this.selection ? FontWeight.Medium : FontWeight.Normal)
    }
    .onClick(() => {
      this.selection = index
      hilog.info(DOMAIN, 'select', `selected index: ${index}`)
    })
    .height(50)
  }

  build() {
    Column() {
      Row() {
        Row() {
          Image($r('app.media.search'))
            .height('100%')
            .objectFit(ImageFit.Auto)
            .padding(5)
            .margin({ left: 5 })
          Blank().width(3)
          Text('搜索商品')
            .layoutWeight(1)
            .fontColor($r('app.color.font_unimportant'))
        }
        .backgroundColor('#f7f7f7')
        .width('90%')
        .height('30')
        .borderRadius(15)
        .layoutWeight(1)

        Image($r('app.media.message_square_more'))
          .objectFit(ImageFit.Auto)
          .height('100%')
          .padding(15)
      }
      .height(50)
      .padding({ left: 20 })
      .alignItems(VerticalAlign.Center)

      Row() {
        Scroll() {
          Column() {
            ForEach(this.classificationNames, (name: string, index: number) => {
              this.buildClassification(index, name)
            })
          }
        }
        .layoutWeight(1)
        .height('100%')
        .scrollBar(BarState.Off)

        Scroll() {

        }
        .layoutWeight(2)
      }
      .layoutWeight(1)

    }
    .margin({ top: $r("app.integer.safe_area_top") })
  }
}