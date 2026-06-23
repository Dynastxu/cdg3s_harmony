import { LengthUnit } from "@kit.ArkUI"

@Component
@Preview
export struct HomeMainPageContent {
  // ad5 是手机端图片，其余非手机端
  @State ads: string[] | Resource[] = [
    $r("app.media.ad1"),
    $r("app.media.ad2"),
    $r("app.media.ad3"),
    $r("app.media.ad5")
  ]
  @State isDarkAdBg: boolean[] = [
    true,
    false,
    false,
    false
  ]
  // 理论上没有背景色，因为手机端的图片直接填充整个 Swiper
  // 这里使用是因为使用的图片尺寸与手机端不同，为保持观感添加的
  @State AdsBg: string[] | Resource = [
    "#000000",
    "#F7F7F7",
    "#F7F7F7",
    "#F7F7F7"
  ]
  @State currentAdIndex: number = 0
  @State searches: string[] | Resource[] = [
    "搜索条目 1",
    "搜索条目 2",
    "搜索条目 3"
  ]
  @State objectItemImages: string[] | Resource[] = [
    $r("app.media.icon_yjhx"),
    $r("app.media.icon_xrfl"),
    $r("app.media.icon_znjj"),
    $r("app.media.icon_rcj"),
    $r("app.media.icon_znsh"),
    $r("app.media.icon_xszx"),
    $r("app.media.icon_mqxq"),
    $r("app.media.icon_shdq"),
    $r("app.media.icon_scsl"),
    $r("app.media.icon_sqk"),
    $r("app.media.icon_gjbt"),
    $r("app.media.icon_ds"),
    $r("app.media.icon_sj"),
    $r("app.media.icon_xmsx"),
    $r("app.media.icon_xmrb"),
    $r("app.media.icon_zncd"),
    $r("app.media.icon_dnpp"),
    $r("app.media.icon_kbx"),
    $r("app.media.icon_xmzc"),
    $r("app.media.icon_xmfb")
  ]
  @State objectItemText: string[] | Resource[] = [
    "以旧换新",
    "新人福利",
    "智能家居",
    "人车家",
    "智能生活",
    "学生专享",
    "米圈星球",
    "生活电器",
    "商城送礼",
    "省钱卡",
    "国家补贴",
    "电视",
    "手机",
    "小米上新",
    "小米热榜",
    "智能穿戴",
    "电脑/平板",
    "空冰洗",
    "小米众筹",
    "小米发布"
  ]
  @State currentSearchIndex: number = 0
  @State isScrolledUpSomeDistance: boolean = false
  @State totalScrollOffset: number = 0
  @State recommendItems: Record<string, string | Resource>[] = [
    {
      "title": "智慧厨房",
      "subtitle": "国补至高优惠15%",
      "image": $r("app.media.icon_zhcf")
    },
    {
      "title": "青春运动季",
      "subtitle": "限时限量抢好礼",
      "image": $r("app.media.icon_qcydj")
    }
  ]
  onAdBgChange?: (isDark: boolean) => void
  onScrolledUpSomeDistance ?: (isMoreThan: boolean) => void
  private timer: number = -1
  private adsOffset: number = 120

  aboutToAppear() {
    // 启动定时器，每隔 3 秒切换索引
    this.timer = setInterval(() => {
      this.currentSearchIndex = (this.currentSearchIndex + 1) % this.searches.length
    }, 3000)
    // 初始化父级 Tab 文字颜色是否反转
    if (this.onAdBgChange) {
      this.onAdBgChange(this.isDarkAdBg[0])
    }
  }

  aboutToDisappear() {
    // 组件销毁时清除定时器
    if (this.timer !== -1) {
      clearInterval(this.timer)
      this.timer = -1
    }
  }

