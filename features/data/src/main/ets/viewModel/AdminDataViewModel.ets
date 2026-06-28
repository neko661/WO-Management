import { BaseViewModel, HttpApiService, ProductionLine, ProductionLineDetail, UserInfo, PersonnelGroup } from 'utils';

@ObservedV2
export class AdminDataViewModel extends BaseViewModel {
  @Trace currentTab: number = 0; // 0: 产线与工艺, 1: 人员
  @Trace productionLines: ProductionLineDetail[] = [];
  @Trace personnelGroups: PersonnelGroup[] = [];

  private api: HttpApiService = HttpApiService.getInstance();

  async init(): Promise<void> {
    await this.loadProductionLines();
    await this.loadPersonnelGroups();
  }

  async loadProductionLines(): Promise<void> {
    try {
      const res = await this.api.getLines();
      if (res.code === 0 && res.data) {
        const details: ProductionLineDetail[] = [];
        for (let i: number = 0; i < res.data.length; i++) {
          const line: ProductionLine = res.data[i];
          const isRunning: boolean = !!line.currentWorkorderId;
          const detail: ProductionLineDetail = {
            id: line.id,
            name: line.name,
            status: isRunning ? 'running' : 'idle',
            statusTag: isRunning ? '生产��' : '只读展示',
            statusTagBg: isRunning ? '#4CAF50' : 'rgba(255,255,255,0.18)',
            statusTagColor: '#FFFFFF',
            currentProcess: '—',
            supportedProcesses: [],
            workorderCode: undefined,
            isRunning: isRunning,
            headerBg: isRunning ? '#FFFFFF' : '#2C3E50',
            headerTextColor: isRunning ? '#1A2B3C' : '#FFFFFF',
          };
          details.push(detail);
        }
        this.productionLines = details;
      }
    } catch (_) {
      this.productionLines = [];
    }
  }

  async loadPersonnelGroups(): Promise<void> {
    try {
      const res = await this.api.getUsers();
      if (res.code === 0 && res.data) {
        const groups: PersonnelGroup[] = [];
        const roleLabels: Record<string, string> = {
          'admin': '管理员',
          'leader': '班组长',
          'operator': '操作员',
          'inspector': '质检员',
        };

        const adminUsers: string[] = [];
        const leaderUsers: string[] = [];
        const operatorUsers: string[] = [];
        const inspectorUsers: string[] = [];

        for (let i: number = 0; i < res.data.length; i++) {
          const user: UserInfo = res.data[i];
          if (user.role === 'admin') adminUsers.push(user.name);
          else if (user.role === 'leader') leaderUsers.push(user.name);
          else if (user.role === 'operator') operatorUsers.push(user.name);
          else if (user.role === 'inspector') inspectorUsers.push(user.name);
        }

        const roleKeys: string[] = ['admin', 'leader', 'operator', 'inspector'];
        const roleMembers: string[][] = [adminUsers, leaderUsers, operatorUsers, inspectorUsers];

        for (let j: number = 0; j < roleKeys.length; j++) {
          const role: string = roleKeys[j];
          const members: string[] = roleMembers[j];
          if (members.length > 0) {
            const group: PersonnelGroup = {
              role: roleLabels[role] || role,
              roleEn: role,
              members: members,
            };
            groups.push(group);
          }
        }

        this.personnelGroups = groups;
      }
    } catch (_) {
      this.personnelGroups = [];
    }
  }

  switchTab(index: number): void {
    this.currentTab = index;
    // 切换到人员 tab 时刷新数据
    if (index === 1) {
      this.loadPersonnelGroups();
    }
  }

  getGroupSummary(): string {
    const parts: string[] = [];
    for (let i: number = 0; i < this.personnelGroups.length; i++) {
      const g: PersonnelGroup = this.personnelGroups[i];
      parts.push(`${g.members.length} ${g.role}`);
    }
    return parts.join(' / ');
  }
}
