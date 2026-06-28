import { UserInfo, UserRole, WorkOrder, ProductionLine, DashboardData, ProductionLineDetail, PersonnelGroup } from "../model/ApiTypes";

export class MockDatabase {
  private static instance: MockDatabase;

  static getInstance(): MockDatabase {
    if (!MockDatabase.instance) MockDatabase.instance = new MockDatabase();
    return MockDatabase.instance;
  }

  private users: UserInfo[] = [
    { id: 1, employeeNo: "admin", name: "张建国", role: "admin", teamId: 0, workshopId: 0, status: "在岗", avatarUrl: "" },
    { id: 2, employeeNo: "leader", name: "王志刚", role: "leader", teamId: 1, workshopId: 1, status: "在岗", avatarUrl: "" },
    { id: 3, employeeNo: "liuwei", name: "刘伟", role: "operator", teamId: 1, workshopId: 1, status: "在岗", avatarUrl: "" },
    { id: 4, employeeNo: "liqiang", name: "李强", role: "operator", teamId: 1, workshopId: 1, status: "在岗", avatarUrl: "" },
    { id: 5, employeeNo: "zhaomin", name: "赵敏", role: "operator", teamId: 1, workshopId: 1, status: "在岗", avatarUrl: "" },
    { id: 6, employeeNo: "inspector", name: "陈静", role: "inspector", teamId: 1, workshopId: 1, status: "在岗", avatarUrl: "" },
  ];

  getAllUsers(): UserInfo[] {
    return this.users.slice();
  }

  private workOrders: WorkOrder[] = [
    { id: 1, code: "MO000001", type: "量产", productId: 1, productName: "无线充电器组装", productCode: "PROD-WC-001", source: "Web 创建", planQty: 100, status: "待报工", operatorId: 3, operatorName: "刘伟", lineId: 1, lineName: "柔性线", processId: 1, processName: "无线充电器组装", workshop: "柔性车间", resource: "柔性线", actualStartTime: "2026-05-01 08:05", actualEndTime: "2026-05-01 09:55", planStartTime: "2026-05-01 08:00", planEndTime: "2026-05-01 18:00", reportedHours: 1.8, goodQty: 96, ngQty: 4, statusFlow: "已派工 → 生产中" },
    { id: 2, code: "MO000002", type: "量产", productId: 1, productName: "无线充电器组装", productCode: "PROD-WC-001", source: "Web 创建", planQty: 800, status: "完工", operatorId: 3, operatorName: "刘伟", lineId: 1, lineName: "柔性组装线", processId: 1, processName: "无线充电器组装" },
    { id: 3, code: "MO000003", type: "量产", productId: 1, productName: "无线充电器组装", productCode: "PROD-WC-001", source: "Web 创建", planQty: 1200, status: "生产中", operatorId: 3, operatorName: "刘伟", lineId: 1, lineName: "柔性组装线", processId: 1, processName: "无线充电器组装" },
    { id: 4, code: "MO000004", type: "量产", productId: 1, productName: "无线充电器组装", productCode: "PROD-WC-001", source: "Web 创建", planQty: 600, status: "已派工", operatorId: 3, operatorName: "刘伟", lineId: 1, lineName: "柔性组装线", processId: 1, processName: "无线充电器组装" },
    { id: 5, code: "MO000005", type: "量产", productId: 1, productName: "无线充电器组装", productCode: "PROD-WC-001", source: "Web 创建", planQty: 500, status: "待派工", lineId: 1, lineName: "柔性组装线", processId: 1, processName: "无线充电器组装" },
    { id: 6, code: "MO000006", type: "量产", productId: 1, productName: "无线充电器组装", productCode: "PROD-WC-001", source: "Web 创建", planQty: 400, status: "发放", lineId: 1, lineName: "柔性组装线", processId: 1, processName: "无线充电器组装" },
    { id: 7, code: "MO000007", type: "量产", productId: 1, productName: "无线充电器组装", productCode: "PROD-WC-001", source: "Web 创建", planQty: 1500, status: "生产中暂停", operatorId: 3, operatorName: "刘伟", lineId: 1, lineName: "柔性组装线", processId: 1, processName: "无线充电器组装", highlighted: true },
    { id: 8, code: "MO000008", type: "量产", productId: 2, productName: "智能插座组装", productCode: "PROD-SP-001", source: "Web 创建", planQty: 900, status: "已派工", operatorId: 5, operatorName: "赵敏", lineId: 1, lineName: "柔性组装线", processId: 2, processName: "智能插座组装" },
    { id: 9, code: "MO000009", type: "量产", productId: 2, productName: "智能插座组装", productCode: "PROD-SP-001", source: "Web 创建", planQty: 700, status: "生产完成", operatorId: 4, operatorName: "李强", lineId: 1, lineName: "柔性组装线", processId: 2, processName: "智能插座组装" },
  ];

  validateUser(employeeNo: string, password: string, role: UserRole): UserInfo | undefined {
    return this.users.find(u => u.employeeNo === employeeNo && u.role === role);
  }