  @Builder
  buildSearchBar() {
    Column() {
      Row() {
        Row() {
          Image($r("app.media.scan_line"))
            .height("80%")
            .padding({ left: 3 })
          Text(this.searches[this.currentSearchIndex])
            .fontSize(14)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
            .padding({ left: 8, right: 8 })
          Button("搜索")
            .width(60)
            .borderRadius(7)
            .backgroundColor($r("app.color.theme"))
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .margin(3)
      }
      .width("90%")
      .height(30)
      .backgroundColor($r("app.color.background"))
      .border({
        width: 1,
        color: $r("app.color.theme"),
      })
      .borderRadius(10)
    }
    .backgroundColor(this.isScrolledUpSomeDistance ? $r("app.color.background") : Color.Transparent)
    .width("100%")
    .layoutGravity(LocalizedAlignment.CENTER)
    .animation({ duration: 0 }) // 由于父组件 Tab 背景色变更难以实现动画，这里暂时设为 0
    .padding({ bottom: 5 })
  }

  @Builder
  buildAds() {
    Swiper() {
      ForEach(this.ads, (item: string | Resource, index: number) => {
        Row() {
          Image(item)
            .width("100%")
            .objectFit(ImageFit.Auto)
        }
        .height(200 + this.adsOffset)
        .alignItems(VerticalAlign.Bottom)
        .background(this.AdsBg[index])
      })
    }
    .autoPlay(true)
    .onChange((index: number) => {
      this.currentAdIndex = index
    })
    .onAnimationStart((_index: number, targetIndex: number) => {
      if (this.onAdBgChange) {
        this.onAdBgChange(this.isDarkAdBg[targetIndex])
      }
    })
  }

  @Builder
  buildObjectItemBar() {
    Scroll() {
      Grid() {
        ForEach(this.objectItemImages, (image: string | Resource, index: number) => {
          this.buildObjectItem(image, this.objectItemText[index])
        })
      }
      .columnsTemplate(Array(10).fill('1fr').join(' '))
      .rowsTemplate("1fr 1fr")
      .height(200)
      .width("190%")
    }
    .scrollable(ScrollDirection.Horizontal)
    .width("100%")
    .margin({
      left: 10,
      right: 10
    })
    .scrollBar(BarState.On)
    .scrollBarMargin({
      start: { value: 135, unit: LengthUnit.VP },
      end: { value: 135, unit: LengthUnit.VP }
    })
  }

  @Builder
  buildObjectItem(
    image: string | Resource,
    title: string | Resource
  ) {
    Column() {
      Image(image).height(75).objectFit(ImageFit.Auto).margin(-5)
      Text(title).fontSize(11)
    }
    .margin(10)
  }

  @Builder
  buildRecommendCard() {
    Stack() {
      Image($r("app.media.ad_hdplr"))
        .height("100%")
        .layoutGravity(LocalizedAlignment.START)
        .borderRadius(10)

      // 遮罩
      Column()
        .borderRadius(10)
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [["#ff888888", 0], ["#00ffffff", 1]]
        })
        .height("100%")
        .width("100%")
      Column()
        .borderRadius(10)
        .linearGradient({
          direction: GradientDirection.Left,
          colors: [["#ff888888", 0.4], ["#00ffffff", 1]]
        })
        .height("100%")
        .width("100%")

      Column() {
        Text("黑电品类日")
          .fontWeight(FontWeight.Bold)
        Text("限量立减至高100元 >")
          .fontSize(11)
          .margin({top: 3})
      }
      .layoutGravity(LocalizedAlignment.TOP_START)
      .alignItems(HorizontalAlign.Start)
      .margin({
        left: 10,
        top: 10
      })

      Row() {
        ForEach(this.recommendItems, (item: Record<string, string | Resource>) => {
          this.buildRecommendCardItem(
            item["title"],
            item["subtitle"],
            item["image"]
          )
        })
      }
      .height("100%")
      .width("60%")
      .layoutGravity(LocalizedAlignment.END)
    }
    .height(130)
    .width("100%")
    .padding({
      left: 10,
      right: 10
    })
    .clip(true)
  }

  @Builder
  buildRecommendCardItem(
    title: string | Resource,
    subtitle: string | Resource,
    image: string | Resource
  ) {
    Column() {
      Text(title)
        .fontWeight(FontWeight.Bold)
        .fontSize(12)
      Text(subtitle)
        .fontSize(10)
        .margin({top: 2})
        .fontColor("#666666")
      Image(image)
        .align(Alignment.Bottom)
        .margin(-2)
        .layoutWeight(1)
    }
    .width(90)
    .padding(5)
    .margin({top: 10, bottom: 10, right: 10})
    .borderRadius(5)
    .backgroundColor("#ffffff")
    .layoutWeight(1)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column() {
          this.buildAds()
          this.buildObjectItemBar()
          this.buildRecommendCard()
          Column().height(999) // 占位内容
        }
        .width("100%")
      }
      .onDidScroll((_xOffset: number, yOffset: number) => {
        this.totalScrollOffset += yOffset
        this.isScrolledUpSomeDistance = this.totalScrollOffset >= 50
        if (this.onScrolledUpSomeDistance) {
          this.onScrolledUpSomeDistance(this.isScrolledUpSomeDistance)
        }
      })
      .margin({ top: -this.adsOffset })
      .scrollBar(BarState.Off)

      // 固定搜索栏
      Column() {
        this.buildSearchBar()
      }
    }
    .width("100%")
    .height("100%")
  }
}