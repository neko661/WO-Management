import { http } from "@kit.NetworkKit";
import { TokenProvider } from "../auth/TokenProvider";
import { LogInterceptor } from "../interceptors/LogInterceptor";

export interface HttpRequestOptions {
  method: http.RequestMethod;
  headers?: Record<string, string>;
  body?: string;
  timeout?: number;
}

export class HttpClient {
  private static instance: HttpClient;
  // 如果在模拟器上运行，通常需要使用 10.0.2.2 或者你电脑的局域网 IP
  // 如果在真机上运行，必须使用你电脑的局域网 IP (例如 192.168.x.x)
  private baseUrl: string = "http://10.0.2.2:3002";

  static getInstance(): HttpClient {
    if (!HttpClient.instance) {
      HttpClient.instance = new HttpClient();
    }
    return HttpClient.instance;
  }

  setBaseUrl(url: string): void {
    this.baseUrl = url;
  }

  getBaseUrl(): string {
    return this.baseUrl;
  }

  private buildUrl(path: string): string {
    if (path.startsWith("http")) {
      return path;
    }
    return `${this.baseUrl}${path}`;
  }

  async get<T>(path: string, params?: Record<string, string | number>): Promise<T> {
    let url: string = this.buildUrl(path);
    if (params) {
      const parts: string[] = [];
      const keys: string[] = Object.keys(params);
      for (let i: number = 0; i < keys.length; i++) {
        const k: string = keys[i];
        const v: string | number | undefined = params[k];
        if (v !== undefined && v !== null) {
          parts.push(`${encodeURIComponent(k)}=${encodeURIComponent(String(v))}`);
        }
      }
      if (parts.length > 0) {
        url = `${url}?${parts.join("&")}`;
      }
    }
    return this.doRequest<T>(url, http.RequestMethod.GET);
  }

  async post<T>(path: string, bodyStr?: string): Promise<T> {
    const url: string = this.buildUrl(path);
    return this.doRequest<T>(url, http.RequestMethod.POST, bodyStr);
  }

  async put<T>(path: string, bodyStr?: string): Promise<T> {
    const url: string = this.buildUrl(path);
    return this.doRequest<T>(url, http.RequestMethod.PUT, bodyStr);
  }

  async delete<T>(path: string): Promise<T> {
    const url: string = this.buildUrl(path);
    return this.doRequest<T>(url, http.RequestMethod.DELETE);
  }

  private async doRequest<T>(url: string, method: http.RequestMethod, bodyStr?: string): Promise<T> {
    const httpReq: http.HttpRequest = http.createHttp();
    const token: string = TokenProvider.getToken();

    // Build headers
    const reqHeaders: Record<string, string> = {
      "Content-Type": "application/json",
    };
    if (token.length > 0) {
      reqHeaders["Authorization"] = `Bearer ${token}`;
    }

    LogInterceptor.log(`${method} ${url}`);

    // Build request options — must be a plain object matching http.HttpRequestOptions
    const reqOptions: http.HttpRequestOptions = {
      method: method,
      header: reqHeaders,
      connectTimeout: 10000,
      readTimeout: 10000,
    };

    // Add body for POST/PUT
    if (bodyStr && bodyStr.length > 0) {
      reqOptions.extraData = bodyStr;
    }

    try {
      const resp: http.HttpResponse = await httpReq.request(url, reqOptions);
      const code: number = resp.responseCode;
      const result: string = (resp.result as string) || "";

      LogInterceptor.log(`Response: ${code}, bodyLen=${result.length}`);

      if (code === 401) {
        TokenProvider.clearToken();
      }

      if (result.length > 0) {
        const parsed: T = JSON.parse(result) as T;
        return parsed;
      }
      // Return empty response as null
      return null as T;
    } catch (err) {
      const errObj: Error = err as Error;
      const msg: string = errObj.message || "unknown";
      LogInterceptor.log(`Request FAILED: ${url}, method=${method}, error=${msg}`);
      throw new Error(`HTTP ${method} ${url} failed: ${msg}`);
    } finally {
      httpReq.destroy();
    }
  }
}
