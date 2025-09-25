export interface RandomOrgResponse {
  randomNumber: number
  min: number
  max: number
  timestamp: string
  source: string
}

export interface RandomOrgApiParams {
  num: number
  min: number
  max: number
  col: number
  base: number
  format: string
  rnd: string
}

export interface RandomNodeError {
  error: string
  code?: string
  statusCode?: number
}
