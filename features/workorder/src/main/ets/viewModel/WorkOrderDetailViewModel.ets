import { HttpApiService, WorkOrder, StatusHistoryItem } from 'utils';

interface DateTimeParts {
  date: string;
  time: string;
}

@ObservedV2
export class WorkOrderDetailViewModel {
  @Trace order: WorkOrder | null = null;
  @Trace statusHistory: StatusHistoryItem[] = [];
  @Trace isLoading: boolean = false;
  @Trace errorMessage: string = '';
  @Trace selectedOperator: string = '刘伟';
  @Trace showDispatchSection: boolean = false;
  @Trace showStartSection: boolean = false;
  @Trace showPauseSection: boolean = false;
  @Trace showConfirmHoursSection: boolean = false;
  @Trace showCompletedSection: boolean = false;
  @Trace showReportSection: boolean = false;
  @Trace showAutoProductionResult: boolean = false;
  @Trace showResumeScrapSection: boolean = false;
  @Trace showIssueToDispatchSection: boolean = false;
  @Trace reportHours: string = '1.8';
  @Trace reportGoodQty: string = '96';
  @Trace reportNgQty: string = '4';
  @Trace reportRemark: string = '';
  onStatusChanged: ((orderId: number, action: string) => void) | null = null;

  private api: HttpApiService = HttpApiService.getInstance();

  async init(orderId: number): Promise<void> {
    this.isLoading = true;
    try {
      const res = await this.api.getWorkOrderDetail(orderId);
      if (res.code === 0 && res.data) {
        this.order = this.enhanceOrderData(res.data);
        this.statusHistory = res.data.statusHistory || [];
      } else {
        this.order = this.getMockOrder(orderId);
      }
    } catch (_) {
      this.order = this.getMockOrder(orderId);
    } finally {
      this.isLoading = false;
      this.updateSectionsByStatus();
    }
  }

  private updateSectionsByStatus(): void {
    const status: string = this.order ? this.order.status : '';
    this.showDispatchSection = status === '待派工';
    this.showStartSection = status === '已派工';
    this.showPauseSection = status === '生产中';
    this.showConfirmHoursSection = status === '已报工'; // 班组长确认工时
    this.showReportSection = status === '待报工' || status === '生产完成'; // 操作员报工
    this.showAutoProductionResult = status === '待报工' || status === '生产完成' || status === '已报工' || status === '完工';
    this.showResumeScrapSection = status === '暂停中' || status === '生产中暂停';
    this.showIssueToDispatchSection = status === '发放';
    this.showCompletedSection = status === '已报工' || status === '完工' || status === '已报废' || status === '发放暂停';
  }

  private enhanceOrderData(order: WorkOrder): WorkOrder {
    const result: WorkOrder = {
      id: order.id,
      code: order.code,
      type: order.type,
      productId: order.productId,
      productName: order.productName,
      productCode: order.productCode,
      source: order.source,
      planQty: order.planQty,
      status: order.status,
      operatorId: order.operatorId,
      operatorName: order.operatorName,
      lineId: order.lineId,
      lineName: order.lineName,
      processId: order.processId,
      processName: order.processName,
      highlighted: order.highlighted,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
      workshop: order.workshop || '柔性车间',
      resource: order.resource || '柔性线',
      planStartTime: order.planStartTime || '2026-05-01 08:00',
      planEndTime: order.planEndTime || '2026-05-01 18:00',
      dispatchTime: order.dispatchTime || '2026-05-01 07:30',
      actualStartTime: order.actualStartTime || '2026-05-01 08:05',
      actualEndTime: order.actualEndTime,
      reportedHours: order.reportedHours ?? 1.8,
      goodQty: order.goodQty ?? 96,
      ngQty: order.ngQty ?? 4,
      statusFlow: order.statusFlow || '已派工 → 生产中',
      availableOperators: order.availableOperators || ['刘伟', '李强', '赵敏'],
    };
    return result;
  }

  private getMockOrder(orderId: number): WorkOrder {
    return {
      id: orderId,
      code: 'M0000003',
      type: '量产',
      productId: 1,
      productName: '无线充电器组装',
      productCode: 'PROD-WC-001',
      source: '手动创建',
      planQty: 100,
      status: '生产中',
      operatorId: 1,
      operatorName: '刘伟',
      lineId: 1,
      lineName: '柔性组装线',
      processId: 1,
      processName: '组装',
      workshop: '柔性车间',
      resource: '柔性线',
      planStartTime: '2026-05-01 08:00',
      planEndTime: '2026-05-01 18:00',
      dispatchTime: '2026-05-01 07:30',
      actualStartTime: '2026-05-01 08:05',
      reportedHours: 1.8,
      goodQty: 96,
      ngQty: 4,
      statusFlow: '已派工 → 生产中',
      availableOperators: ['刘伟', '李强', '赵敏'],
    };
  }

