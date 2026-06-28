export interface QualityOverview {
  totalInspected: number;
  passRate: number;
  defectRate: number;
  pendingInspect: number;
  monthlyQualified: number;
  monthlyDefect: number;
  yearToDatePassRate: number;
  lastMonthPassRate: number;
}

export interface DefectCategory {
  id: number;
  name: string;
  count: number;
  percentage: number;
  color: string;
  trend: 'up' | 'down' | 'stable';
}

export interface QualityTrendPoint {
  date: string;
  passRate: number;
  defectCount: number;
  inspectedCount: number;
}

export interface LineQuality {
  lineId: number;
  lineName: string;
  passRate: number;
  inspectedCount: number;
  defectCount: number;
  topDefect: string;
  status: 'good' | 'warning' | 'critical';
}

export interface InspectionRecord {
  id: number;
  workorderCode: string;
  productName: string;
  lineName: string;
  inspectorName: string;
  inspectedCount: number;
  defectCount: number;
  result: 'pass' | 'fail' | 'conditional';
  inspectDate: string;
}

export interface QualityMenuItem {
  id: number;
  title: string;
  description: string;
  icon: Resource;
  iconBg: string;
  iconColor: string;
  targetPage: string;
}
