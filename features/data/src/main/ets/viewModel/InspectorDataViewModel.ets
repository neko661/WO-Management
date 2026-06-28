import { BaseViewModel, HttpApiService, DashboardData, ProductionLine } from 'utils';

@ObservedV2
export class InspectorDataViewModel extends BaseViewModel {
  @Trace dashboard: DashboardData = {
    todayPlanRate: 0, totalInput: 0, totalOutput: 0, totalNg: 0,
    productFinishRate: 0, operationFinishRate: 0
  };
  @Trace productionLines: ProductionLine[] = [];
  private api: HttpApiService = HttpApiService.getInstance();

  async init(): Promise<void> {
    await this.loadDashboard();
    await this.loadProductionLines();
  }

  async loadDashboard(): Promise<void> {
    try {
      const res = await this.api.getDashboard();
      if (res.code === 0 && res.data) {
        const d = res.data;
        const dashboardData: DashboardData = {
          todayPlanRate: d.todayPlanRate,
          totalInput: d.totalInput,
          totalOutput: d.totalOutput,
          totalNg: d.totalNg,
          productFinishRate: d.productFinishRate,
          operationFinishRate: d.operationFinishRate,
        };
        this.dashboard = dashboardData;
      }
    } catch (_) { /* keep defaults */ }
  }

  async loadProductionLines(): Promise<void> {
    try {
      const res = await this.api.getLines();
      if (res.code === 0 && res.data) {
        this.productionLines = res.data;
      }
    } catch (_) {
      this.productionLines = [];
    }
  }
}
