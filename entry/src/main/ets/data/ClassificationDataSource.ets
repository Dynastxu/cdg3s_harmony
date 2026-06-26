import { HOST } from "../config";
import { Classification } from "./entity";
import { BaseDataSource } from "./BaseDataSource";

export class ClassificationRootDataSource extends BaseDataSource<Classification> {
  constructor() {
    super(HOST + "/category/listRoots")
  }
}

export class ClassificationDataSource extends BaseDataSource<Classification> {
  constructor(id: number) {
    super(id < 0 ? null : `${HOST}/category/listChild?id=${id.toString()}`)
  }

  reloadWithId(id: number) {
    this.reloadDataFrom(`${HOST}/category/listChild?id=${id.toString()}`)
  }
}