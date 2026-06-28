import { TokenProvider } from "../auth/TokenProvider";
export class TokenInterceptor { static getAuthHeader(): string { return "Bearer " + TokenProvider.getToken(); } }
