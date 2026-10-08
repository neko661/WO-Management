import { BaseViewModel, HttpApiService, WorkOrder, InspectionRecord as ApiInspectionRecord } from 'utils';
import { SessionManager } from 'datastore';
import {
  QualityOverview, DefectCategory, QualityTrendPoint,
  LineQuality, InspectionRecord, QualityMenuItem
} from '../model/QualityTypes';

interface LineQualityAggregate {
  lineId: number;
  inspected: number;
  defect: number;
  topDefect: Map<string, number>;
}

@ObservedV2
export class QualityOverviewViewModel extends BaseViewModel {
  @Trace overview: QualityOverview = {
    totalInspected: 0, passRate: 0, defectRate: 0,
    pendingInspect: 0, monthlyQualified: 0, monthlyDefect: 0,
    yearToDatePassRate: 0, lastMonthPassRate: 0,
    passRateChange: 0, monthlyDefectChange: 0,
    passRecordCount: 0, conditionalRecordCount: 0, failRecordCount: 0
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
    this.loadMenuItems();
    await this.reloadDashboardData();
  }

  async reloadDashboardData(): Promise<void> {
    let orders: WorkOrder[] = [];
    let inspections: ApiInspectionRecord[] = [];

    try {
      const orderRes = await this.api.getWorkOrders({ pageSize: 200 });
      if (orderRes.code === 0 && orderRes.data) {
        orders = orderRes.data.list;
      }
    } catch (_) {
    }

    try {
      const inspectionRes = await this.api.getInspections({ pageSize: 200 });
      if (inspectionRes.code === 0 && inspectionRes.data) {
        inspections = inspectionRes.data.list;
      }
    } catch (_) {
    }

    const records: InspectionRecord[] = this.buildInspectionRecords(orders, inspections);
    this.recentRecords = records.slice(0, 6);
    this.overview = this.buildOverview(records, orders);
    this.defectCategories = this.buildDefectCategories(records, inspections, orders);
    this.trendData = this.buildTrendData(records, orders);
    this.lineQualityList = this.buildLineQuality(records, inspections, orders);
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

  private buildInspectionRecords(orders: WorkOrder[], inspections: ApiInspectionRecord[]): InspectionRecord[] {
    const result: InspectionRecord[] = [];

    for (let i: number = 0; i < inspections.length; i++) {
      const item: ApiInspectionRecord = inspections[i];
      const mapped: InspectionRecord = {
        id: item.id,
        workorderCode: item.workorderCode,
        productName: this.findOrderProductName(orders, item.workorderCode),
        lineName: this.normalizeLineName(item.lineName),
        inspectorName: item.inspectorName || '质检员',
        inspectedCount: item.sampleQty,
        defectCount: item.ngQty,
        result: this.normalizeResult(item.result, item.ngQty),
        inspectDate: this.extractDate(item.createdAt)
      };
      result.push(mapped);
    }

    if (result.length === 0) {
      return this.convertWorkOrderFallbackRecords(orders);
    }

    result.sort((a: InspectionRecord, b: InspectionRecord) => {
      return this.getDateValue(b.inspectDate) - this.getDateValue(a.inspectDate);
    });
    return result;
  }

  private convertWorkOrderFallbackRecords(orders: WorkOrder[]): InspectionRecord[] {
    const result: InspectionRecord[] = [];
    for (let i: number = 0; i < orders.length; i++) {
      const order: WorkOrder = orders[i];
      const inspectedCount: number = (order.goodQty || 0) + (order.ngQty || 0);
      if (inspectedCount <= 0) {
        continue;
      }
      result.push({
        id: order.id,
        workorderCode: order.code,
        productName: order.productName,
        lineName: this.normalizeLineName(order.lineName),
        inspectorName: this.userName || '系统汇总',
        inspectedCount: inspectedCount,
        defectCount: order.ngQty || 0,
        result: this.normalizeResult(order.status, order.ngQty || 0),
        inspectDate: this.extractDate(this.getOrderActivityDate(order))
      });
    }
    result.sort((a: InspectionRecord, b: InspectionRecord) => {
      return this.getDateValue(b.inspectDate) - this.getDateValue(a.inspectDate);
    });
    return result;
  }

  private buildOverview(records: InspectionRecord[], orders: WorkOrder[]): QualityOverview {
    let totalInspected: number = 0;
    let totalDefect: number = 0;
    let pendingInspect: number = 0;
    let monthlyQualified: number = 0;
    let monthlyDefect: number = 0;
    let lastMonthInspected: number = 0;
    let lastMonthDefect: number = 0;
    let passRecordCount: number = 0;
    let conditionalRecordCount: number = 0;
    let failRecordCount: number = 0;
    const todayDate: string = this.getTodayDate();
    const currentMonth: string = todayDate.substring(0, 7);
    const lastMonth: string = this.getLastMonthPrefix(todayDate);

    for (let i: number = 0; i < records.length; i++) {
      const record: InspectionRecord = records[i];
      totalInspected += record.inspectedCount;
      totalDefect += record.defectCount;
      if (record.result === 'pass') {
        passRecordCount++;
      } else if (record.result === 'fail') {
        failRecordCount++;
      } else {
        conditionalRecordCount++;
      }
      if (record.inspectDate.startsWith(currentMonth)) {
        monthlyQualified += record.inspectedCount - record.defectCount;
        monthlyDefect += record.defectCount;
      }
      if (record.inspectDate.startsWith(lastMonth)) {
        lastMonthInspected += record.inspectedCount;
        lastMonthDefect += record.defectCount;
      }
    }

    for (let i: number = 0; i < orders.length; i++) {
      const status: string = orders[i].status;
      if (status === '生产完成' || status === '待报工' || status === '已报工') {
        pendingInspect++;
      }
    }

    const totalQualified: number = totalInspected - totalDefect;
    const passRate: number = totalInspected > 0 ? (totalQualified * 100 / totalInspected) : 0;
    const defectRate: number = totalInspected > 0 ? (totalDefect * 100 / totalInspected) : 0;
    const lastMonthPassRate: number = lastMonthInspected > 0 ? ((lastMonthInspected - lastMonthDefect) * 100 / lastMonthInspected) : passRate;
    const passRateChange: number = passRate - lastMonthPassRate;
    const monthlyDefectChange: number = monthlyDefect - lastMonthDefect;

    return {
      totalInspected: totalInspected,
      passRate: this.toFixedOne(passRate),
      defectRate: this.toFixedOne(defectRate),
      pendingInspect: pendingInspect,
      monthlyQualified: monthlyQualified,
      monthlyDefect: monthlyDefect,
      yearToDatePassRate: this.toFixedOne(passRate),
      lastMonthPassRate: this.toFixedOne(lastMonthPassRate),
      passRateChange: this.toFixedOne(passRateChange),
      monthlyDefectChange: monthlyDefectChange,
      passRecordCount: passRecordCount,
      conditionalRecordCount: conditionalRecordCount,
      failRecordCount: failRecordCount
    };
  }

  private buildDefectCategories(records: InspectionRecord[], inspections: ApiInspectionRecord[], orders: WorkOrder[]): DefectCategory[] {
    const counter: Map<string, number> = new Map<string, number>();
    for (let i: number = 0; i < inspections.length; i++) {
      const name: string = this.extractDefectName(inspections[i].note);
      const current: number = counter.get(name) || 0;
      counter.set(name, current + inspections[i].ngQty);
    }

    if (counter.size === 0) {
      for (let i: number = 0; i < records.length; i++) {
        if (records[i].defectCount > 0) {
          const current: number = counter.get('报工不良') || 0;
          counter.set('报工不良', current + records[i].defectCount);
        }
      }
    }

    let totalDefect: number = 0;
    counter.forEach((count: number) => {
      totalDefect += count;
    });
    if (totalDefect === 0) {
      totalDefect = this.sumOrderNg(orders);
      if (totalDefect > 0) {
        counter.set('报工不良', totalDefect);
      }
    }

    const colorSeed: string[] = ['#F44336', '#FF9800', '#2196F3', '#9C27B0', '#4CAF50', '#14B8A6'];
    const result: DefectCategory[] = [];
    let index: number = 0;
    counter.forEach((count: number, name: string) => {
      result.push({
        id: index + 1,
        name: name,
        count: count,
        percentage: totalDefect > 0 ? this.toFixedOne(count * 100 / totalDefect) : 0,
        color: colorSeed[index % colorSeed.length],
        trend: index === 0 ? 'up' : index === 1 ? 'stable' : 'down'
      });
      index++;
    });
    result.sort((a: DefectCategory, b: DefectCategory) => b.count - a.count);
    return result;
  }

  private buildTrendData(records: InspectionRecord[], orders: WorkOrder[]): QualityTrendPoint[] {
    const today: Date = new Date(this.getTodayDate() + 'T00:00:00');
    const result: QualityTrendPoint[] = [];

    for (let i: number = 6; i >= 0; i--) {
      const currentDate: Date = new Date(today.getTime() - i * 24 * 60 * 60 * 1000);
      const dateKey: string = this.formatDateKey(currentDate);
      let inspectedCount: number = 0;
      let defectCount: number = 0;

      for (let j: number = 0; j < records.length; j++) {
        if (records[j].inspectDate === dateKey) {
          inspectedCount += records[j].inspectedCount;
          defectCount += records[j].defectCount;
        }
      }

      if (inspectedCount === 0) {
        for (let j: number = 0; j < orders.length; j++) {
          const orderDate: string = this.extractDate(this.getOrderActivityDate(orders[j]));
          if (orderDate === dateKey) {
            inspectedCount += this.getOrderOutputQty(orders[j]);
            defectCount += orders[j].ngQty || 0;
          }
        }
      }

      const passRate: number = inspectedCount > 0 ? ((inspectedCount - defectCount) * 100 / inspectedCount) : 0;
      result.push({
        date: this.formatMonthDay(currentDate),
        passRate: this.toFixedOne(passRate),
        defectCount: defectCount,
        inspectedCount: inspectedCount
      });
    }
    return result;
  }

  private buildLineQuality(records: InspectionRecord[], inspections: ApiInspectionRecord[], orders: WorkOrder[]): LineQuality[] {
    const lineMap: Map<string, LineQualityAggregate> = new Map<string, LineQualityAggregate>();

    for (let i: number = 0; i < records.length; i++) {
      const lineName: string = this.normalizeLineName(records[i].lineName);
      if (!lineMap.has(lineName)) {
        lineMap.set(lineName, this.createLineQualityAggregate(lineName));
      }
      const item: LineQualityAggregate = lineMap.get(lineName) as LineQualityAggregate;
      item.inspected += records[i].inspectedCount;
      item.defect += records[i].defectCount;
    }

    for (let i: number = 0; i < inspections.length; i++) {
      const lineName: string = this.normalizeLineName(inspections[i].lineName);
      if (!lineMap.has(lineName)) {
        lineMap.set(lineName, this.createLineQualityAggregate(lineName));
      }
      const item: LineQualityAggregate = lineMap.get(lineName) as LineQualityAggregate;
      const defectName: string = this.extractDefectName(inspections[i].note);
      const current: number = item.topDefect.get(defectName) || 0;
      item.topDefect.set(defectName, current + inspections[i].ngQty);
    }

    if (lineMap.size === 0) {
      for (let i: number = 0; i < orders.length; i++) {
        const order: WorkOrder = orders[i];
        const lineName: string = this.normalizeLineName(order.lineName);
        if (!lineMap.has(lineName)) {
          lineMap.set(lineName, this.createLineQualityAggregate(lineName));
        }
        const item: LineQualityAggregate = lineMap.get(lineName) as LineQualityAggregate;
        item.inspected += this.getOrderOutputQty(order);
        item.defect += order.ngQty || 0;
      }
    }

    const result: LineQuality[] = [];
    lineMap.forEach((item, lineName: string) => {
      const passRate: number = item.inspected > 0 ? ((item.inspected - item.defect) * 100 / item.inspected) : 0;
      result.push({
        lineId: item.lineId,
        lineName: lineName,
        passRate: this.toFixedOne(passRate),
        inspectedCount: item.inspected,
        defectCount: item.defect,
        topDefect: this.getTopDefectName(item.topDefect),
        status: passRate >= 97 ? 'good' : passRate >= 94 ? 'warning' : 'critical'
      });
    });
    result.sort((a: LineQuality, b: LineQuality) => a.lineId - b.lineId);
    return result;
  }

  private createLineQualityAggregate(lineName: string): LineQualityAggregate {
    return {
      lineId: this.getLineIdByName(lineName),
      inspected: 0,
      defect: 0,
      topDefect: new Map<string, number>()
    };
  }

  private findOrderProductName(orders: WorkOrder[], code: string): string {
    for (let i: number = 0; i < orders.length; i++) {
      if (orders[i].code === code) {
        return orders[i].productName;
      }
    }
    return '生产工单';
  }

  private getOrderActivityDate(order: WorkOrder): string {
    return order.actualEndTime || order.actualStartTime || order.updatedAt || order.createdAt || this.getTodayDate();
  }

  private getOrderOutputQty(order: WorkOrder): number {
    return (order.goodQty || 0) + (order.ngQty || 0);
  }

  private normalizeResult(value: string, defectCount: number): 'pass' | 'fail' | 'conditional' {
    if (value === 'fail' || defectCount > 10) return 'fail';
    if (value === 'conditional' || defectCount > 0) return 'conditional';
    return 'pass';
  }

  private extractDefectName(note: string): string {
    if (!note || note.length === 0) {
      return '未分类不良';
    }
    const marker: string = '不良类型:';
    const index: number = note.indexOf(marker);
    if (index >= 0) {
      const extracted: string = note.substring(index + marker.length).trim();
      if (extracted.length > 0) {
        return extracted;
      }
    }
    return note.length > 12 ? note.substring(0, 12) : note;
  }

  private normalizeLineName(name: string): string {
    if (!name || name.length === 0) {
      return '柔性组装线';
    }
    if (name === '柔性线') return '柔性组装线';
    return name;
  }

  private getTopDefectName(defectMap: Map<string, number>): string {
    let topName: string = '无明显不良';
    let topCount: number = 0;
    defectMap.forEach((count: number, name: string) => {
      if (count > topCount) {
        topCount = count;
        topName = name;
      }
    });
    return topName;
  }

  private getLineIdByName(name: string): number {
    if (name === '柔性组装线') return 1;
    if (name === '智能组装线') return 2;
    if (name === 'SMT产线') return 3;
    if (name === '机加工线') return 4;
    return 99;
  }

  private getDateValue(value: string): number {
    return new Date(value + 'T00:00:00').getTime();
  }

  private extractDate(value: string): string {
    if (!value || value.length < 10) {
      return this.getTodayDate();
    }
    return value.substring(0, 10);
  }

  private formatDateKey(date: Date): string {
    const month: string = (date.getMonth() + 1).toString().padStart(2, '0');
    const day: string = date.getDate().toString().padStart(2, '0');
    return date.getFullYear().toString() + '-' + month + '-' + day;
  }

  private formatMonthDay(date: Date): string {
    const month: string = (date.getMonth() + 1).toString().padStart(2, '0');
    const day: string = date.getDate().toString().padStart(2, '0');
    return month + '/' + day;
  }

  private getTodayDate(): string {
    return this.formatDateKey(new Date());
  }

  private getLastMonthPrefix(todayDate: string): string {
    const current: Date = new Date(todayDate + 'T00:00:00');
    current.setMonth(current.getMonth() - 1);
    const month: string = (current.getMonth() + 1).toString().padStart(2, '0');
    return current.getFullYear().toString() + '-' + month;
  }

  private sumOrderNg(orders: WorkOrder[]): number {
    let total: number = 0;
    for (let i: number = 0; i < orders.length; i++) {
      total += orders[i].ngQty || 0;
    }
    return total;
  }

  private toFixedOne(value: number): number {
    return Math.round(value * 10) / 10;
  }
}
