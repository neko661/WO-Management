import { BaseViewModel, MockDatabase, UserInfo } from 'utils';

@ObservedV2
export class UserManageViewModel extends BaseViewModel {
  @Trace users: UserInfo[] = [];
  total: number = 0;
  currentUser: UserInfo = {} as UserInfo;
  isLoading: boolean = false;
  actionMessage: string = '';

  private db: MockDatabase = MockDatabase.getInstance();

  async loadUsers(role?: string): Promise<void> {
    this.isLoading = true;
    try {
      let list: UserInfo[] = this.db.getAllUsers();
      if (role && role !== '') {
        list = list.filter((u: UserInfo): boolean => u.role === role);
      }
      this.users = list;
      this.total = list.length;
    } finally {
      this.isLoading = false;
    }
  }

  getRoleLabel(role: string): string {
    if (role === 'admin') return '管理员';
    if (role === 'leader') return '班组长';
    if (role === 'operator') return '操作员';
    if (role === 'inspector') return '质检员';
    return role;
  }

  getUserById(id: number): UserInfo | null {
    const list: UserInfo[] = this.db.getAllUsers();
    const found: UserInfo | undefined = list.find((u: UserInfo): boolean => u.id === id);
    return found ?? null;
  }

  async createUser(user: UserInfo): Promise<boolean> {
    this.isLoading = true;
    try {
      const created: boolean = this.db.addUser(user);
      if (created) {
        this.actionMessage = '人员创建成功';
        await this.loadUsers();
        return true;
      }
      this.actionMessage = '创建失败';
      return false;
    } finally {
      this.isLoading = false;
    }
  }

  async updateUser(id: number, user: UserInfo): Promise<boolean> {
    this.isLoading = true;
    try {
      const updated: boolean = this.db.updateUser(id, user);
      if (updated) {
        this.actionMessage = '人员信息已更新';
        await this.loadUsers();
        return true;
      }
      this.actionMessage = '人员不存在';
      return false;
    } finally {
      this.isLoading = false;
    }
  }

  async deleteUser(id: number): Promise<boolean> {
    this.isLoading = true;
    try {
      const ok: boolean = this.db.deleteUser(id);
      if (ok) {
        this.actionMessage = '人员已删除';
        await this.loadUsers();
        return true;
      }
      this.actionMessage = '删除失败';
      return false;
    } finally {
      this.isLoading = false;
    }
  }

  generateEmployeeNo(): string {
    const users: UserInfo[] = this.db.getAllUsers();
    const maxId: number = users.reduce((max: number, u: UserInfo): number => Math.max(max, u.id || 0), 0);
    return `user${String(maxId + 1).padStart(3, '0')}`;
  }
}