/**
 * In-memory token holder for quick access during HTTP requests.
 * Synced with SessionManager on login/logout.
 */
export class TokenProvider {
  private static token: string = "";

  static setToken(t: string): void {
    TokenProvider.token = t;
  }

  static getToken(): string {
    return TokenProvider.token;
  }

  static clearToken(): void {
    TokenProvider.token = "";
  }

  static hasToken(): boolean {
    return TokenProvider.token.length > 0;
  }
}
