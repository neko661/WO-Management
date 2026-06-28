import { PreferencesUtils } from '../preferences/PreferencesUtils';

const KEY_TOKEN = 'token';
const KEY_ROLE = 'role';
const KEY_USER_NAME = 'userName';
const KEY_EMPLOYEE_NO = 'employeeNo';
const KEY_USER_ID = 'userId';

export class SessionManager {
  private static instance: SessionManager;
  private prefs: PreferencesUtils = PreferencesUtils.getInstance();

  static getInstance(): SessionManager {
    if (!SessionManager.instance) {
      SessionManager.instance = new SessionManager();
    }
    return SessionManager.instance;
  }

  async init(ctx: Context): Promise<void> {
    await this.prefs.init(ctx);
  }

  async setToken(token: string): Promise<void> { await this.prefs.put(KEY_TOKEN, token); }
  async getToken(): Promise<string> { return await this.prefs.get(KEY_TOKEN); }

  async setRole(role: string): Promise<void> { await this.prefs.put(KEY_ROLE, role); }
  async getRole(): Promise<string> { return await this.prefs.get(KEY_ROLE); }

  async setUserName(userName: string): Promise<void> { await this.prefs.put(KEY_USER_NAME, userName); }
  async getUserName(): Promise<string> { return await this.prefs.get(KEY_USER_NAME); }

  async setEmployeeNo(employeeNo: string): Promise<void> { await this.prefs.put(KEY_EMPLOYEE_NO, employeeNo); }
  async getEmployeeNo(): Promise<string> { return await this.prefs.get(KEY_EMPLOYEE_NO); }

  async setUserId(userId: string): Promise<void> { await this.prefs.put(KEY_USER_ID, userId); }
  async getUserId(): Promise<string> { return await this.prefs.get(KEY_USER_ID); }

  async clear(): Promise<void> {
    await this.prefs.delete(KEY_TOKEN);
    await this.prefs.delete(KEY_ROLE);
    await this.prefs.delete(KEY_USER_NAME);
    await this.prefs.delete(KEY_EMPLOYEE_NO);
    await this.prefs.delete(KEY_USER_ID);
  }
}
