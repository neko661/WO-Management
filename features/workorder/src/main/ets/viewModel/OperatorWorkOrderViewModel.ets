import { BaseViewModel, HttpApiService, WorkOrder, WorkOrderQueryParams } from 'utils';

@ObservedV2
export class OperatorWorkOrderViewModel extends BaseViewModel {
  @Trace workOrders: WorkOrder[] = [];
  @Trace filteredOrders: WorkOrder[] = [];
  @Trace searchKeyword: string = '';
  @Trace filterStatus: string = '';
  private api: HttpApiService = HttpApiService.getInstance();
  onNavigateToDetail: ((orderId: number) => void) | null = null;

  async init(): Promise<void> {
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
      result.push(order);
    }
    this.filteredOrders = result;
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
}
