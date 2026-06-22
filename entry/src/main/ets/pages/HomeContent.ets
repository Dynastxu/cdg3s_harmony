@Component
export  struct HomeContent {
  @State currentTabIndex: number = 0;

  @Builder
  buildTabBar(
    text: string | Resource,
    index: number
  ) {
    Column() {
      Text(text).fontSize(19)
      Row()
        .width(15)
        .height(3)
        .backgroundColor(this.currentTabIndex == index ? '#ff000000' : '#0000000')
        .borderRadius(1.5)
        .margin({ top: 4 })
    }
  }

  build() {
    Tabs() {
      TabContent() {
        Text("首页内容")
      }
      .tabBar(this.buildTabBar(
        "首页",
        0
      ))

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
        2
      ))
    }
    .onChange((index: number) => {
      this.currentTabIndex = index;
    })
  }
}