import { BaseViewModel, HttpApiService, WorkOrder, WorkOrderQueryParams } from 'utils';

export interface StatusChangeResult {
  from: string;
  to: string;
}

export interface ActionOption {
  action: string;
  label: string;
}

@ObservedV2
export class AdminWorkOrderViewModel extends BaseViewModel {
  @Trace workOrders: WorkOrder[] = [];
  @Trace currentRoleTab: number = 0;
  @Trace searchKeyword: string = '';
  @Trace typeFilter: string = '';
  @Trace statusFilter: string = '';
  @Trace lineFilter: string = '';
  @Trace showFilterPanel: boolean = false;

  private api: HttpApiService = HttpApiService.getInstance();

  async init(): Promise<void> {
    await this.loadWorkOrders();
  }

  async loadWorkOrders(): Promise<void> {
    try {
      const params: WorkOrderQueryParams = { 
        pageSize: 50,
        keyword: this.searchKeyword || undefined,
        status: this.statusFilter || undefined,
        type: this.typeFilter || undefined,
        lineName: this.lineFilter || undefined
      };
      const res = await this.api.getWorkOrders(params);
      if (res.code === 0 && res.data) {
        this.workOrders = res.data.list.sort((a, b) => b.id - a.id);
      }
    } catch (_) {
      this.workOrders = [];
    }
  }

  switchRoleTab(index: number): void {
    this.currentRoleTab = index;
  }

  toggleFilterPanel(): void {
    this.showFilterPanel = !this.showFilterPanel;
  }

  getFilteredOrders(): WorkOrder[] {
    // 根据 currentRoleTab 过滤工单
    // 0: 全部, 1: 班组长, 2: 操作员, 3: 质检员
    let filtered = this.workOrders;
    
    if (this.currentRoleTab === 1) {
      // 班组长：待派工、已派工、发放、发放暂停
      const leaderStatuses = ['待派工', '已派工', '发放', '发放暂停'];
      filtered = filtered.filter(o => leaderStatuses.includes(o.status));
    } else if (this.currentRoleTab === 2) {
      // 操作员：已派工、生产中、暂停中、生产完成、待报工
      const operatorStatuses = ['已派工', '生产中', '暂停中', '生产完成', '待报工'];
      filtered = filtered.filter(o => operatorStatuses.includes(o.status));
    } else if (this.currentRoleTab === 3) {
      // 质检员：已报工、完工
      const inspectorStatuses = ['已报工', '完工'];
      filtered = filtered.filter(o => inspectorStatuses.includes(o.status));
    }
    
    return filtered;
  }

  getTypeFilterLabel(): string {
    if (!this.typeFilter) return '工单类型';
    return '工单类型: ' + this.typeFilter;
  }

  getStatusFilterLabel(): string {
    if (!this.statusFilter) return '状态';
    return '状态: ' + this.statusFilter;
  }

  getLineFilterLabel(): string {
    if (!this.lineFilter) return '当前产线';
    return '当前产线: ' + this.lineFilter;
  }

  hasAnyFilter(): boolean {
    return !!this.typeFilter || !!this.statusFilter || !!this.lineFilter;
  }

  async transitionWorkOrder(id: number, action: string): Promise<void> {
    try {
      const res = await this.api.transitionWorkOrder(id, action);
      if (res.code === 0) {
        await this.loadWorkOrders();
      } else {
        throw new Error(res.msg || '状态变更失败');
      }
    } catch (e) {
      throw new Error(e instanceof Error ? e.message : String(e));
    }
  }

  getStatusColor(status: string): string {
    if (status === '生产中') return '#0EA5E9';
    if (status === '已报工') return '#10B981';
    if (status === '生产完成' || status === '完工') return '#059669';
    if (status === '已派工') return '#F59E0B';
    if (status === '发放') return '#D97706';
    if (status === '发放暂停') return '#D97706';
    if (status === '待派工') return '#64748B';
    if (status === '暂停中' || status === '生产中暂停') return '#EF4444';
    if (status === '已报废') return '#DC2626';
    return '#64748B';
  }

  getAvailableActions(status: string): ActionOption[] {
    const result: ActionOption[] = [];
    if (status === '发放暂停') {
      result.push({ action: 'resume_issue', label: '恢复' });
      result.push({ action: 'scrap', label: '报废' });
      return result;
    }
    if (status === '发放') {
      result.push({ action: 'pause_issue', label: '暂停发放' });
      result.push({ action: 'scrap', label: '报废' });
      return result;
    }
    if (status === '待派工') {
      result.push({ action: 'dispatch', label: '派工' });
      result.push({ action: 'scrap', label: '报废' });
      return result;
    }
    if (status === '已派工') {
      result.push({ action: 'start', label: '启动生产' });
      result.push({ action: 'cancel_dispatch', label: '取消派工' });
      return result;
    }
    if (status === '生产中') {
      result.push({ action: 'complete', label: '生产完成' });
      result.push({ action: 'pause', label: '暂停' });
      return result;
    }
    if (status === '生产中暂停' || status === '暂停中') {
      result.push({ action: 'resume', label: '恢复生产' });
      result.push({ action: 'scrap', label: '报废' });
      return result;
    }
    if (status === '生产完成') {
      result.push({ action: 'report', label: '报工' });
      return result;
    }
    return result;
  }

  isDangerAction(action: string): boolean {
    return action === 'pause_issue' || action === 'pause' || action === 'scrap' || action === 'cancel_dispatch';
  }

  isHighlightedStatus(status: string): boolean {
    return status === '发放暂停' || status === '生产中暂停' || status === '暂停中';
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
    if (action === 'report') return '已报工';
    return currentStatus;
  }

  changeStatusLocal(orderId: number, action: string): StatusChangeResult | null {
    const newList: WorkOrder[] = [];
    let fromStatus: string = '';
    let toStatus: string = '';
    for (let i: number = 0; i < this.workOrders.length; i++) {
      const order: WorkOrder = this.workOrders[i];
      if (order.id === orderId) {
        fromStatus = order.status;
        toStatus = this.getNextStatus(action, fromStatus);
        const newOrder: WorkOrder = {
          id: order.id,
          code: order.code,
          type: order.type,
          productId: order.productId,
          productName: order.productName,
          productCode: order.productCode,
          source: order.source,
          planQty: order.planQty,
          status: toStatus,
          operatorId: order.operatorId,
          operatorName: order.operatorName,
          lineId: order.lineId,
          lineName: order.lineName,
          processId: order.processId,
          processName: order.processName,
          highlighted: this.isHighlightedStatus(toStatus),
          createdAt: order.createdAt,
          updatedAt: order.updatedAt,
          workshop: order.workshop,
          resource: order.resource,
          planStartTime: order.planStartTime,
          planEndTime: order.planEndTime,
          dispatchTime: order.dispatchTime,
          actualStartTime: order.actualStartTime,
          actualEndTime: order.actualEndTime,
          reportedHours: order.reportedHours,
          goodQty: order.goodQty,
          ngQty: order.ngQty,
          statusFlow: order.statusFlow,
          availableOperators: order.availableOperators,
        };
        newList.push(newOrder);
      } else {
        newList.push(order);
      }
    }
    if (fromStatus.length > 0) {
      this.workOrders = newList;
      const result: StatusChangeResult = { from: fromStatus, to: toStatus };
      return result;
    }
    return null;
  }
}
