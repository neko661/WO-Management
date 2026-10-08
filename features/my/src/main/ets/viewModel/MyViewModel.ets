import { BaseViewModel } from 'utils';
import { SessionManager } from 'datastore';
import { ProfileData } from '../model/MyTypes';

@ObservedV2
export class MyViewModel extends BaseViewModel {
  @Trace profile: ProfileData = {
    employeeNo: '',
    name: '',
    role: '',
    currentRole: '',
    status: '在岗',
    appVersion: 'v1.0.0'
  };
  private session: SessionManager = SessionManager.getInstance();

  async init(): Promise<void> {
    const employeeNo: string = await this.session.getEmployeeNo();
    const name: string = await this.session.getUserName();
    const role: string = await this.session.getRole();
    this.profile = {
      employeeNo: employeeNo,
      name: name,
      role: role,
      currentRole: this.getRoleLabel(role),
      status: '在岗',
      appVersion: this.profile.appVersion
    };
  }

  getRoleLabel(role?: string): string {
    const r: string = role || this.profile.role;
    if (r === 'leader') return '班组长';
    if (r === 'operator') return '操作员';
    if (r === 'inspector') return '质检员';
    if (r === 'admin') return '管理员';
    return r;
  }

  getAccountLabel(): string {
    return this.profile.role + ' · ' + this.profile.employeeNo + ' / 123456';
  }

  async logout(onLogout: () => void): Promise<void> {
    await this.session.clear();
    onLogout();
  }
}
