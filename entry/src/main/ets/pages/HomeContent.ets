import { HomeMainPageContent } from "./HomeMainPageContent"

@Component
export struct HomeContent {
  @State currentTabIndex: number = 0
  @State needFontColorReverse: boolean = false
  @State needShowTabBg: boolean = false
  @State tabBgColor: string | Resource = "#ffffff"

  @Builder
  buildTabBar(
    text: string | Resource,
    index: number,
    fontColor: string | Resource = "#000000",
    fontColorReverse: string | Resource = "#ffffff",
  ) {
    Column() {
      Text(text).fontSize(19).fontColor(this.needFontColorReverse && !this.needShowTabBg ? fontColorReverse : fontColor)
      Row()
        .width(15)
        .height(3)
        .backgroundColor(this.currentTabIndex == index ? '#ff000000' : '#0000000')
        .borderRadius(1.5)
        .margin({ top: 4 })
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      if (this.needShowTabBg) {
        Row()
          .width('100%')
          .height(50)  // 根据你的 TabBar 实际高度调整
          .backgroundColor(this.tabBgColor)
          .animation({duration: 200})
      }

      Tabs() {
        TabContent() {
          HomeMainPageContent({
            onAdBgChange: (isDark: boolean) => {
              this.needFontColorReverse = isDark
            },
            onScrolledUpSomeDistance: (isMoreThan: boolean) => {
              this.needShowTabBg = isMoreThan
          }
          })
        }
        .tabBar(this.buildTabBar(
          "首页",
          0
        ))
        .clip(false)

        TabContent() {
          Text("手机发布内容")
        }
        .tabBar(this.buildTabBar(
          "手机发布",
          1
        ))

        TabContent() {
          Text("国补内容")
        }
        .tabBar(this.buildTabBar(
          "国补",
          2,
          "#569976",
          "#569976"
        ))
      }
      .onChange((index: number) => {
        this.currentTabIndex = index;
      })
      .barWidth("70%")
      .clip(this.needShowTabBg)
    }
  }
}