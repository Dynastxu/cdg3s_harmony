@Component
export struct HomeMainPageContent {
  @State ads: string[] | Resource[] = [
    $r("app.media.ad1"),
    $r("app.media.ad2"),
    $r("app.media.ad3"),
    $r("app.media.ad4")
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
  @State currentSearchIndex: number = 0
  @State isScrolledUpSomeDistance: boolean = false
  @State totalScrollOffset: number = 0
  onAdBgChange?: (isDark: boolean) => void
  onScrolledUpSomeDistance ?: (isMoreThan: boolean) => void
  private timer: number = -1
  private adsOffset: number = 100

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
    .padding({bottom: 5})
  }

  @Builder
  buildAds() {
    Swiper() {
      ForEach(this.ads, (item: string | Resource, index: number) => {
        Image(item)
          .width("100%")
          .height(150 + this.adsOffset)
          .objectFit(ImageFit.Fill)
          .padding({ top: this.adsOffset })
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

  build() {
    Stack({alignContent: Alignment.Top}) {
      // 底层：可滚动区域（广告等）
      Scroll() {
        Column() {
          this.buildAds()
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
      .offset({ y: -50 })

      // 固定搜索栏
      Column() {
        this.buildSearchBar()
      }
    }
    .width("100%")
    .height("100%")
  }
}