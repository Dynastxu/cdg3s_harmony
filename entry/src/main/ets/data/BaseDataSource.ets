import { http } from "@kit.NetworkKit"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { DOMAIN } from "../common/constants/LogConstants"

export abstract class BaseDataSource<T> implements IDataSource {
  protected data: T[] = []
  protected listeners: DataChangeListener[] = []
  protected isLoadingData: boolean = false
  protected abstract logTag: string

  constructor(url: string | null, onLoadOver?: () => void) {
    if (url != null) this.getDataFrom(url, onLoadOver)
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

  protected reloadDataFrom(url: string, onReloadOver?: () => void) {
    this.data = []
    this.getDataFrom(url, onReloadOver)
  }

  protected getDataFrom(url: string, onReloadOver?: () => void) {
    hilog.info(DOMAIN.DATASOURCE, this.logTag, `从 ${url} 获取数据`)

    const httpRequest: http.HttpRequest = http.createHttp()

    this.isLoadingData = true
    httpRequest.request(url, (err: BusinessError, res: http.HttpResponse) => {
      if (err == null) {
        this.data = JSON.parse(res.result as string) as T[]
        hilog.info(DOMAIN.DATASOURCE, this.logTag, `获取数据成功 (${this.data.length})\n${res.result as string}`)
      } else {
        hilog.error(DOMAIN.DATASOURCE, this.logTag, `获取数据失败：${err.message}`)
      }
      httpRequest.destroy()
      this.notifyDataRefresh()
      if (onReloadOver) {
        onReloadOver()
      }
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