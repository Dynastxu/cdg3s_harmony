import { isBlank } from "../utils/function"

@Component
export struct ProfileContent {
  @Consume navPathStack: NavPathStack
  @StorageProp('nickname') nickname?: string = AppStorage.get('nickname')
  @StorageProp('username') username?: string = AppStorage.get('username')
  @StorageProp('login_token') token?: string = AppStorage.get('login_token')

  build() {
    Scroll() {
      Column() {
        Row() {
          Image($r('app.media.circle_user_round'))
            .width(50)
          Blank().width(5)
          Text(isBlank(this.token) ? '登录/注册 >' : isBlank(this.nickname) ? this.username : this.nickname)
            .layoutWeight(1)
            .height('100%')
            .onClick(() => {
              this.navPathStack.pushPathByName('Login', null)
            })
        }
        .height(50)
      }
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [[$r('app.color.theme_light'), 0], [$r('app.color.background'), 0.1]]
      })
      .height('100%')
      .width('100%')
      .padding({ left: 5, right: 5, top: $r('app.integer.safe_area_top') })
    }
    .height('100%')
    .width('100%')
  }
}

@Component
@Preview
struct ProfileContentPreview {
  @Provide navPathStack: NavPathStack = new NavPathStack()

  build() {
    ProfileContent()
  }
}