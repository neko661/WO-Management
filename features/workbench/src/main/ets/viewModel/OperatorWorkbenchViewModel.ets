import { BaseViewModel, HttpApiService, WorkOrder, TodoItem as ApiTodoItem, DashboardStats, WorkOrderQueryParams } from 'utils';
import { SessionManager } from 'datastore';
import { TodoItem as WbTodoItem, QuickEntry, MenuCard } from '../model/WorkbenchTypes';

@ObservedV2
export class OperatorWorkbenchViewModel extends BaseViewModel {
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
            color: t.priority === 'high' ? '#007DFF' : '#FF9800',
          };
          this.todos.push(item);
        }
        this.loadExceptionTasks();
        return;
      }
    } catch (_) { /* fallback */ }
    this.todos = [
      { id: 1, type: 'to_start', title: '待生产', description: '已派工待开工的工单', count: 0, color: '#007DFF' },
      { id: 2, type: 'producing', title: '生产中', description: '当前进行中的工单', count: 1, color: '#FF9800' },
      { id: 3, type: 'to_report', title: '待报工', description: '生产完成需要报工的工单', count: 0, color: '#4CAF50' },
      { id: 4, type: 'completed_today', title: '今日完成', description: '今日已完成的工单', count: 2, color: '#9C27B0' },
    ];
    this.loadExceptionTasks();
  }

  loadExceptionTasks(): void {
    const raw: string = AppStorage.get('operator_exception_tasks') as string;
    if (raw && raw.length > 0) {
      const parts: string[] = raw.split('|||');
      const count: number = parts.length;
      // 更新异常待处理的数量
      let found: boolean = false;
      for (let i: number = 0; i < this.todos.length; i++) {
        if (this.todos[i].type === 'exception') {
          this.todos[i].count = count;
          found = true;
          break;
        }
      }
      if (!found) {
        const exItem: WbTodoItem = {
          id: 5,
          type: 'exception',
          title: '异常待处理',
          description: '产线异常需要处理',
          count: count,
          color: '#F44336',
        };
        const arr: WbTodoItem[] = [];
        for (let i: number = 0; i < this.todos.length; i++) {
          arr.push(this.todos[i]);
        }
        arr.push(exItem);
        this.todos = arr;
      }
    }
  }

  loadMenuCards(): void {
    this.menuCards = [
      { id: 1, title: '我的工单', description: '查看分配给我的所有工单数据与进度',
        icon: $r('app.media.ticket'), iconBg: '#E3F2FD', iconColor: '#007DFF' },
      { id: 2, title: '开工生产', description: '开始执行已派工的生产任务',
        icon: $r('app.media.produce'), iconBg: '#E8F5E9', iconColor: '#4CAF50' },
      { id: 3, title: '报工上报', description: '完成生产后进行报工确认',
        icon: $r('app.media.billboard'), iconBg: '#FFF3E0', iconColor: '#FF9800' },
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
