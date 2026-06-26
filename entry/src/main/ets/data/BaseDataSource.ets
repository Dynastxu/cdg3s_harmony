import { http } from "@kit.NetworkKit"
import { hilog } from "@kit.PerformanceAnalysisKit"

const DOMAIN = 0x0003

export abstract class BaseDataSource<T> implements IDataSource {
  protected data: T[] = []
  protected listeners: DataChangeListener[] = []
  protected isLoadingData: boolean = false

  constructor(url: string | null) {
    if (url != null) this.getDataFrom(url)
  }

  totalCount(): number {
    return this.data.length
  }

  getData(index: number): T {
    return this.data[index]
  }

  getFullData(): T[] {
    return this.data
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) {
      this.listeners.splice(pos, 1)
    }
  }

  protected reloadDataFrom(url: string) {
    this.data = []
    this.getDataFrom(url)
  }

  protected getDataFrom(url: string) {
    hilog.info(DOMAIN, "netService", `从 ${url} 获取数据`)

    const httpRequest: http.HttpRequest = http.createHttp()

    this.isLoadingData = true
    httpRequest.request(url, (err: BusinessError, res: http.HttpResponse) => {
      if (err == null) {
        this.data = JSON.parse(res.result as string) as T[]
        hilog.info(DOMAIN, "netService", `获取数据成功 (${this.data.length})`)
      } else {
        hilog.error(DOMAIN, "netService", `获取数据失败：${err.message}`)
      }
      httpRequest.destroy()
      this.notifyDataRefresh()
      this.isLoadingData = false
    })
  }

  protected notifyDataRefresh() {
    this.listeners.forEach(listener => {
      listener.onDataReloaded()
    })
  }

  getIsLoadingData(): boolean {
    return this.isLoadingData
  }
}