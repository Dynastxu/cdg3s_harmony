export function logout() {
  AppStorage.set('login_token', '')
  AppStorage.set('username', '')
  AppStorage.set('nickname', '')
}