  getUserById(id: number): UserInfo | undefined {
    return this.users.find(u => u.id === id);
  }

  getUsersByRole(role: string): UserInfo[] {
    return this.users.filter(u => u.role === role);
  }

  getWorkOrders(role: string, userId?: number): WorkOrder[] {
    if (role === 'operator' && userId) {
      return this.workOrders.filter(o => o.operatorId === userId);
    }
    return this.workOrders.slice();
  }

  getWorkOrderById(id: number): WorkOrder | undefined {
    return this.workOrders.find(o => o.id === id);
  }

  updateWorkOrder(id: number, status?: string, operatorId?: number, operatorName?: string): WorkOrder | null {
    const idx: number = this.workOrders.findIndex(o => o.id === id);
    if (idx < 0) return null;
    const old: WorkOrder = this.workOrders[idx];
    if (status) old.status = status;
    if (operatorId) old.operatorId = operatorId;
    if (operatorName) old.operatorName = operatorName;
    return old;
  }

  getProductionLines(): ProductionLine[] {
    return [
      { id: 1, name: "柔性组装线", workshopId: 2, status: "生产中", currentWorkorderId: 2, currentProcessId: 1 },
      { id: 2, name: "智能组装线", workshopId: 3, status: "空闲" },
      { id: 3, name: "SMT产线", workshopId: 4, status: "空闲" },
      { id: 4, name: "机加工线", workshopId: 1, status: "空闲" },
    ];
  }

  getDashboard(): DashboardData {
    return {
      todayPlanRate: 75.5,
      totalInput: 3150,
      totalOutput: 2980,
      totalNg: 45,
      productFinishRate: 82.3,
      operationFinishRate: 68.7
    };
  }

  getProductionLineDetails(): ProductionLineDetail[] {
    return [
      {
        id: 1,
        name: "柔性组装线",
        status: "running",
        statusTag: "生产中",
        statusTagBg: "#4CAF50",
        statusTagColor: "#FFFFFF",
        currentProcess: "无线充电器组装",
        supportedProcesses: ["无线充电器组装", "智能插座组装"],
        workorderCode: "MO0000002",
        rawMaterial: 81,
        goodCount: 5,
        ngCount: 1,
        isRunning: true,
        headerBg: "#FFFFFF",
        headerTextColor: "#1A2B3C"
      },
      {
        id: 2,
        name: "智能组装线",
        status: "idle",
        statusTag: "只读展示",
        statusTagBg: "rgba(255,255,255,0.18)",
        statusTagColor: "#FFFFFF",
        currentProcess: "智能手机组装",
        supportedProcesses: ["智能手机组装", "智能平板组装"],
        isRunning: false,
        headerBg: "#2C3E50",
        headerTextColor: "#FFFFFF"
      },
      {
        id: 3,
        name: "SMT产线",
        status: "idle",
        statusTag: "只读展示",
        statusTagBg: "rgba(255,255,255,0.18)",
        statusTagColor: "#FFFFFF",
        currentProcess: "数据采集器主板贴装",
        supportedProcesses: ["数据采集器主板贴装", "无线充电器主板贴装"],
        isRunning: false,
        headerBg: "#2C3E50",
        headerTextColor: "#FFFFFF"
      },
      {
        id: 4,
        name: "机加工线",
        status: "idle",
        statusTag: "只读展示",
        statusTagBg: "rgba(255,255,255,0.18)",
        statusTagColor: "#FFFFFF",
        currentProcess: "外壳加工",
        supportedProcesses: ["外壳加工", "零件精加工"],
        isRunning: false,
        headerBg: "#2C3E50",
        headerTextColor: "#FFFFFF"
      }
    ];
  }

  getPersonnelGroups(): PersonnelGroup[] {
    return [
      { role: "管理员", roleEn: "admin", members: ["张建国"] },
      { role: "班组长", roleEn: "leader", members: ["王志刚"] },
      { role: "操作员", roleEn: "operator", members: ["刘伟", "李强", "赵敏"] },
      { role: "质检员", roleEn: "inspector", members: ["陈静"] }
    ];
  }

  addUser(user: UserInfo): boolean {
    const maxId = this.users.reduce((max: number, u: UserInfo) => Math.max(max, u.id || 0), 0);
    user.id = maxId + 1;
    user.status = user.status || '在岗';
    user.teamId = user.teamId || 1;
    user.workshopId = user.workshopId || 1;
    this.users.push(user);
    return true;
  }

  updateUser(id: number, user: UserInfo): boolean {
    const idx: number = this.users.findIndex(u => u.id === id);
    if (idx < 0) return false;
    const old: UserInfo = this.users[idx];
    old.name = user.name;
    old.employeeNo = user.employeeNo;
    old.role = user.role;
    old.status = user.status || old.status;
    return true;
  }

  deleteUser(id: number): boolean {
    const idx: number = this.users.findIndex(u => u.id === id);
    if (idx < 0) return false;
    this.users.splice(idx, 1);
    return true;
  }
}
