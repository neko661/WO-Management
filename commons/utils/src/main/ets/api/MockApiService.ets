import { LoginRequest, UserInfo, WorkOrder, ProductionLine, DashboardData, ProductionLineDetail, PersonnelGroup } from "../model/ApiTypes";
import { LoginResult } from "./HttpApiService";
import { MockDatabase } from "../database/MockDatabase";
import { SessionManager } from "datastore";
import { AppConfig } from "../config/AppConfig";

export interface MockPaginatedList {
  list: WorkOrder[];
  total: number;
  page: number;
  pageSize: number;
}

export interface MockApiResponse<T> {
  code: number;
  msg: string;
  data: T | null;
}

export class MockApiService {
  private static instance: MockApiService;

  static getInstance(): MockApiService {
    if (!MockApiService.instance) {
      MockApiService.instance = new MockApiService();
    }
    return MockApiService.instance;
  }

  private async delay(): Promise<void> {
    await new Promise<void>((r) => { setTimeout(r, AppConfig.MOCK_DELAY); });
  }

  async login(request: LoginRequest): Promise<MockApiResponse<LoginResult>> {
    await this.delay();
    const db: MockDatabase = MockDatabase.getInstance();
    const user: UserInfo | undefined = db.validateUser(request.employeeNo, request.password, request.role);
    if (user) {
      const token: string = "mock_token_" + Date.now();
      const session: SessionManager = SessionManager.getInstance();
      await session.setToken(token);
      await session.setRole(request.role);
      await session.setUserName(user.name);
      await session.setEmployeeNo(user.employeeNo);
      await session.setUserId(user.id.toString());
      const resp: LoginResult = {
        token: token,
        user: user
      };
      return { code: 0, msg: "登录成功", data: resp };
    } else {
      return { code: 1, msg: "账号或密码错误", data: null };
    }
  }

  async register(employeeNo: string, name: string, password: string, role: string): Promise<MockApiResponse<UserInfo>> {
    await this.delay();
    return { code: 0, msg: "注册成功", data: null };
  }

  async getWorkOrders(
    role: string,
    userId?: number,
    page?: number,
    pageSize?: number,
    status?: string,
    keyword?: string
  ): Promise<MockApiResponse<MockPaginatedList>> {
    await this.delay();
    const db: MockDatabase = MockDatabase.getInstance();
    let orders: WorkOrder[] = db.getWorkOrders(role, userId);

    if (status && status.length > 0) {
      orders = orders.filter(o => o.status === status);
    }
    if (keyword && keyword.length > 0) {
      orders = orders.filter(o => o.code.includes(keyword) || o.productName.includes(keyword));
    }

    const p: number = page || 1;
    const ps: number = pageSize || 50;
    const start: number = (p - 1) * ps;
    const end: number = start + ps;
    const list: WorkOrder[] = orders.slice(start, end);

    const result: MockPaginatedList = { list: list, total: orders.length, page: p, pageSize: ps };
    return {
      code: 0,
      msg: "success",
      data: result
    };
  }

  async getWorkOrderDetail(id: number, role: string, userId?: number): Promise<MockApiResponse<WorkOrder>> {
    await this.delay();
    const db: MockDatabase = MockDatabase.getInstance();
    const order: WorkOrder | undefined = db.getWorkOrderById(id);
    if (order) {
      return { code: 0, msg: "success", data: order };
    }
    return { code: 1, msg: "工单不存在", data: null };
  }

  async transitionWorkOrder(
    id: number,
    action: string,
    role: string,
    userId?: number,
    operatorId?: number
  ): Promise<MockApiResponse<WorkOrder>> {
    await this.delay();
    const db: MockDatabase = MockDatabase.getInstance();
    const order: WorkOrder | undefined = db.getWorkOrderById(id);
    if (!order) {
      return { code: 1, msg: "工单不存在", data: null };
    }

    let newStatus: string = order.status;
    let newOperatorId: number | undefined = undefined;
    let newOperatorName: string | undefined = undefined;

    if (action === 'dispatch' && operatorId) {
      const op: UserInfo | undefined = db.getUserById(operatorId);
      newStatus = '已派工';
      newOperatorId = operatorId;
      newOperatorName = op ? op.name : '';
    } else if (action === 'cancel_dispatch') {
      newStatus = '待派工';
      newOperatorId = 0;
      newOperatorName = '';
    } else if (action === 'start') {
      newStatus = '生产中';
    } else if (action === 'complete') {
      newStatus = '生产完成';
    } else if (action === 'pause') {
      newStatus = '生产中暂停';
    } else if (action === 'resume') {
      newStatus = '生产中';
    } else if (action === 'report') {
      newStatus = '已报工';
    } else if (action === 'scrap') {
      newStatus = '已报废';
    } else if (action === 'pause_issue') {
      newStatus = '发放暂停';
    } else if (action === 'resume_issue') {
      newStatus = '发放';
    }

    const updated: WorkOrder | null = db.updateWorkOrder(id, newStatus, newOperatorId, newOperatorName);
    if (updated) {
      return { code: 0, msg: "操作成功", data: updated };
    }
    return { code: 1, msg: "操作失败", data: null };
  }

  async getProductionLines(): Promise<MockApiResponse<ProductionLine[]>> {
    await this.delay();
    return { code: 0, msg: "success", data: MockDatabase.getInstance().getProductionLines() };
  }

  async getDashboard(role: string, userId?: number): Promise<MockApiResponse<DashboardData>> {
    await this.delay();
    return { code: 0, msg: "success", data: MockDatabase.getInstance().getDashboard() };
  }

  async getProductionLineDetails(): Promise<MockApiResponse<ProductionLineDetail[]>> {
    await this.delay();
    return { code: 0, msg: "success", data: MockDatabase.getInstance().getProductionLineDetails() };
  }

  async getPersonnelGroups(): Promise<MockApiResponse<PersonnelGroup[]>> {
    await this.delay();
    return { code: 0, msg: "success", data: MockDatabase.getInstance().getPersonnelGroups() };
  }

  async getUsersByRole(role: string): Promise<MockApiResponse<UserInfo[]>> {
    await this.delay();
    return { code: 0, msg: "success", data: MockDatabase.getInstance().getUsersByRole(role) };
  }
}
