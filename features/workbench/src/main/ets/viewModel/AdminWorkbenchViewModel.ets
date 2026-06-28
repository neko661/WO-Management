import { BaseViewModel, HttpApiService, WorkOrder, TodoItem as ApiTodoItem, DashboardStats, WorkOrderQueryParams } from 'utils';
import { SessionManager } from 'datastore';
import { TodoItem as WbTodoItem, QuickEntry, MenuCard } from '../model/WorkbenchTypes';

@ObservedV2
export class AdminWorkbenchViewModel extends BaseViewModel {
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
    ];
  }

  async loadTodos(): Promise<void> {
    try {
      const res = await this.api.getDashboard();
      if (res.code === 0 && res.data) {
        const d = res.data;
        this.todos = [
          { id: 1, type: 'lines', title: '产线总数', description: '当前产线', count: d.totalLines, color: '#007DFF' },
          { id: 2, type: 'employees', title: '人员总数', description: '注册人员', count: d.totalUsers, color: '#4CAF50' },
          { id: 3, type: 'active_orders', title: '活跃工单', description: '进行中的工单', count: d.inProgressCount, color: '#FF9800' },
          { id: 4, type: 'exceptions', title: '待处理异常', description: '未处理的异常', count: d.pausedCount, color: '#F44336' },
        ];
        return;
      }
    } catch (_) { /* fallback */ }
    this.todos = [
      { id: 1, type: 'lines', title: '产线总数', description: '当前产线', count: 4, color: '#007DFF' },
      { id: 2, type: 'employees', title: '人员总数', description: '注册人员', count: 7, color: '#4CAF50' },
      { id: 3, type: 'active_orders', title: '活跃工单', description: '进行中的工单', count: 3, color: '#FF9800' },
      { id: 4, type: 'exceptions', title: '待处理异常', description: '未处理的异常', count: 1, color: '#F44336' },
    ];
  }

  loadMenuCards(): void {
    this.menuCards = [
      { id: 1, title: '全产线工单总览', description: '查看所有产线工单数据，统筹异常处理',
        icon: $r('app.media.ticket'), iconBg: '#E3F2FD', iconColor: '#007DFF' },
      { id: 2, title: '人员管理', description: '增删改查全产线人员信息与角色',
        icon: $r('app.media.personnel'), iconBg: '#E3F2FD', iconColor: '#007DFF' },
      { id: 3, title: '产线与工艺管理', description: '4 条产线总览，柔性组装线可仿真生产',
        icon: $r('app.media.produce'), iconBg: '#E3F2FD', iconColor: '#007DFF' },
    ];
  }

  async loadWorkOrders(): Promise<void> {
    try {
      const params: WorkOrderQueryParams = { pageSize: 50 };
      const res = await this.api.getWorkOrders(params);
      if (res.code === 0 && res.data) {
        this.workOrders = res.data.list.sort((a, b) => b.id - a.id);
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
