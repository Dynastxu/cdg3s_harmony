import { Callback } from '@kit.BasicServicesKit'

@Component
export struct NavDestinationInner {
  @BuilderParam topBar: () => void = this.slot
  @BuilderParam bottomBar: () => void = this.slot
  @BuilderParam innerContent: () => void = this.slot
  @BuilderParam maskLayer: () => void = this.defaultMaskLayer
  @State topBarHeight: Length = $r('app.integer.safe_area_top')
  @State enableTopSafeArea: boolean = true
  @Prop showMaskLayer: boolean = false
  onReady: Callback<NavDestinationContext> = () => {
  }

  @Builder
  slot() {
  }

  @Builder
  defaultMaskLayer() {
    // 半透明遮罩
    Column()
      .width('100%')
      .height('100%')
      .backgroundColor('#33000000')
      .onClick(() => {
        this.showMaskLayer = false
      })

    Column() {
      Text('遮罩内容')
    }
    .width('100%')
    .height(100)
    .backgroundColor($r('app.color.background'))
    .borderRadius({ topLeft: 10, topRight: 10 })
    .padding({
      left: 20,
      right: 20,
      top: 20,
      bottom: 30
    })
    .position({ bottom: 0 })
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          if (this.enableTopSafeArea) {
            Blank().height(this.topBarHeight)
          }
          this.innerContent()
        }
        .width('100%')

        Column() {
          this.topBar()
        }
        .position({ top: 0 })
        .height(this.topBarHeight)
        .width('100%')

        Column() {
          this.bottomBar()
        }
        .position({ bottom: 0 })
        .width('100%')

        if (this.showMaskLayer) {
          this.maskLayer()
        }
      }
      .height('100%')
      .width('100%')
    }
    .onReady(this.onReady)
    .hideTitleBar(true)
    .hideToolBar(true)
  }
}

@Component
@Preview
struct NavDestinationInnerPreview {
  @State showMaskLayer: boolean = false

  @Builder
  innerContent() {
    Text('内容')
  }

  @Builder
  topContent() {
    Column() {
      Text('顶部栏')
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.theme'))
  }

  @Builder
  bottomContent() {
    Column() {
      Text('底部栏')
    }
    .width('100%')
    .backgroundColor($r('app.color.theme'))
  }

  build() {
    NavDestinationInner({
      innerContent: this.innerContent,
      topBar: this.topContent,
      bottomBar: this.bottomContent,
      showMaskLayer: this.showMaskLayer
    })
  }
}

@Component
@Preview
struct NavDestinationInnerShowMaskLayerPreview {
  build() {
    NavDestinationInnerPreview({
      showMaskLayer: true
    })
  }
}