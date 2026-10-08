import { BaseViewModel, HttpApiService, WorkOrder, WorkOrderQueryParams } from 'utils';
import { SessionManager } from 'datastore';

@ObservedV2
export class OperatorWorkOrderViewModel extends BaseViewModel {
  @Trace workOrders: WorkOrder[] = [];
  @Trace filteredOrders: WorkOrder[] = [];
  @Trace searchKeyword: string = '';
  @Trace filterStatus: string = '';
  @Trace currentUserName: string = '';
  private api: HttpApiService = HttpApiService.getInstance();
  private session: SessionManager = SessionManager.getInstance();
  onNavigateToDetail: ((orderId: number) => void) | null = null;

  async init(): Promise<void> {
    this.currentUserName = await this.session.getUserName();
    await this.loadWorkOrders();
  }

  async loadWorkOrders(): Promise<void> {
    try {
      const params: WorkOrderQueryParams = { pageSize: 50 };
      const res = await this.api.getWorkOrders(params);
      if (res.code === 0 && res.data) {
        this.workOrders = res.data.list;
      }
    } catch (_) {
      this.workOrders = [];
    }
    this.updateFilteredOrders();
  }

  updateFilteredOrders(): void {
    const result: WorkOrder[] = [];
    for (let i: number = 0; i < this.workOrders.length; i++) {
      const order: WorkOrder = this.workOrders[i];
      if (this.searchKeyword.length > 0 && !order.code.includes(this.searchKeyword)) continue;
      if (this.filterStatus.length > 0 && order.status !== this.filterStatus) continue;
      if (this.isOperatorRelevantOrder(order)) {
        result.push(order);
      }
    }
    this.filteredOrders = result;
  }

  private isOperatorRelevantOrder(order: WorkOrder): boolean {
    const operatorName: string = order.operatorName || '';
    if (operatorName.length === 0) {
      return false;
    }
    const visibleStatuses: string[] = ['已派工', '生产中', '暂停中', '生产中暂停', '生产完成', '待报工', '已报工', '完工'];
    for (let i: number = 0; i < visibleStatuses.length; i++) {
      if (visibleStatuses[i] === order.status) {
        return true;
      }
    }
    return operatorName === this.currentUserName;
  }

  canOperateOrder(order: WorkOrder): boolean {
    return (order.operatorName || '') === this.currentUserName;
  }

  getOperatorLabel(order: WorkOrder): string {
    return order.operatorName && order.operatorName.length > 0 ? order.operatorName : '未指派';
  }

  getReadonlyHint(order: WorkOrder): string {
    return '当前派工：' + this.getOperatorLabel(order) + '，你可查看但不能操作';
  }

  getNextStatus(action: string, currentStatus: string): string {
    if (action === 'start') return '生产中';
    if (action === 'report') return '已报工';
    return currentStatus;
  }

  private applyStatusChange(orderId: number, action: string): void {
    const newOrders: WorkOrder[] = [];
    for (let i: number = 0; i < this.workOrders.length; i++) {
      const order: WorkOrder = this.workOrders[i];
      if (order.id === orderId) {
        const updatedOrder: WorkOrder = {
          id: order.id,
          code: order.code,
          type: order.type,
          productId: order.productId,
          productName: order.productName,
          productCode: order.productCode,
          source: order.source,
          planQty: order.planQty,
          status: this.getNextStatus(action, order.status),
          operatorId: order.operatorId,
          operatorName: order.operatorName,
          lineId: order.lineId,
          lineName: order.lineName,
          processId: order.processId,
          processName: order.processName,
          highlighted: order.highlighted,
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
        newOrders.push(updatedOrder);
      } else {
        newOrders.push(order);
      }
    }
    this.workOrders = newOrders;
    this.updateFilteredOrders();
  }

  async startProduction(orderId: number): Promise<void> {
    const order: WorkOrder | null = this.findOrder(orderId);
    if (!order || !this.canOperateOrder(order)) {
      return;
    }
    this.applyStatusChange(orderId, 'start');
    try {
      const res = await this.api.transitionWorkOrder(orderId, 'start');
      if (res.code === 0) {
        await this.loadWorkOrders();
      }
    } catch (_) {
    }
  }

  async reportWork(orderId: number): Promise<void> {
    const order: WorkOrder | null = this.findOrder(orderId);
    if (!order || !this.canOperateOrder(order)) {
      return;
    }
    this.applyStatusChange(orderId, 'report');
    try {
      const res = await this.api.transitionWorkOrder(orderId, 'report');
      if (res.code === 0) {
        await this.loadWorkOrders();
      }
    } catch (_) {
    }
  }

  viewDetail(orderId: number): void {
    if (this.onNavigateToDetail) {
      this.onNavigateToDetail(orderId);
    }
  }

  private findOrder(orderId: number): WorkOrder | null {
    for (let i: number = 0; i < this.workOrders.length; i++) {
      if (this.workOrders[i].id === orderId) {
        return this.workOrders[i];
      }
    }
    return null;
  }
}
