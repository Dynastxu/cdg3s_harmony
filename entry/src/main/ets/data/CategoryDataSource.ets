import { HOST } from "../config";
import { Category, Goods } from "./entity";
import { BaseDataSource } from "./BaseDataSource";
import { hilog } from "@kit.PerformanceAnalysisKit";

const DOMAIN = 0x0004

export class CategoryRootDataSource extends BaseDataSource<Category> {
  constructor() {
    super(HOST + "/category/listRoots")
  }
}

export class CategoryDataSource extends BaseDataSource<Category> {
  constructor(id: number) {
    super(id < 0 ? null : `${HOST}/category/listChild?id=${id.toString()}`)
  }

  reloadWithId(id: number, onLoadOver?: () => void) {
    this.reloadDataFrom(`${HOST}/category/listChild?id=${id.toString()}`, onLoadOver)
  }
}

export class CategoryGoodsDataSource extends BaseDataSource<Goods> {
  constructor(categoryId: number) {
    super(categoryId < 0 ? null : `${HOST}/goods/getCategoryGoods?categoryId=${categoryId}`, () => {
      hilog.debug(DOMAIN, 'netService', this.data[0]?.mainImage?.imagePath)
    })
  }

  reloadWithId(categoryId: number, onLoadOver?: () => void) {
    this.reloadDataFrom(`${HOST}/goods/getCategoryGoods?id=${categoryId.toString()}`, onLoadOver)
  }
}