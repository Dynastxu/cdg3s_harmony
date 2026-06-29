import { HOST } from "../config"
import { Goods, GoodsImage } from "../data/entity"
import { getDataFrom } from "../utils/network"

@Component
struct GoodDetailsPage {
  @Consume navPathStack: NavPathStack
  @State goods: Goods | null = null

  @Builder
  buildImages() {
    Swiper() {
      ForEach(this.goods?.images, (image: GoodsImage) => {
        Image(`http://${HOST}${image.imagePath}`)
          .width('100%')
          .objectFit(ImageFit.Auto)
      })
    }
    .width('100%')
    .loop(false)
  }

  @Builder
  buildBaseInfo() {
    Column() {
      // 价格
      Row() {
        Text('￥')
          .fontSize(14)
          .fontColor($r('app.color.theme'))
        Text(`${this.goods?.discountedPrice ? this.goods?.discountedPrice : this.goods?.price}`)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.theme'))
          .fontSize(28)
        if (this.goods?.discountedPrice) {
          Blank().width(2)
          Text(`￥${this.goods?.price}`)
            .fontSize(14)
            .fontColor($r("app.color.font_unimportant"))
            .decoration({
              type: TextDecorationType.LineThrough,
              color: $r("app.color.font_unimportant")
            })
        }

        Blank().layoutWeight(1)
      }
      .alignItems(VerticalAlign.Bottom)
      .height(50)
      .width('100%')
      .padding(10)

      Column() {
        // 名称
        Row() {
          Text(this.goods?.name)
            .fontWeight(FontWeight.Bold)
          Blank().layoutWeight(1)
        }
        .alignItems(VerticalAlign.Bottom)
      }
      .padding({left: 10, right: 10})
    }
    .width('100%')
    .borderRadius(5)
    .backgroundColor($r('app.color.background'))
  }

  @LocalBuilder
  imageButton(image: string | Resource, name: string | Resource) {
    Column() {
      Image(image)
        .objectFit(ImageFit.Contain)
        .width('100%')
        .layoutWeight(1)
        .height('100%')
      Text(name)
        .layoutWeight(1)
        .fontSize(10)
    }
    .alignItems(HorizontalAlign.Center)
    .width(30)
  }

  @Builder
  buildBottomBar() {
    Row({space: 10}) {
      this.imageButton(
        $r('app.media.message_circle_question_mark'),
        '客服'
      )
      this.imageButton(
        $r('app.media.star'),
        '收藏'
      )
      this.imageButton(
        $r('app.media.shopping_cart'),
        '购物车'
      )
      Button('加入购物车')
        .backgroundColor($r('app.color.theme'))
        .layoutWeight(1)
        .height('100%')
      Button('立即购买')
        .backgroundColor($r('app.color.theme'))
        .layoutWeight(1)
        .height('100%')
    }
    .height(60)
    .width('100%')
    .background($r('app.color.background'))
    .padding(10)
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        // 内容
        Scroll() {
          Column() {
            this.buildImages()
            Column() {
              this.buildBaseInfo()
            }
            .padding(10)

            Blank().layoutWeight(1)
          }
        }
        .backgroundColor('#f5f5f5')
        .height('100%')
        .width('100%')

        // 顶部栏
        Row() {
          // 返回按钮
          Image($r('app.media.chevron_left'))
            .backgroundColor('#44000000')
            .height(30)
            .borderRadius(10)
            .onClick(() => {
              this.navPathStack.pop()
            })
          Blank().layoutWeight(1)
        }
        .padding({ top: $r('app.integer.safe_area_top') , left: 10, right: 10})

        // 底部栏
        Column() {
          Blank().layoutWeight(1)
          this.buildBottomBar()
        }
        .width('100%')
      }
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      const goodsId = context.pathInfo.param as number
      getDataFrom<Goods>({
        url: `${HOST}/goods?id=${goodsId}`,
        onSuccess: (g: Goods) => {
          this.goods = g
        }
      })
    })
  }
}

@Builder
export function GoodDetailsPageBuilder() {
  GoodDetailsPage()
}