  getStatusColor(status: string): string {
    if (status === '生产中') return '#0EA5E9';
    if (status === '已报工') return '#10B981';
    if (status === '生产完成' || status === '完工') return '#059669';
    if (status === '待报工') return '#0EA5E9';
    if (status === '已派工') return '#F59E0B';
    if (status === '发放' || status === '发放暂停') return '#D97706';
    if (status === '待派工') return '#64748B';
    if (status === '暂停中' || status === '生产中暂停') return '#EF4444';
    if (status === '已报废') return '#DC2626';
    return '#64748B';
  }

  getStatusBgColor(status: string): string {
    if (status === '生产中') return '#E0F2FE';
    if (status === '已报工') return '#ECFDF5';
    if (status === '生产完成' || status === '完工') return '#ECFDF5';
    if (status === '待报工') return '#E0F2FE';
    if (status === '已派工') return '#FEF3C7';
    if (status === '发放' || status === '发放暂停') return '#FFFBEB';
    if (status === '待派工') return '#F1F5F9';
    if (status === '暂停中' || status === '生产中暂停') return '#FEF2F2';
    if (status === '已报废') return '#FEF2F2';
    return '#F1F5F9';
  }

  getStatusLabel(status: string): string {
    return status;
  }

  getProcessSteps(): string[] {
    return [
      '上料',
      '主板组装',
      '后盖组装',
      '螺丝锁付',
      '激光打标',
      '自动化成品检测',
      '下料',
    ];
  }

  getPauseReason(): string {
    if (this.order && this.order.status === '暂停中') {
      return '设备故障待修';
    }
    return '—';
  }

  getWorkshop(): string {
    return this.order?.workshop || '柔性车间';
  }

  selectOperator(name: string): void {
    this.selectedOperator = name;
  }

  async confirmDispatch(): Promise<boolean> {
    if (!this.order) return false;
    const oldOrder: WorkOrder = this.order;
    const newOrder: WorkOrder = {
      id: oldOrder.id,
      code: oldOrder.code,
      type: oldOrder.type,
      productId: oldOrder.productId,
      productName: oldOrder.productName,
      productCode: oldOrder.productCode,
      source: oldOrder.source,
      planQty: oldOrder.planQty,
      status: '已派工',
      operatorId: oldOrder.operatorId,
      operatorName: this.selectedOperator,
      lineId: oldOrder.lineId,
      lineName: oldOrder.lineName,
      processId: oldOrder.processId,
      processName: oldOrder.processName,
      highlighted: false,
      createdAt: oldOrder.createdAt,
      updatedAt: oldOrder.updatedAt,
      workshop: oldOrder.workshop,
      resource: oldOrder.resource,
      planStartTime: oldOrder.planStartTime,
      planEndTime: oldOrder.planEndTime,
      dispatchTime: oldOrder.dispatchTime,
      actualStartTime: oldOrder.actualStartTime,
      actualEndTime: oldOrder.actualEndTime,
      reportedHours: oldOrder.reportedHours,
      goodQty: oldOrder.goodQty,
      ngQty: oldOrder.ngQty,
      statusFlow: oldOrder.statusFlow,
      availableOperators: oldOrder.availableOperators,
    };
    this.order = newOrder;
    this.updateSectionsByStatus();
    if (this.onStatusChanged) {
      this.onStatusChanged(oldOrder.id, 'dispatch');
    }
    try {
      let operatorId = 3;
      if (this.selectedOperator === '刘伟') operatorId = 3;
      if (this.selectedOperator === '李强') operatorId = 4;
      if (this.selectedOperator === '赵敏') operatorId = 5;
      await this.api.transitionWorkOrder(oldOrder.id, 'dispatch', operatorId);
    } catch (_) {
    }
    return true;
  }

  async confirmComplete(): Promise<boolean> {
    if (!this.order) return false;
    this.applyStatusChange('confirm');
    try {
      const res = await this.api.transitionWorkOrder(this.order.id, 'confirm');
      if (res.code === 0) {
        await this.init(this.order.id);
      }
    } catch (_) {
    }
    return true;
  }

  async scrap(): Promise<boolean> {
    if (!this.order) return false;
    const oldOrder: WorkOrder = this.order;
    const newOrder: WorkOrder = {
      id: oldOrder.id,
      code: oldOrder.code,
      type: oldOrder.type,
      productId: oldOrder.productId,
      productName: oldOrder.productName,
      productCode: oldOrder.productCode,
      source: oldOrder.source,
      planQty: oldOrder.planQty,
      status: '已报废',
      operatorId: oldOrder.operatorId,
      operatorName: oldOrder.operatorName,
      lineId: oldOrder.lineId,
      lineName: oldOrder.lineName,
      processId: oldOrder.processId,
      processName: oldOrder.processName,
      highlighted: false,
      createdAt: oldOrder.createdAt,
      updatedAt: oldOrder.updatedAt,
      workshop: oldOrder.workshop,
      resource: oldOrder.resource,
      planStartTime: oldOrder.planStartTime,
      planEndTime: oldOrder.planEndTime,
      dispatchTime: oldOrder.dispatchTime,
      actualStartTime: oldOrder.actualStartTime,
      actualEndTime: oldOrder.actualEndTime,
      reportedHours: oldOrder.reportedHours,
      goodQty: oldOrder.goodQty,
      ngQty: oldOrder.ngQty,
      statusFlow: oldOrder.statusFlow,
      availableOperators: oldOrder.availableOperators,
    };
    this.order = newOrder;
    this.updateSectionsByStatus();
    if (this.onStatusChanged) {
      this.onStatusChanged(oldOrder.id, 'scrap');
    }
    return true;
  }

