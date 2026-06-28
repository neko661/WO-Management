/**
 * Global app configuration
 */
export class AppConfig {
  // Backend server URL — change this for production
  // 如果在模拟器上运行，通常需要使用 10.0.2.2 或者你电脑的局域网 IP
  // 如果在真机上运行，必须使用你电脑的局域网 IP (例如 192.168.x.x)
  static readonly BASE_URL: string = "http://10.0.2.2:3002";
  // WebSocket URL
  static readonly WS_URL: string = "ws://10.0.2.2:3002";
  static readonly CONNECT_TIMEOUT: number = 10000;
  static readonly READ_TIMEOUT: number = 10000;
  static readonly MOCK_DELAY: number = 500;

  // Session Keys
  static readonly KEY_TOKEN: string = "token";
  static readonly KEY_ROLE: string = "role";
  static readonly KEY_USER_NAME: string = "userName";
  static readonly KEY_EMPLOYEE_NO: string = "employeeNo";
  static readonly KEY_USER_ID: string = "userId";
}
