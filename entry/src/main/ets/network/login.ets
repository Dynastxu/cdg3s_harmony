import { HOST } from "../config"
import { http } from "@kit.NetworkKit"
import { GetNicknameResponse, LoginRequest, LoginResponse } from "./dto"
import { SOFPara} from "../utils/interface"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { DOMAIN } from "../common/constants/LogConstants"

export interface LoginPara extends SOFPara {
  username: string
  password: string
}

export interface GetNicknamePara extends SOFPara<(nickname: string) => void> {
  username: string,
  token: string
}

export function login(para: LoginPara) {
  const url = `http://${HOST}/auth/login`
  const httpRequest = http.createHttp()

  const requestData: LoginRequest = {
    username: para.username,
    password: para.password
  }

  httpRequest.request(url, {
    method: http.RequestMethod.POST,
    header: {
      'Content-Type': 'application/json'
    },
    extraData: JSON.stringify(requestData)
  }, (err: BusinessError, res: http.HttpResponse) => {
    httpRequest.destroy()

    if (err) {
      if (para.onFail) para.onFail(`网络错误：${err.message}`)
    } else {
      try {
        const response = JSON.parse(res.result as string) as LoginResponse
        if (response.success && response.token) {
          AppStorage.set('login_token', response.token)
          AppStorage.set('username', para.username)
          getNickname({
            username: para.username,
            token: response.token,
            onSuccess: (nickname: string) => {
              AppStorage.set('nickname', nickname)
            },
            onFail: (msg: string) => {
              hilog.error(DOMAIN.NETWORK, 'Login', `获取昵称失败：${msg}`)
            }
          })
          if (para.onSuccess) {
            para.onSuccess(response.message || '登录成功')
          }
        } else {
          if (para.onFail) {
            para.onFail(response.message || '登录失败')
          }
        }
      } catch (e) {
        if (para.onFail) para.onFail(`登录失败：${e}`)
      }
    }
  })
}

export function getNickname(para: GetNicknamePara) {
  const url = `http://${HOST}/user/nickname?username=${encodeURIComponent(para.username)}`
  const httpRequest = http.createHttp()

  httpRequest.request(url, {
    method: http.RequestMethod.GET,
    header: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + para.token
    }
  }, (err: BusinessError, res: http.HttpResponse) => {
    httpRequest.destroy()

    if (err) {
      if (para.onFail) para.onFail(`网络错误：${err.message}`)
    } else {
      try {
        const response = JSON.parse(res.result as string) as GetNicknameResponse
        hilog.info(DOMAIN.NETWORK, 'Login', `用户昵称：${response.nickname}`)
        if (para.onSuccess) para.onSuccess(response.nickname)
      } catch (e) {
        if (para.onFail) para.onFail(e)
      }
    }
  })
}