import { UserInfo } from "utils";

export interface LoginRequest {
  employeeNo: string;
  password: string;
  role: string;
}

export interface LoginResponse {
  code: number;
  msg: string;
  data: {
    token: string;
    user: UserInfo;
  };
}
