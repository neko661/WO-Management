import { HttpClient, TokenProvider } from "network";
import {
  ApiResponse,
  UserInfo,
  UserRole,
  WorkOrder,
  ProductionLine,
} from "../model/ApiTypes";

// ============================================================
// Response / Request types
// ============================================================

export interface LoginResult {
  token: string;
  user: UserInfo;
}

export interface PaginatedList<T> {
  list: T[];
  total: number;
  page: number;
  pageSize: number;
}

export interface StatusHistoryItem {
  id: number;
  workorderId: number;
  fromStatus: string;
  toStatus: string;
  operatorId: number;
  operatorName: string;
  remark: string;
  createdAt: string;
}

export interface WorkOrderDetail extends WorkOrder {
  statusHistory: StatusHistoryItem[];
}

export interface LineDetail {
  id: number;
  name: string;
  workshopId: number;
  status: string;
  isRunning: boolean;
  currentWorkorderId: number;
  currentProcessId: number;
  currentWorkOrder: object | null;
  workstations: WorkstationInfo[];
}

export interface WorkstationInfo {
  id: number;
  code: string;
  name: string;
  productionLineId: number;
  deviceStatus: string;
  workStatus: string;
  conveyorStatus: string;
  processedCount: number;
  good: number;
  ng: number;
  processTime: number;
}

export interface InspectionRecord {
  id: number;
  workorderId: number;
  workorderCode: string;
  lineId: number;
  lineName: string;
  inspectorId: number;
  inspectorName: string;
  sampleQty: number;
  ngQty: number;
  result: string;
  note: string;
  createdAt: string;
}

export interface TodoItem {
  id: string;
  type: string;
  title: string;
  description: string;
  workorderId: number;
  workorderCode: string;
  lineId: number;
  priority: string;
  progress: number;
  createdAt: string;
}

export interface DashboardStats {
  totalOrders: number;
  issuedCount: number;
  dispatchedCount: number;
  inProgressCount: number;
  completedCount: number;
  pausedCount: number;
  todayPlanRate: number;
  totalInput: number;
  totalOutput: number;
  totalNg: number;
  productFinishRate: number;
  operationFinishRate: number;
  totalLines: number;
  runningLines: number;
  idleLines: number;
  totalUsers: number;
}

// Request parameter interfaces (explicitly typed for ArkTS)
export interface WorkOrderQueryParams {
  status?: string;
  keyword?: string;
  type?: string;
  lineName?: string;
  page?: number;
  pageSize?: number;
}

export interface CreateWorkOrderRequest {
  productName: string;
  productCode?: string;
  planQty: number;
  lineId: number;
  lineName?: string;
  processName?: string;
  type?: string;
}

export interface UpdateWorkOrderRequest {
  productName?: string;
  productCode?: string;
  planQty?: number;
  lineId?: number;
  lineName?: string;
  processName?: string;
}

export interface TransitionRequest {
  action: string;
  operatorId?: number;
  goodQty?: number;
  ngQty?: number;
  reportedHours?: number;
}

export interface InspectionQueryParams {
  page?: number;
  pageSize?: number;
  workorderId?: number;
}

export interface CreateInspectionRequest {
  workorderId: number;
  lineId?: number;
  sampleQty?: number;
  ngQty?: number;
  result?: string;
  note?: string;
}

export interface CreateUserRequest {
  employeeNo: string;
  name: string;
  password: string;
  role: string;
  teamId?: number;
  workshopId?: number;
}

export interface UpdateUserRequest {
  name?: string;
  role?: string;
  teamId?: number;
  workshopId?: number;
  status?: string;
  password?: string;
}

export interface TodosResponse {
  todos: TodoItem[];
  total: number;
}

// ============================================================
// HttpApiService — Singleton
// ============================================================

export class HttpApiService {
  private static instance: HttpApiService;
  private http: HttpClient;

  static getInstance(): HttpApiService {
    if (!HttpApiService.instance) {
      HttpApiService.instance = new HttpApiService();
    }
    return HttpApiService.instance;
  }

  private constructor() {
    this.http = HttpClient.getInstance();
  }

  // ============================================================
  // Auth
  // ============================================================

  async login(employeeNo: string, password: string, role: string): Promise<ApiResponse<LoginResult>> {
    const body: Record<string, string> = {
      "employeeNo": employeeNo,
      "password": password,
      "role": role,
    };
    const res: ApiResponse<LoginResult> = await this.http.post<ApiResponse<LoginResult>>("/api/auth/login", JSON.stringify(body));

    if (res.code === 0 && res.data) {
      TokenProvider.setToken(res.data.token);
    }
    return res;
  }

  async getMe(): Promise<ApiResponse<UserInfo>> {
    return this.http.get<ApiResponse<UserInfo>>("/api/auth/me");
  }

  async verifyToken(): Promise<ApiResponse<object>> {
    return this.http.get<ApiResponse<object>>("/api/auth/verify");
  }

  async register(employeeNo: string, name: string, password: string, role: string): Promise<ApiResponse<UserInfo>> {
    const body: Record<string, string> = {
      "employeeNo": employeeNo,
      "name": name,
      "password": password,
      "role": role,
    };
    return this.http.post<ApiResponse<UserInfo>>("/api/auth/register", JSON.stringify(body));
  }

