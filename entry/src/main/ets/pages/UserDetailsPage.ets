@Component
struct UserDetailsPage {
  build() {
    NavDestination() {

    }
    .hideToolBar(true)
    .padding({top: $r('app.integer.safe_area_top')})
  }
}