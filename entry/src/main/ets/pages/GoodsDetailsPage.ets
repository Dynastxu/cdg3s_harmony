import { HOST } from '../config'
import { Goods, GoodsImage, GoodsSpecification, GoodsSpecificationImage } from '../data/entity'
import { getDataFrom } from '../network/utils'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { DOMAIN } from '../common/constants/LogConstants'
import { LengthUnit } from '@kit.ArkUI'
import { NavDestinationInner } from '../component/NavDestinationInner'

@Component
struct GoodDetailsPage {
  @Consume navPathStack: NavPathStack
  @State goods: Goods | null = null
  @State showAddToCartPanel: boolean = false
  @State selectedSpecifications: GoodsSpecification[] = []
  @State specificationImage: GoodsImage | null = null
  @State specificationImages: GoodsSpecificationImage[] | null = null

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
  bottomBar() {
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
        .onClick(() => {
          this.getUIContext().animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
            this.showAddToCartPanel = true
          })
        })
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

  @Builder
  buildAddToShoppingCartContent() {
    if (this.goods != null) {
      Column() {
        Row() {
          // 规格图片
          Image(this.specificationImage ? `http://${HOST}${this.specificationImage.imagePath}` : null)
            .height(100)
            .width(100)
            .onComplete(() => {
              hilog.info(DOMAIN.PAGE, 'GoodsDetails', `规格图片加载成功: ${this.specificationImage?.imagePath}`)
            })
            .onError((error) => {
              hilog.error(DOMAIN.PAGE, 'GoodsDetails', `规格图片加载失败: http://${HOST}${this.specificationImage?.imagePath}`)
              hilog.error(DOMAIN.PAGE, 'GoodsDetails', `错误详情: ${JSON.stringify(error)}`)
            })
          Row() {
            Column() {
              // 价格
              Row() {
                Text(`￥${this.goods?.discountedPrice ? this.goods?.discountedPrice : this.goods?.price}`)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.theme'))
                  .fontSize(21)
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
              }
              .alignItems(VerticalAlign.Top)
              .width('100%')
              .justifyContent(FlexAlign.Start)

              // 名称及选中的规格
              Row() {
                Text(this.goods.name + ' ' + this.getSelectedSpecsText())
                  .fontSize(12)
                  .textOverflow({ overflow: TextOverflow.None })
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
            }
            .padding(10)
            .alignItems(HorizontalAlign.Start)
          }
        }
        .width('100%')

        if (this.goods.specifications != null && this.goods.specifications.length > 0) {
          // 规格选项
          Column() {
            ForEach(this.getGoodsSpecificationsNames(this.goods!.specifications!), (name: string) => {
              Text(name)
                .fontSize(12)
                .fontWeight(FontWeight.Bold)
              Flex({
                wrap: FlexWrap.Wrap,
                space: { main: { value: 10, unit: LengthUnit.VP }, cross: { value: 5, unit: LengthUnit.VP } }
              }) {
                ForEach(this.getGoodsSpecificationsValues(this.goods!.specifications!, name), (v: string) => {
                  Column() {
                    Text(v)
                      .fontSize(12)
                  }
                  .constraintSize({ minHeight: 20 })
                  .borderRadius(10)
                  .backgroundColor(this.isSpecificationSelected(name, v) ?
                    $r('app.color.theme_light') : '#f5f5f5')
                  .borderWidth(1)
                  .borderColor(this.isSpecificationSelected(name, v) ?
                    $r('app.color.theme') : '#f5f5f5')
                  // 规格点击事件
                  .onClick(() => {
                    this.selectSpecifications(name, v)
                  })
                  .padding({
                    left: 10,
                    right: 10,
                    top: 5,
                    bottom: 5
                  })
                })
              }
              .padding({ bottom: 20, top: 5 })
            })
          }
          .alignItems(HorizontalAlign.Start)
        }

        // 确认按钮
        Button('确认加入购物车')
          .backgroundColor($r('app.color.theme'))
          .width('100%')
          .margin({ top: 20 })
          .onClick(() => {
            // TODO: 加入购物车逻辑
            this.getUIContext().animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
              this.showAddToCartPanel = false
            })
          })
      }
      .padding({ left: 10, right: 10 })
    }
  }

  private isSpecificationSelected(name: string, value: string): boolean {
    return this.selectedSpecifications.some(s => s.name === name && s.value === value)
  }

  private getSelectedSpecsText(): string {
    if (this.selectedSpecifications.length === 0) return ''
    return this.selectedSpecifications.map(s => `${s.value}`).join(' ')
  }

  @Builder
  mainContent() {
    // 主内容
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
  }

  @Builder
  topBar() {
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
    .width('100%')
  }

  @Builder
  maskLayer() {
    // 半透明遮罩
    Column()
      .width('100%')
      .height('100%')
      .backgroundColor('#33000000')
      .onClick(() => {
        this.getUIContext().animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
          this.showAddToCartPanel = false
        })
      })
      .transition(TransitionEffect.OPACITY.animation({ duration: 300 }))

    // 规格选择底部面板
    Column() {
      // 规格内容
      this.buildAddToShoppingCartContent()
    }
    .width('100%')
    .backgroundColor($r('app.color.background'))
    .borderRadius({ topLeft: 10, topRight: 10 })
    .padding({
      left: 20,
      right: 20,
      top: 20,
      bottom: 30
    })
    .position({ bottom: 0 })
    .transition(
      TransitionEffect.translate({ y: 600 })
        .animation({ duration: 300, curve: Curve.EaseOut })
    )
  }

  build() {
    NavDestinationInner({
      topBar: () => { this.topBar() },
      bottomBar: () => { this.bottomBar() },
      innerContent: () => { this.mainContent() },
      maskLayer: () => { this.maskLayer() },
      showMaskLayer: this.showAddToCartPanel,
      onReady: (context: NavDestinationContext) => {
        const goodsId = context.pathInfo.param as number
        // 获取商品数据
        getDataFrom<Goods>({
          url: `${HOST}/goods?id=${goodsId}`,
          onSuccess: (g: Goods) => {
            if (g == null) return
            this.goods = g
            if (g.specifications && g.specifications.length > 0) {
              // 为每个规格种类选择第一个值作为默认选中
              const specNames = this.getGoodsSpecificationsNames(g.specifications)
              this.selectedSpecifications = []
              specNames.forEach(name => {
                const values = this.getGoodsSpecificationsValues(g.specifications!, name)
                if (values.length > 0) {
                  // 找到该规格种类的第一个规格项
                  const firstSpec = g.specifications!.find(s => s.name === name && s.value === values[0])
                  if (firstSpec) {
                    this.selectedSpecifications.push(firstSpec)
                  }
                }
              })
              hilog.info(DOMAIN.PAGE, 'GoodsDetails', `初始化选中规格: ${JSON.stringify(this.selectedSpecifications)}`)
              // 获取商品规格图片数据
              getDataFrom<GoodsSpecificationImage[]>({
                url: `${HOST}/goods/image/specification?goodsId=${g.id}`,
                onSuccess: (v) => {
                  hilog.info(DOMAIN.PAGE, 'GoodsDetails', `获取规格图片成功，数量: ${v?.length || 0}`)
                  if (v && v.length > 0) {
                    v.forEach((specImg, index) => {
                      hilog.info(DOMAIN.PAGE, 'GoodsDetails', `规格图片[${index}]: 图片路径=${specImg.image?.imagePath}, 规格组合=${JSON.stringify(specImg.specifications)}`)
                    })
                  }
                  this.specificationImages = v
                  // 初始化时匹配第一张规格图片
                  this.updateSpecificationImageBySelection()
                }
              })
            }
          }
        })
      }
    })
  }

  private selectSpecifications(name: string, value: string) {
    hilog.info(DOMAIN.PAGE, 'GoodsDetails', `点击规格: name=${name}, value=${value}`)

    if (!this.goods || !this.goods.specifications) return

    // 查找对应的规格对象
    let targetSpec: GoodsSpecification | null = null
    for (const s of this.goods.specifications) {
      if (s.name === name && s.value === value) {
        targetSpec = s
        break
      }
    }

    if (!targetSpec) return

    // 检查是否已选中该规格种类
    const existingIndex = this.selectedSpecifications.findIndex(s => s.name === name)

    if (existingIndex >= 0) {
      // 同一种规格已存在，替换为新选中的值
      this.selectedSpecifications[existingIndex] = targetSpec
    } else {
      // 新种类规格，添加到数组
      this.selectedSpecifications.push(targetSpec)
    }

    // 更新规格图片
    hilog.info(DOMAIN.PAGE, 'GoodsDetails', `更新后的选中规格: ${JSON.stringify(this.selectedSpecifications)}`)
    this.updateSpecificationImageBySelection()
  }

  private updateSpecificationImageBySelection() {
    hilog.info(DOMAIN.PAGE, 'GoodsDetails', `开始匹配规格图片，当前选中规格: ${JSON.stringify(this.selectedSpecifications)}, 可用规格图片数量: ${this.specificationImages?.length || 0}`)

    if (!this.specificationImages || this.selectedSpecifications.length === 0) {
      hilog.warn(DOMAIN.PAGE, 'GoodsDetails', `规格图片数据为空或没有选中规格，清空当前图片`)
      this.specificationImage = null
      return
    }

    // 遍历所有规格图片配置，找到匹配的
    for (const specImage of this.specificationImages) {
      hilog.info(DOMAIN.PAGE, 'GoodsDetails', `检查规格图片: ${JSON.stringify(specImage.specifications)}, 图片路径: ${specImage.image?.imagePath}`)

      // 检查 specImage.specifications 是否包含所有选中的规格
      const isMatch = this.selectedSpecifications.every(selectedSpec => {
        return specImage.specifications.some(spec =>
        spec.name === selectedSpec.name && spec.value === selectedSpec.value
        )
      })

      hilog.info(DOMAIN.PAGE, 'GoodsDetails', `匹配结果: ${isMatch}`)

      if (isMatch) {
        hilog.info(DOMAIN.PAGE, 'GoodsDetails', `找到匹配的图片: ${specImage.image?.imagePath}`)
        this.specificationImage = specImage.image
        return
      }
    }

    // 没有找到匹配的图片
    hilog.warn(DOMAIN.PAGE, 'GoodsDetails', `未找到匹配的规格图片`)
    this.specificationImage = null
  }

  private getGoodsSpecificationsNames(specifications: GoodsSpecification[]): string[] {
    let names: string[] = []
    specifications.forEach((s) => {
      if (!names.includes(s.name)) {
        names.push(s.name)
      }
    })
    return names
  }

  private getGoodsSpecificationsValues(specifications: GoodsSpecification[], name: string): string[] {
    let values: string[] = []
    specifications.forEach((s) => {
      if (s.name != name) {
        return
      }
      if (!values.includes(s.value)) {
        values.push(s.value)
      }
    })
    return values
  }
}

@Builder
export function GoodDetailsPageBuilder() {
  GoodDetailsPage()
}