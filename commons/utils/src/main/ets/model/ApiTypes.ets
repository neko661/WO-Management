export interface ApiResponse<T> {
  code: number;
  msg: string;
  data?: T;
}

// Role type
export type UserRole = "leader" | "operator" | "inspector" | "admin";

export interface LoginRequest {
  employeeNo: string;
  password: string;
  role: UserRole;
}

export interface LoginResponse {
  code: number;
  msg: string;
  data: string;
}

export interface UserInfo {
  id: number;
  employeeNo: string;
  name: string;
  role: UserRole;
  teamId: number;
  workshopId: number;
  status: string;
  avatarUrl: string;
}

// Work order types (minimal for initial skeleton)
export interface WorkOrder {
  id: number;
  code: string;
  type: string;
  productId: number;
  productName: string;
  productCode: string;
  source: string;
  planQty: number;
  status: string;
  operatorId?: number;
  operatorName?: string;
  lineId: number;
  lineName: string;
  processId: number;
  processName: string;
  highlighted?: boolean;
  createdAt?: string;
  updatedAt?: string;
  workshop?: string;
  resource?: string;
  planStartTime?: string;
  planEndTime?: string;
  dispatchTime?: string;
  actualStartTime?: string;
  actualEndTime?: string;
  reportedHours?: number;
  goodQty?: number;
  ngQty?: number;
  statusFlow?: string;
  availableOperators?: string[];
}

// Production line
export interface ProductionLine {
  id: number;
  name: string;
  workshopId: number;
  status: string;
  currentWorkorderId?: number;
  currentProcessId?: number;
}

// Workstation
export interface Workstation {
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
}

// Dashboard
export interface DashboardData {
  todayPlanRate: number;
  totalInput: number;
  totalOutput: number;
  totalNg: number;
  productFinishRate: number;
  operationFinishRate: number;
}

// Production line detail for 基础数据查看
export interface ProductionLineDetail {
  id: number;
  name: string;
  status: string;
  statusTag: string;
  statusTagBg: string;
  statusTagColor: string;
  currentProcess: string;
  supportedProcesses: string[];
  workorderCode?: string;
  rawMaterial?: number;
  goodCount?: number;
  ngCount?: number;
  isRunning: boolean;
  headerBg: string;
  headerTextColor: string;
}

export interface PersonnelGroup {
  role: string;
  roleEn: string;
  members: string[];
}
