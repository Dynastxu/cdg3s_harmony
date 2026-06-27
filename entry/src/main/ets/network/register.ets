import { HOST } from "../config"
import { RegisterRequest, RegisterResponse } from "./dto"
import { http } from "@kit.NetworkKit"

export interface RegisterAttribute {
  userName: string,
  password: string
  onSuccess?: (msg: string) => void,
  onFail?: (msg: string) => void
}

export function register(attr: RegisterAttribute) {
  const url = `http://${HOST}/user/register`
  const httpRequest = http.createHttp()

  const requestData: RegisterRequest = {
    username: attr.userName,
    password: attr.password
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
      if (attr.onFail) attr.onFail(`网络错误：${err.message}`)
      return
    }
    try {
      const response = JSON.parse(res.result as string) as RegisterResponse
      if (response.success) {
        if (attr.onSuccess) attr.onSuccess(response.message || '注册成功')
      } else {
        if (attr.onFail) attr.onFail(response.message || '注册失败')
      }
    } catch (e) {
      if (attr.onFail) attr.onFail('注册失败，请稍后重试')
    }
  })
}
