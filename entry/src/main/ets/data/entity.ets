// 暂时仅用于假数据
export interface GoodsInfo {
  id: number
  uid?: string
  name: string | Resource
  price: number
  originalPrice?: number
  isStartingPrice: boolean
  image: string | Resource
  desc: string | Resource
}

export interface Category {
  id: number
  name: string
}

export interface GoodsTag {
  id: number
  name: string
  color: string | null
  description: string | null
}

export interface GoodsImage {
  id: number
  imagePath: string
}

export interface Goods {
  id: number
  name: string
  price: number
  category: string | null
  discountedPrice: number | null
  startingPrice: number | null
  goodsTag: GoodsTag[]
  images: GoodsImage[]
  mainImage: GoodsImage | null
}