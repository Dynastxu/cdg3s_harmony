export function isBlank(str: string): boolean {
  if (str == null) return true
  return str.trim().length === 0;
}