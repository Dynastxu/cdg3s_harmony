import { hilog } from "@kit.PerformanceAnalysisKit"
import { http } from "@kit.NetworkKit"
import { SOFPara } from "../utils/interface"
import { DOMAIN } from "../common/constants/LogConstants"

export interface GetDataFromPara<T> extends SOFPara<(value: T) => void> {
  url: string
}

/**
 * 从指定 url 获取数据
 * @description 通过 `onSuccess` 回调获取数据
 * @param para 方法参数
 */
export function getDataFrom<T>(para: GetDataFromPara<T>) {
  hilog.info(DOMAIN.NETWORK, "Network", `从 ${para.url} 获取数据`)
  const httpRequest: http.HttpRequest = http.createHttp()

  httpRequest.request(para.url, (err: BusinessError, res: http.HttpResponse) => {
    httpRequest.destroy()
    if (err == null) {
      let data = JSON.parse(res.result as string) as T
      hilog.info(DOMAIN.NETWORK, "Network", `获取数据成功`)
      if (para.onSuccess) para.onSuccess(data)
    } else {
      hilog.error(DOMAIN.NETWORK, "Network", `获取数据失败：${err.message}`)
      if (para.onFail) para.onFail(err.message)
    }
  })
}