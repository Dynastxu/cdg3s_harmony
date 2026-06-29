import { HOST } from "../config"
import { RegisterRequest, RegisterResponse } from "./dto"
import { http } from "@kit.NetworkKit"
import { SOFPara} from "../utils/interface"

export interface RegisterPara extends SOFPara {
  username: string
  password: string
}

export function register(para: RegisterPara) {
  const url = `http://${HOST}/auth/register`
  const httpRequest = http.createHttp()

  const requestData: RegisterRequest = {
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
      return
    }
    try {
      const response = JSON.parse(res.result as string) as RegisterResponse
      if (response.success) {
        if (para.onSuccess) para.onSuccess(response.message || '注册成功')
      } else {
        if (para.onFail) para.onFail(response.message || '注册失败')
      }
    } catch (e) {
      if (para.onFail) para.onFail(`注册失败：${e}`)
    }
  })
}
