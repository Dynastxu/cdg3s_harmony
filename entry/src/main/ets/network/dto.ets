export interface RegisterResponse {
  success: boolean,
  message: string
}

export interface RegisterRequest {
  username: string,
  password: string
}