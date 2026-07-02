import { NavDestinationInner } from '../component/NavDestinationInner'
import { logout } from '../network/logout'

@Component
struct SettingsPage {
  @Consume navPathStack: NavPathStack

  @Builder
  mainContent() {
    Column() {
      Column({ space: 5 }) {
        Column({ space: 1 }) {
          SettingItem({
            title: '消息推送',
            subTitle: '免打扰时间:23:00-次日8:00',
            value: '已开启'
          })
        }
        .width('100%')

        Row() {
          Text('退出账号')
            .fontSize(12)
            .padding({ top: 10, bottom: 10})
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.background'))
        .onClick(() => {
          logout()
          this.navPathStack.pop()
        })
      }
      .width('100%')

      Blank().layoutWeight(1)
    }
    .backgroundColor($r('app.color.background_dim'))
  }

  build() {
    NavDestinationInner({
      innerContent: () => { this.mainContent() }
    })
  }
}

@Component
struct SettingItem {
  @Require title: string | Resource
  @Prop titleFontSize: number | string | Resource = 12
  @Prop subTitle: string | Resource
  @Prop subTitleFontSize: number | string | Resource = 12
  @Prop value: string | Resource

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.title)
            .fontSize(this.titleFontSize)
          Blank().height(10)
          Text(this.subTitle)
            .fontSize(this.subTitleFontSize)
            .fontColor($r('app.color.font_unimportant'))
        }
        .alignItems(HorizontalAlign.Start)
        .padding({ top: 10, bottom: 10, left: 10})

        Row() {
          Text(this.value + ' >')
            .fontColor($r('app.color.font_unimportant'))
            .fontSize(12)
            .padding({ right: 10 })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .constraintSize({ minHeight: 30 })
    .backgroundColor($r('app.color.background'))
  }
}

@Builder
export function SettingsPageBuilder() {
  SettingsPage()
}

@Component
@Preview
struct SettingsPagePreview {
  @Provide navPathStack: NavPathStack = new NavPathStack()

  build() {
    SettingsPage()
  }
}

@Component
@Preview
struct SettingItemPreview {
  build() {
    SettingItem({
      title: '标题',
      subTitle: '副标题',
      value: '值'
    })
  }
}