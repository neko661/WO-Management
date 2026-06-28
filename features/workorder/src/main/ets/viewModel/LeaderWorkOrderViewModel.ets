import { BaseViewModel, HttpApiService, WorkOrder, WorkOrderQueryParams } from 'utils';

@ObservedV2
export class LeaderWorkOrderViewModel extends BaseViewModel {
  @Trace workOrders: WorkOrder[] = [];
  @Trace searchKeyword: string = '';
  @Trace filterStatus: string = '';
  private api: HttpApiService = HttpApiService.getInstance();

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
  }

  getFilteredOrders(): WorkOrder[] {
    const result: WorkOrder[] = [];
    for (let i: number = 0; i < this.workOrders.length; i++) {
      const order: WorkOrder = this.workOrders[i];
      if (this.searchKeyword.length > 0 && !order.code.includes(this.searchKeyword)) continue;
      if (this.filterStatus.length > 0 && order.status !== this.filterStatus) continue;
      result.push(order);
    }
    return result;
  }
}
