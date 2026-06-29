/**
 * 成败回调参数接口
 * @param S 成功回调参数类型
 * @param F 失败回调参数类型
 */
export interface SOFPara <S = (msg: string) => void, F = (msg: string) => void>{
  onSuccess?: S
  onFail?: F
}