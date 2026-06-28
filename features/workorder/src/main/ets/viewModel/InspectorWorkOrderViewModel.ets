import { BaseViewModel, HttpApiService, WorkOrder, WorkOrderQueryParams } from 'utils';

@ObservedV2
export class InspectorWorkOrderViewModel extends BaseViewModel {
  @Trace workOrders: WorkOrder[] = [];
  @Trace filteredOrders: WorkOrder[] = [];
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
        // 将完工、已报工、生产完成的工单排在最前面，并且按 ID 倒序（最新的排前面）
        this.workOrders = res.data.list.sort((a, b) => {
          const aIsToInspect = a.status === '完工' || a.status === '已报工' || a.status === '生产完成';
          const bIsToInspect = b.status === '完工' || b.status === '已报工' || b.status === '生产完成';
          if (aIsToInspect && !bIsToInspect) return -1;
          if (!aIsToInspect && bIsToInspect) return 1;
          // 如果状态相同，按 ID 倒序排列（最新的在前面）
          return b.id - a.id;
        });
        this.refreshFiltered();
      }
    } catch (_) {
      this.workOrders = [];
      this.filteredOrders = [];
    }
  }

  // 刷新过滤列表
  refreshFiltered(): void {
    // 读取 AppStorage 触发响应式更新
    const trigger: number = AppStorage.get('inspect_trigger') as number;
    const result: WorkOrder[] = [];
    for (let i: number = 0; i < this.workOrders.length; i++) {
      const order: WorkOrder = this.workOrders[i];
      const inspected: string = AppStorage.get('inspected_' + order.code) as string;
      if (inspected === 'true') continue;
      if (this.searchKeyword.length > 0 && !order.code.includes(this.searchKeyword)) continue;
      if (this.filterStatus.length > 0 && order.status !== this.filterStatus) continue;
      result.push(order);
    }
    this.filteredOrders = result;
  }

  getFilteredOrders(): WorkOrder[] {
    // 每次调用都重新计算，确保刚抽检完的工单被排除
    const result: WorkOrder[] = [];
    for (let i: number = 0; i < this.workOrders.length; i++) {
      const order: WorkOrder = this.workOrders[i];
      const inspected: string = AppStorage.get('inspected_' + order.code) as string;
      if (inspected === 'true') continue;
      if (this.searchKeyword.length > 0 && !order.code.includes(this.searchKeyword)) continue;
      if (this.filterStatus.length > 0 && order.status !== this.filterStatus) continue;
      result.push(order);
    }
    return result;
  }
}
