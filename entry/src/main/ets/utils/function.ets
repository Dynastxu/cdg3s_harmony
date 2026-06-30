export function isBlank(str: string): boolean {
  if (str == null) return true
  return str.trim().length === 0;
}

export function minPrice(...prices: (number | null)[]) {
  let notNullPrices: number[] = []
  prices.forEach((prices: number | null) => {
    if (prices != null) notNullPrices.push(prices)
  })
  return Math.min(...notNullPrices)
}