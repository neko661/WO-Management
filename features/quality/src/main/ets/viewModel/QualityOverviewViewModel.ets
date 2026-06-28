import { BaseViewModel, HttpApiService } from 'utils';
import { SessionManager } from 'datastore';
import {
  QualityOverview, DefectCategory, QualityTrendPoint,
  LineQuality, InspectionRecord, QualityMenuItem
} from '../model/QualityTypes';

@ObservedV2
export class QualityOverviewViewModel extends BaseViewModel {
  @Trace overview: QualityOverview = {
    totalInspected: 0, passRate: 0, defectRate: 0,
    pendingInspect: 0, monthlyQualified: 0, monthlyDefect: 0,
    yearToDatePassRate: 0, lastMonthPassRate: 0
  };
  @Trace defectCategories: DefectCategory[] = [];
  @Trace trendData: QualityTrendPoint[] = [];
  @Trace lineQualityList: LineQuality[] = [];
  @Trace recentRecords: InspectionRecord[] = [];
  @Trace menuItems: QualityMenuItem[] = [];
  @Trace currentTab: number = 0;
  @Trace userName: string = '';

  private api: HttpApiService = HttpApiService.getInstance();
  private session: SessionManager = SessionManager.getInstance();

  async init(): Promise<void> {
    this.userName = await this.session.getUserName();
    this.loadOverview();
    this.loadDefectCategories();
    this.loadTrendData();
    this.loadLineQuality();
    this.loadRecentRecords();
    this.loadMenuItems();
  }

  loadOverview(): void {
    this.overview = {
      totalInspected: 12580,
      passRate: 96.4,
      defectRate: 3.6,
      pendingInspect: 12,
      monthlyQualified: 3240,
      monthlyDefect: 118,
      yearToDatePassRate: 95.8,
      lastMonthPassRate: 96.1
    };
  }

  loadDefectCategories(): void {
    this.defectCategories = [
      { id: 1, name: '外观缺陷', count: 156, percentage: 34.5, color: '#F44336', trend: 'up' },
      { id: 2, name: '尺寸偏差', count: 98, percentage: 21.7, color: '#FF9800', trend: 'stable' },
      { id: 3, name: '装配不良', count: 87, percentage: 19.2, color: '#2196F3', trend: 'down' },
      { id: 4, name: '电气性能', count: 65, percentage: 14.4, color: '#9C27B0', trend: 'down' },
      { id: 5, name: '包装问题', count: 46, percentage: 10.2, color: '#4CAF50', trend: 'stable' },
    ];
  }

  loadTrendData(): void {
    this.trendData = [
      { date: '06/19', passRate: 95.8, defectCount: 18, inspectedCount: 430 },
      { date: '06/20', passRate: 96.2, defectCount: 16, inspectedCount: 425 },
      { date: '06/21', passRate: 95.5, defectCount: 20, inspectedCount: 440 },
      { date: '06/22', passRate: 96.8, defectCount: 14, inspectedCount: 438 },
      { date: '06/23', passRate: 97.1, defectCount: 12, inspectedCount: 420 },
      { date: '06/24', passRate: 96.4, defectCount: 15, inspectedCount: 415 },
      { date: '06/25', passRate: 96.9, defectCount: 13, inspectedCount: 428 },
    ];
  }

  loadLineQuality(): void {
    this.lineQualityList = [
      { lineId: 1, lineName: '柔性组装线', passRate: 97.2, inspectedCount: 3200, defectCount: 90, topDefect: '外观缺陷', status: 'good' },
      { lineId: 2, lineName: '智能组装线', passRate: 94.8, inspectedCount: 2800, defectCount: 146, topDefect: '尺寸偏差', status: 'warning' },
      { lineId: 3, lineName: 'SMT产线', passRate: 98.5, inspectedCount: 4100, defectCount: 62, topDefect: '装配不良', status: 'good' },
      { lineId: 4, lineName: '机加工线', passRate: 93.2, inspectedCount: 2480, defectCount: 169, topDefect: '电气性能', status: 'critical' },
    ];
  }

  loadRecentRecords(): void {
    this.recentRecords = [
      { id: 1, workorderCode: 'MO000001', productName: '无线充电器组装', lineName: '柔性组装线',
        inspectorName: '陈静', inspectedCount: 200, defectCount: 5, result: 'pass', inspectDate: '2025-06-25' },
      { id: 2, workorderCode: 'MO000002', productName: '无线充电器组装', lineName: '柔性组装线',
        inspectorName: '陈静', inspectedCount: 160, defectCount: 8, result: 'conditional', inspectDate: '2025-06-24' },
      { id: 3, workorderCode: 'MO000003', productName: '智能插座组装', lineName: '智能组装线',
        inspectorName: '张明', inspectedCount: 240, defectCount: 0, result: 'pass', inspectDate: '2025-06-24' },
      { id: 4, workorderCode: 'MO000004', productName: 'PCB焊接', lineName: 'SMT产线',
        inspectorName: '李芳', inspectedCount: 500, defectCount: 3, result: 'pass', inspectDate: '2025-06-23' },
      { id: 5, workorderCode: 'MO000005', productName: '机加工件', lineName: '机加工线',
        inspectorName: '王磊', inspectedCount: 180, defectCount: 12, result: 'fail', inspectDate: '2025-06-23' },
    ];
  }

  loadMenuItems(): void {
    this.menuItems = [
      { id: 1, title: '质检概览', description: '查看质检整体数据与KPI指标',
        icon: $r('app.media.billboard'), iconBg: '#E3F2FD', iconColor: '#007DFF', targetPage: 'overview' },
      { id: 2, title: '缺陷统计', description: '按类别查看缺陷分布与排行',
        icon: $r('app.media.ticket'), iconBg: '#FCE4EC', iconColor: '#E91E63', targetPage: 'defect' },
      { id: 3, title: '质量趋势', description: '查看质量指标趋势变化图',
        icon: $r('app.media.data'), iconBg: '#E8F5E9', iconColor: '#4CAF50', targetPage: 'trend' },
      { id: 4, title: '质检报告', description: '生成与查看质检报告记录',
        icon: $r('app.media.produce'), iconBg: '#FFF3E0', iconColor: '#FF9800', targetPage: 'report' },
    ];
  }

  switchTab(index: number): void {
    this.currentTab = index;
  }
}
