export interface ChartDataItem {
  label: string;
  value: number;
  color: string;
}

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

// 产线详情完整数据
export interface LineDetailFull {
  id: number;
  name: string;
  status: string;
  statusTag: string;
  workorderCode: string;
  currentProcess: string;
  processDescription: string;
  operatorName: string;
  workorderStatus: string;
  rawMaterial: number;
  finishedProduct: number;
  ngCount: number;
}

// 工作站摘要（用于产线详情列表）
export interface WorkstationDetail {
  id: number;
  code: string;
  name: string;
  deviceStatus: string;
  workStatus: string;
  conveyorStatus: string;
  productCode: string;
  processingTime: string;
  processedCount: number;
  goodCount: number;
  ngCount: number;
  status: string;
}

// 工作站状态描述
export interface StationStateData {
  deviceStatus: string;
  deviceStatusDesc: string;
  workStatus: string;
  workAction: string;
  workActionDesc: string;
  conveyorStatus: string;
  conveyorDirection: string;
  conveyorDesc: string;
  workorderStatus: string;
}

// 工作站完整详情
export interface WorkstationFullDetail {
  id: number;
  code: string;
  name: string;
  lineId: number;
  lineName: string;
  deviceCode: string;
  deviceStatus: string;
  deviceStatusDesc: string;
  workStatus: string;
  workAction: string;
  workActionDesc: string;
  conveyorStatus: string;
  conveyorDirection: string;
  conveyorDesc: string;
  currentProcess: string;
  workorderCode: string;
  productName: string;
  operatorName: string;
  workorderStatus: string;
  processedCount: number;
  rawMaterial: number;
  goodCount: number;
  ngCount: number;
  processingTime: string;
}
