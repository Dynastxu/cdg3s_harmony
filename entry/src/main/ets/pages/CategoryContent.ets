import hilog from '@ohos.hilog'
import { DOMAIN } from '../common/constants/LogConstants'
import { HOST } from '../config'
import { CategoryDataSource, CategoryGoodsDataSource, CategoryRootDataSource } from '../data/CategoryDataSource'
import { Category, Goods } from '../data/entity'
import { minPrice } from '../utils/function'

enum GoodsItemBuildType {
  List,
  Grid
}

@Component
export struct CategoryContent {
  @Consume navPathStack: NavPathStack
  @State selection: number = -1
  @State childSelection: number = 0
  @State adHeight: number = 0
  @State contentScrollOffset: number = 0
  @State isChildCategorySticky: boolean = false
  @State private rootDataSource: CategoryRootDataSource = new CategoryRootDataSource()
  @State private dataSource: CategoryDataSource = new CategoryDataSource(-1)
  @State private goodsDataSourceMap: Map<number, CategoryGoodsDataSource> = new Map()
  private childCategoryScroll: Scroller = new Scroller()
  private contentScroll: Scroller = new Scroller()
  private categoryItemHeights: Map<number, number> = new Map()

  @Builder
  buildCategory(index: number, name: string | Resource) {
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
        hilog.info(DOMAIN.PAGE, 'CategoryContent', `selection id: ${selectionId}`)
      }
    })
    .height(50)
  }

  @Builder
  buildAd() {
    // TODO 广告内容
    // Blank().height(50)
    //   .onAreaChange((_oldArea, newArea) => {
    //     this.adHeight = Number(newArea.height)
    //   })
  }

  @Builder
  buildChildCategoryTabs() {
    Scroll(this.childCategoryScroll) {
      Row() {
        LazyForEach(
          this.dataSource,
          (item: Category, index: number) => {
            Text(item.name)
              .height('100%')
              .padding({ left: 5, right: 5 })
              .margin({ left: 5, right: 5 })
              .backgroundColor(this.childSelection == index ? '#ececec' : Color.Transparent)
              .onClick(() => {
                this.childSelection = index
                this.scrollToCategoryContent(index)
              })
              .fontSize(14)
              .borderRadius(5)
          },
          (item: Category) => item.id.toString()
        )
      }
      .alignItems(VerticalAlign.Center)
      .padding({ top: 10 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .height(30)
    .margin({bottom: 10})
    .backgroundColor($r('app.color.background'))
  }

  @Builder
  buildCategoryContent() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll(this.contentScroll) {
        if (this.selection == -1) {

        } else {
          Column() {
            this.buildAd()

            // 上方分类选项
            Column () {
              this.buildChildCategoryTabs()
            }
            // .height(this.isChildCategorySticky ? 0 : null)

            // 分割线
            Column()
              .borderWidth(1)
              .borderColor('#ececec')
              .width('100%')
              .height(1)
              .margin({bottom: 10 })

            // 下方分类内容
            Column() {
              ForEach(
                this.dataSource.getFullData(),
                (item: Category, index: number) => {
                  Column() {
                    Text(item.name)
                      .alignSelf(ItemAlign.Start)
                      .width('100%')
                      .fontWeight(FontWeight.Bold)
                      .margin({ top: index == 0 ? 10 : 20 })
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
                  }
                  .onAreaChange((_oldArea, newArea) => {
                    this.categoryItemHeights.set(index, Number(newArea.height))
                  })
                },
                (item: Category) => item.id.toString()
              )
              Blank().height(300)
            }
            .width('100%')
          }
          .width('100%')
        }
      }
      .padding({ left: 5, right: 5 })
      .height('100%')
      .scrollBar(BarState.Off)
      .onWillScroll((xOffset, yOffset) => {
        this.contentScrollOffset += yOffset
        // 当滚动距离超过广告高度时，固定分类
        this.isChildCategorySticky = this.contentScrollOffset >= this.adHeight
      })

      // 顶层固定分类
      Column() {
        this.buildChildCategoryTabs() // 分类固定
      }
      .height(this.isChildCategorySticky ? null : 0)
      .padding({ left: 5, right: 5 })
    }
    .layoutWeight(2)
  }

  @LocalBuilder
  buildGoodsItem(goods: Goods, buildType: GoodsItemBuildType = GoodsItemBuildType.List, onClick?: () => void) {
    Row() {
      // 图片
      Image(`http://${HOST}${goods.mainImage?.imagePath}`)
        .width(80)
        .height(80)
        .objectFit(ImageFit.Cover)
        .borderRadius(8)
      Column() {
        // 名称
        Text(goods.name)
        // 价格
        Row() {
          Text('￥').fontSize(10)
          Text(`${minPrice(goods.price, goods.discountedPrice, goods.startingPrice)}`)
          if (goods.startingPrice) {
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
            this.buildCategory(-1, "推荐")
            LazyForEach(this.rootDataSource, (item: Category, index: number) => {
              this.buildCategory(index, item.name)
            })
          }
        }
        .layoutWeight(1)
        .height('100%')
        .scrollBar(BarState.Off)

        // 右侧
        this.buildCategoryContent()
      }
      .layoutWeight(1)
    }
    .margin({ top: $r("app.integer.safe_area_top") })
  }

  private getGoodsDataSource(categoryId: number): CategoryGoodsDataSource {
    let ds = this.goodsDataSourceMap.get(categoryId)
    if (!ds) {
      ds = new CategoryGoodsDataSource(categoryId)
      this.goodsDataSourceMap.set(categoryId, ds)
    }
    return ds
  }

  private scrollToCategoryContent(index: number) {
    let targetOffset = 0
    for (let i = 0; i < index; i++) {
      const height = this.categoryItemHeights.get(i)
      if (height) {
        targetOffset += height
      } else {
        targetOffset += 200
      }
    }
    if (targetOffset > 0) {
      targetOffset += 10
    }
    this.contentScroll.scrollTo({
      xOffset: 0,
      yOffset: targetOffset,
      animation: true
    })
  }
}