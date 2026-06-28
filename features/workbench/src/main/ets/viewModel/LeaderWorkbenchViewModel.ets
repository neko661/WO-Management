import { BaseViewModel, HttpApiService, WorkOrder, TodoItem as ApiTodoItem, DashboardStats, WorkOrderQueryParams } from 'utils';
import { SessionManager } from 'datastore';
import { TodoItem as WbTodoItem, QuickEntry, MenuCard } from '../model/WorkbenchTypes';

@ObservedV2
export class LeaderWorkbenchViewModel extends BaseViewModel {
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
      const res = await this.api.getTodos();
      if (res.code === 0 && res.data) {
        this.todos = [];
        for (let i: number = 0; i < res.data.todos.length; i++) {
          const t: ApiTodoItem = res.data.todos[i];
          const idParts: string[] = t.id.split('_');
          const numId: number = parseInt(idParts.length > 0 ? idParts[idParts.length - 1] : '0');
          const item: WbTodoItem = {
            id: numId,
            type: t.type,
            title: t.title,
            description: t.description,
            count: 1,
            color: t.priority === 'high' ? '#FF9800' : '#4CAF50',
          };
          this.todos.push(item);
        }
        return;
      }
    } catch (_) { /* fallback */ }
    this.todos = [
      { id: 1, type: 'pending_dispatch', title: '待派工工单', description: '有待派工的工单需要指派操作员', count: 1, color: '#FF9800' },
      { id: 2, type: 'exception', title: '异常待处理', description: '产线异常需要处理', count: 0, color: '#F44336' },
      { id: 3, type: 'confirm', title: '待确认工时', description: '已报工工单等待确认', count: 1, color: '#4CAF50' },
      { id: 4, type: 'team_members', title: '班组成员', description: '当前班组在岗人员', count: 5, color: '#007DFF' },
    ];
  }

  loadMenuCards(): void {
    this.menuCards = [
      { id: 1, title: '班组工单总览', description: '查看本班组所有工单数据，统筹派工与异常处理',
        icon: $r('app.media.ticket'), iconBg: '#E3F2FD', iconColor: '#007DFF' },
      { id: 2, title: '班组成员管理', description: '查看本班组人员信息与状态',
        icon: $r('app.media.personnel'), iconBg: '#E8F5E9', iconColor: '#4CAF50' },
      { id: 3, title: '产线监控', description: '实时查看产线运行状态与生产进度',
        icon: $r('app.media.produce'), iconBg: '#FFF3E0', iconColor: '#FF9800' },
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

  // 获取待办工单：待派工、已派工、待确认工时 等状态
  getPendingOrders(): WorkOrder[] {
    const pendingStatuses: string[] = ['待派工', '已派工', '生产完成', '已报工'];
    return this.workOrders.filter((o: WorkOrder) => pendingStatuses.indexOf(o.status) >= 0);
  }

  // 获取异常工单：暂停中、高亮标记 等
  getExceptionOrders(): WorkOrder[] {
    return this.workOrders.filter((o: WorkOrder) => o.status === '暂停中' || o.highlighted === true);
  }
}