  // ============================================================
  // Work Orders
  // ============================================================

  async getWorkOrders(params?: WorkOrderQueryParams): Promise<ApiResponse<PaginatedList<WorkOrder>>> {
    const queryParams: Record<string, string | number> = {};
    if (params) {
      if (params.status) queryParams["status"] = params.status;
      if (params.keyword) queryParams["keyword"] = params.keyword;
      if (params.type) queryParams["type"] = params.type;
      if (params.lineName) queryParams["lineName"] = params.lineName;
      if (params.page) queryParams["page"] = params.page;
      if (params.pageSize) queryParams["pageSize"] = params.pageSize;
    }
    return this.http.get<ApiResponse<PaginatedList<WorkOrder>>>("/api/workorders", queryParams);
  }

  async getWorkOrderDetail(id: number): Promise<ApiResponse<WorkOrderDetail>> {
    return this.http.get<ApiResponse<WorkOrderDetail>>(`/api/workorders/${id}`);
  }

  async createWorkOrder(data: CreateWorkOrderRequest): Promise<ApiResponse<WorkOrder>> {
    return this.http.post<ApiResponse<WorkOrder>>("/api/workorders", JSON.stringify(data));
  }

  async updateWorkOrder(id: number, data: UpdateWorkOrderRequest): Promise<ApiResponse<WorkOrder>> {
    return this.http.put<ApiResponse<WorkOrder>>(`/api/workorders/${id}`, JSON.stringify(data));
  }

  async deleteWorkOrder(id: number): Promise<ApiResponse<null>> {
    return this.http.delete<ApiResponse<null>>(`/api/workorders/${id}`);
  }

  async transitionWorkOrder(id: number, action: string, operatorId?: number, goodQty?: number, ngQty?: number, reportedHours?: number): Promise<ApiResponse<WorkOrder>> {
    const body: Record<string, string | number | undefined> = {
      "action": action,
      "operatorId": operatorId,
      "goodQty": goodQty,
      "ngQty": ngQty,
      "reportedHours": reportedHours
    };
    return this.http.post<ApiResponse<WorkOrder>>(`/api/workorders/${id}/transition`, JSON.stringify(body));
  }

  // ============================================================
  // Production Lines
  // ============================================================

  async getLines(): Promise<ApiResponse<ProductionLine[]>> {
    return this.http.get<ApiResponse<ProductionLine[]>>("/api/lines");
  }

  async getLineDetail(id: number): Promise<ApiResponse<LineDetail>> {
    return this.http.get<ApiResponse<LineDetail>>(`/api/lines/${id}`);
  }

  async startLine(id: number): Promise<ApiResponse<ProductionLine>> {
    return this.http.post<ApiResponse<ProductionLine>>(`/api/lines/${id}/start`);
  }

  async stopLine(id: number): Promise<ApiResponse<ProductionLine>> {
    return this.http.post<ApiResponse<ProductionLine>>(`/api/lines/${id}/stop`);
  }

  async resetLine(id: number): Promise<ApiResponse<ProductionLine>> {
    return this.http.post<ApiResponse<ProductionLine>>(`/api/lines/${id}/reset`);
  }

  // ============================================================
  // Inspections
  // ============================================================

  async getInspections(params?: InspectionQueryParams): Promise<ApiResponse<PaginatedList<InspectionRecord>>> {
    const queryParams: Record<string, string | number> = {};
    if (params) {
      if (params.page) queryParams["page"] = params.page;
      if (params.pageSize) queryParams["pageSize"] = params.pageSize;
      if (params.workorderId) queryParams["workorderId"] = params.workorderId;
    }
    return this.http.get<ApiResponse<PaginatedList<InspectionRecord>>>("/api/inspections", queryParams);
  }

  async createInspection(data: CreateInspectionRequest): Promise<ApiResponse<InspectionRecord>> {
    return this.http.post<ApiResponse<InspectionRecord>>("/api/inspections", JSON.stringify(data));
  }

  // ============================================================
  // Dashboard & Todos
  // ============================================================

  async getDashboard(): Promise<ApiResponse<DashboardStats>> {
    return this.http.get<ApiResponse<DashboardStats>>("/api/dashboard");
  }

  async getTodos(): Promise<ApiResponse<TodosResponse>> {
    return this.http.get<ApiResponse<TodosResponse>>("/api/todos");
  }

  // ============================================================
  // User Management (Admin)
  // ============================================================

  async getUsers(): Promise<ApiResponse<UserInfo[]>> {
    return this.http.get<ApiResponse<UserInfo[]>>("/api/users");
  }
  async createUser(data: CreateUserRequest): Promise<ApiResponse<UserInfo>> {
    return this.http.post<ApiResponse<UserInfo>>("/api/users", JSON.stringify(data));
  }

  async updateUser(id: number, data: UpdateUserRequest): Promise<ApiResponse<UserInfo>> {
    return this.http.put<ApiResponse<UserInfo>>(`/api/users/${id}`, JSON.stringify(data));
  }

  async deleteUser(id: number): Promise<ApiResponse<null>> {
    return this.http.delete<ApiResponse<null>>(`/api/users/${id}`);
  }
}
