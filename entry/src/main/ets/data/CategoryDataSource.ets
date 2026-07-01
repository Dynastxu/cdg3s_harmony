import { HOST } from "../config";
import { Category, Goods } from "./entity";
import { BaseDataSource } from "./BaseDataSource";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { DOMAIN } from "../common/constants/LogConstants";

export class CategoryRootDataSource extends BaseDataSource<Category> {
  protected logTag: string = 'CategoryRootDataSource'

  constructor() {
    super(HOST + "/category/listRoots")
  }
}

export class CategoryDataSource extends BaseDataSource<Category> {
  protected logTag: string = 'CategoryDataSource'

  constructor(id: number) {
    super(id < 0 ? null : `${HOST}/category/listChild?id=${id.toString()}`)
  }

  reloadWithId(id: number, onLoadOver?: () => void) {
    this.reloadDataFrom(`${HOST}/category/listChild?id=${id.toString()}`, onLoadOver)
  }
}

export class CategoryGoodsDataSource extends BaseDataSource<Goods> {
  protected logTag: string = 'CategoryGoodsDataSource'

  constructor(categoryId: number) {
    super(categoryId < 0 ? null : `${HOST}/goods/getCategoryGoods?categoryId=${categoryId}`, () => {
      hilog.debug(DOMAIN.DATASOURCE, this.logTag, this.data[0]?.mainImage?.imagePath)
    })
  }

  reloadWithId(categoryId: number, onLoadOver?: () => void) {
    this.reloadDataFrom(`${HOST}/goods/getCategoryGoods?id=${categoryId.toString()}`, onLoadOver)
  }
}