  getNextStatus(action: string, currentStatus: string): string {
    if (action === 'resume_issue') return '发放';
    if (action === 'pause_issue') return '发放暂停';
    if (action === 'scrap') return '已报废';
    if (action === 'dispatch') return '已派工';
    if (action === 'cancel_dispatch') return '待派工';
    if (action === 'start') return '生产中';
    if (action === 'complete') return '生产完成';
    if (action === 'pause') return '生产中暂停';
    if (action === 'resume') return '生产中';
    if (action === 'report') return '完工';
    if (action === 'confirm') return '已报工';
    return currentStatus;
  }

  private applyStatusChange(action: string): void {
    if (!this.order) return;
    const orderId: number = this.order.id;
    const newStatus: string = this.getNextStatus(action, this.order.status);
    const oldOrder: WorkOrder = this.order;
    const newOrder: WorkOrder = {
      id: oldOrder.id,
      code: oldOrder.code,
      type: oldOrder.type,
      productId: oldOrder.productId,
      productName: oldOrder.productName,
      productCode: oldOrder.productCode,
      source: oldOrder.source,
      planQty: oldOrder.planQty,
      status: newStatus,
      operatorId: oldOrder.operatorId,
      operatorName: oldOrder.operatorName,
      lineId: oldOrder.lineId,
      lineName: oldOrder.lineName,
      processId: oldOrder.processId,
      processName: oldOrder.processName,
      highlighted: false,
      createdAt: oldOrder.createdAt,
      updatedAt: oldOrder.updatedAt,
      workshop: oldOrder.workshop,
      resource: oldOrder.resource,
      planStartTime: oldOrder.planStartTime,
      planEndTime: oldOrder.planEndTime,
      dispatchTime: oldOrder.dispatchTime,
      actualStartTime: oldOrder.actualStartTime,
      actualEndTime: oldOrder.actualEndTime,
      reportedHours: oldOrder.reportedHours,
      goodQty: oldOrder.goodQty,
      ngQty: oldOrder.ngQty,
      statusFlow: oldOrder.statusFlow,
      availableOperators: oldOrder.availableOperators,
    };
    this.order = newOrder;
    this.updateSectionsByStatus();
    if (this.onStatusChanged) {
      this.onStatusChanged(orderId, action);
    }
  }

  async doTransition(action: string): Promise<boolean> {
    if (!this.order) return false;
    this.applyStatusChange(action);
    try {
      const res = await this.api.transitionWorkOrder(this.order.id, action);
      if (res.code === 0) {
        await this.init(this.order.id);
      }
    } catch (_) {
    }
    return true;
  }

  isPaused(): boolean {
    if (!this.order) return false;
    return this.order.status === '暂停中';
  }

  formatDateTime(dateStr?: string): string {
    if (!dateStr) return '—';
    return dateStr;
  }

  splitDateTime(dateStr?: string): DateTimeParts {
    const result: DateTimeParts = { date: '—', time: '' };
    if (!dateStr) return result;
    const parts = dateStr.split(' ');
    result.date = parts[0] || '—';
    result.time = parts.length > 1 ? (parts[1] || '') : '';
    return result;
  }

  calculateOutputRate(): string {
    if (!this.order) return '0%';
    const planQty = parseInt(this.order.planQty.toString()) || 0;
    const goodQty = parseInt(this.order.goodQty?.toString() ?? '') || 0;
    const ngQty = parseInt(this.order.ngQty?.toString() ?? '') || 0;
    if (planQty === 0) return '0%';
    return ((goodQty + ngQty) / planQty * 100).toFixed(1) + '%';
  }

  calculateGoodRate(): string {
    if (!this.order) return '0%';
    const goodQty = parseInt(this.order.goodQty?.toString() ?? '') || 0;
    const ngQty = parseInt(this.order.ngQty?.toString() ?? '') || 0;
    const total = goodQty + ngQty;
    if (total === 0) return '0%';
    return (goodQty / total * 100).toFixed(1) + '%';
  }

  async submitReport(): Promise<boolean> {
    if (!this.order) return false;
    this.applyStatusChange('report');
    try {
      const goodQty = parseInt(this.reportGoodQty) || 0;
      const ngQty = parseInt(this.reportNgQty) || 0;
      const reportedHours = parseFloat(this.reportHours) || 0;
      
      const res = await this.api.transitionWorkOrder(this.order.id, 'report', undefined, goodQty, ngQty, reportedHours);
      if (res.code === 0) {
        await this.init(this.order.id);
      }
    } catch (_) {
    }
    return true;
  }
}
