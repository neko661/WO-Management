import { BaseViewModel, HttpApiService, WorkOrder, TodoItem as ApiTodoItem, DashboardStats, WorkOrderQueryParams } from 'utils';
import { SessionManager } from 'datastore';
import { TodoItem as WbTodoItem, QuickEntry, MenuCard } from '../model/WorkbenchTypes';

@ObservedV2
export class InspectorWorkbenchViewModel extends BaseViewModel {
  @Trace userName: string = '';
  @Trace appTitle: string = '柔性组装 MES 教学仿真';
  @Trace todos: WbTodoItem[] = [];
  @Trace quickEntries: QuickEntry[] = [];
  @Trace menuCards: MenuCard[] = [];
  @Trace workOrders: WorkOrder[] = [];
  @Trace dashboard: DashboardStats | null = null;

  private api: HttpApiService = HttpApiService.getInstance();
  private session: SessionManager = SessionManager.getInstance();

  async init(): Promise<void> {
    this.userName = await this.session.getUserName();
    this.loadQuickEntries();
    this.loadMenuCards();
    await this.loadTodos();
    await this.loadWorkOrders();
    await this.loadDashboard();
  }

  loadQuickEntries(): void {
    this.quickEntries = [
      { id: 1, label: '基础数据', bgColor: '#E8F5E9', iconColor: '#4CAF50', icon: $r('app.media.data') },
      { id: 2, label: '工单', bgColor: '#E3F2FD', iconColor: '#007DFF', icon: $r('app.media.ticket') },
      { id: 3, label: '质检看板', bgColor: '#FCE4EC', iconColor: '#E91E63', icon: $r('app.media.billboard') },
      { id: 4, label: '抽检记录', bgColor: '#FFF3E0', iconColor: '#FF9800', icon: $r('app.media.billboard') },
    ];
  }

  async loadTodos(): Promise<void> {
    try {
      // 动态计算待抽检数量
      const toInspectCount = this.workOrders.filter(o => o.status === '完工' || o.status === '已报工' || o.status === '生产完成').length;
      
      this.todos = [
        { id: 1, type: 'to_inspect', title: '待抽检', description: '已报工等待抽检的工单', count: toInspectCount, color: '#007DFF' },
        { id: 2, type: 'line_status', title: '产线运行状态', description: '当前产线实时监控', count: 0, color: '#FF9800' },
        { id: 3, type: 'today_inspected', title: '今日已检', description: '今日已完成的质检工单', count: 3, color: '#4CAF50' },
        { id: 4, type: 'ng_rate', title: '不良率', description: '本月产品不良率统计', count: 2, color: '#F44336' },
      ];
    } catch (_) { /* fallback */ }
  }

  loadMenuCards(): void {
    this.menuCards = [
      { id: 1, title: '质检工单总览', description: '查看所有待检与已检工单数据',
        icon: $r('app.media.ticket'), iconBg: '#E3F2FD', iconColor: '#007DFF' },
      { id: 2, title: '质检记录', description: '查看历史质检记录与结果',
        icon: $r('app.media.billboard'), iconBg: '#FCE4EC', iconColor: '#E91E63' },
      { id: 3, title: '产线监控', description: '实时监控产线运行状态',
        icon: $r('app.media.produce'), iconBg: '#FFF3E0', iconColor: '#FF9800' },
    ];
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
        // 重新加载 todos 以更新数量
        this.loadTodos();
      }
    } catch (_) {
      this.workOrders = [];
    }
  }

  async loadDashboard(): Promise<void> {
    try {
      const res = await this.api.getDashboard();
      if (res.code === 0 && res.data) {
        this.dashboard = res.data;
      }
    } catch (_) {
      // ignore
    }
  }
}
