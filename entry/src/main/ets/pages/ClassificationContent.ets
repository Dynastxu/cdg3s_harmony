import hilog from "@ohos.hilog"
import { HOST } from "../config"
import {
  ClassificationDataSource,
  ClassificationRootDataSource,
  ClassificationGoodsDataSource
} from "../data/ClassificationDataSource"
import { Classification, Goods } from "../data/entity"

const DOMAIN = 0x0002

enum GoodsItemBuildType {
  List,
  Grid
}

@Component
export struct ClassificationContent {
  @State selection: number = -1
  @State childSelection: number = 0
  @State private rootDataSource: ClassificationRootDataSource = new ClassificationRootDataSource()
  @State private dataSource: ClassificationDataSource = new ClassificationDataSource(-1)
  @State private goodsDataSourceMap: Map<number, ClassificationGoodsDataSource> = new Map()
  @Consume navPathStack: NavPathStack

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
      this.childSelection = 0
      if (index >= 0) {
        const selectionId = this.rootDataSource.getData(index).id
        this.dataSource.reloadWithId(selectionId)
        hilog.info(DOMAIN, 'select', `selection id: ${selectionId}`)
      }
    })
    .height(50)
  }

  @Builder
  buildClassificationContent() {
    if (this.selection == -1) {

    } else {
      Column() {
        // 上方分类选项
        Scroll() {
          Row() {
            LazyForEach(
              this.dataSource,
              (item: Classification, index: number) => {
                Text(item.name)
                  .height('100%')
                  .padding({ left: 5, right: 5 })
                  .margin({ left: 5, right: 5 })
                  .backgroundColor(this.childSelection == index ? '#ececec' : Color.Transparent)
                  .onClick(() => {
                    this.childSelection = index
                  })
                  .fontSize(14)
                  .borderRadius(5)
              },
              (item: Classification) => item.id.toString()
            )
          }
          .alignItems(VerticalAlign.Center)
          .padding({ top: 10 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .height(30)

        Column()
          .borderWidth(1)
          .borderColor('#ececec')
          .width('100%')
          .height(1)
          .margin({top: 10, bottom: 10})

        // 下方分类内容
        Column() {
          ForEach(
            this.dataSource.getFullData(),
            (item: Classification, index: number) => {
              Text(item.name)
                .alignSelf(ItemAlign.Start)
                .width('100%')
                .fontWeight(FontWeight.Bold)
              Column() {
                LazyForEach(
                  this.getGoodsDataSource(item.id),
                  (item: Goods, index: number) => {
                    this.buildGoodsItem(item)
                  },
                  (item: Goods) => item.id.toString()
                )
              }
              .width('100%')
            },
            (item: Classification) => item.id.toString()
          )
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    }
  }

  private getGoodsDataSource(categoryId: number): ClassificationGoodsDataSource {
    let ds = this.goodsDataSourceMap.get(categoryId)
    if (!ds) {
      ds = new ClassificationGoodsDataSource(categoryId)
      this.goodsDataSourceMap.set(categoryId, ds)
    }
    return ds
  }

  @LocalBuilder
  buildGoodsItem(goods: Goods, buildType: GoodsItemBuildType = GoodsItemBuildType.List, onClick?: () => void) {
    Row() {
      Image(`http://${HOST}${goods.mainImage?.imagePath}`)
        .width(80)
        .height(80)
        .objectFit(ImageFit.Cover)
        .borderRadius(8)
      Column() {
        Text(goods.name)
        Row() {
          Text('￥').fontSize(10)
          Text(`${goods.price}`)
          if (goods.isStartingPrice) {
            Text('起').fontSize(10)
          }
          // TODO 商品标签
        }
        .alignItems(VerticalAlign.Bottom)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .padding(5)
    .backgroundColor('#f8f8f8')
    .onClick(() => {
      this.navPathStack.pushPathByName('GoodsDetails', goods.id)
    })
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
        // 左侧
        Scroll() {
          Column() {
            this.buildClassification(-1, "推荐")
            LazyForEach(this.rootDataSource, (item: Classification, index: number) => {
              this.buildClassification(index, item.name)
            })
          }
        }
        .layoutWeight(1)
        .height('100%')
        .scrollBar(BarState.Off)

        // 右侧
        Scroll() {
          this.buildClassificationContent()
        }
        .layoutWeight(2)
        .padding({left: 5, right: 5})
      }
      .layoutWeight(1)
    }
    .margin({ top: $r("app.integer.safe_area_top") })
  }
}