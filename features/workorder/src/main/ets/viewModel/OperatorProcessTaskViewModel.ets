import { BaseViewModel, HttpApiService, WorkOrder } from 'utils';
import { SessionManager } from 'datastore';

export interface ProcessTask {
  id: number;
  workOrderId: number;
  lineId: number;
  lineName: string;
  workOrderCode: string;
  processCode: string;
  processName: string;
  productName: string;
  status: string;
  planQty: number;
  completedQty: number;
  remainQty: number;
  estimatedTime: string;
  priority: string;
  remark: string;
  isUrgent: boolean;
}

@ObservedV2
export class OperatorProcessTaskViewModel extends BaseViewModel {
  @Trace currentTab: number = 0;
  @Trace currentTask: ProcessTask | null = null;
  @Trace queueTasks: ProcessTask[] = [];
  @Trace reportedTasks: ProcessTask[] = [];
  @Trace inProgressTask: ProcessTask | null = null;
  @Trace progressPercent: number = 0;
  @Trace elapsedMinutes: number = 0;
  @Trace selectedTaskId: number = 0;
  @Trace currentUserName: string = '';

  private api: HttpApiService = HttpApiService.getInstance();
  private session: SessionManager = SessionManager.getInstance();

  async init(): Promise<void> {
    this.currentUserName = await this.session.getUserName();
    await this.loadTasks();
  }

  async loadTasks(): Promise<void> {
    try {
      const res = await this.api.getWorkOrders({ pageSize: 100 });
      if (res.code === 0 && res.data) {
        const orders = res.data.list;
        
        this.currentTask = null;
        this.inProgressTask = null;
        this.queueTasks = [];
        this.reportedTasks = [];

        for (let i = 0; i < orders.length; i++) {
          const order = orders[i];
          if (!this.isVisibleOrder(order)) {
            continue;
          }
          const task = this.mapWorkOrderToTask(order);

          if (order.status === '待报工' || order.status === '生产完成') {
            // 待报工的作为当前任务（如果还没有当前任务）
            if (!this.currentTask) {
              this.currentTask = task;
            } else {
              this.queueTasks.push(task);
            }
          } else if (order.status === '生产中') {
            this.inProgressTask = task;
            // 简单模拟进度
            this.progressPercent = Math.floor((task.completedQty / task.planQty) * 100) || 0;
            this.elapsedMinutes = 45; // 模拟已执行时间
          } else if (order.status === '已报工' || order.status === '完工') {
            this.reportedTasks.push(task);
          } else if (order.status === '已派工') {
            this.queueTasks.push(task);
          } else {
            this.queueTasks.push(task);
          }
        }
        
        // 对 reportedTasks 进行排序，最新的排在前面
        this.reportedTasks.sort((a, b) => b.id - a.id);

        // 如果有进行中的任务，自动切换到进行中 tab
        if (this.inProgressTask) {
          this.currentTab = 1;
          this.selectedTaskId = this.inProgressTask.id;
        } else if (this.currentTask) {
          this.currentTab = 0;
          if (this.selectedTaskId === 0) {
            this.selectedTaskId = this.currentTask.id;
          }
        } else if (this.reportedTasks.length > 0) {
          this.currentTab = 2;
        }
      }
    } catch (e) {
      console.error('Failed to load tasks', e);
    }
  }

  private mapWorkOrderToTask(order: WorkOrder): ProcessTask {
    const completedQty = (order.goodQty || 0) + (order.ngQty || 0);
    return {
      id: order.id,
      workOrderId: order.id,
      lineId: order.lineId || 1,
      lineName: order.lineName || '柔性组装线',
      workOrderCode: order.code,
      processCode: 'OP10', // 模拟工序代码
      processName: order.processName || '标准组装',
      productName: order.productName,
      status: order.status,
      planQty: order.planQty,
      completedQty: completedQty,
      remainQty: order.planQty - completedQty,
      estimatedTime: '',
      priority: 'normal',
      remark: order.status,
      isUrgent: false
    };
  }

  private isVisibleOrder(order: WorkOrder): boolean {
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

  selectTask(taskId: number): void {
    this.selectedTaskId = taskId;
    const task: ProcessTask | null = this.findTask(taskId);
    if (task) {
      AppStorage.setOrCreate('selected_process_task', JSON.stringify(task));
    }
  }

  isTaskSelected(taskId: number): boolean {
    return this.selectedTaskId === taskId;
  }

  canEnterLine(): boolean {
    return this.selectedTaskId > 0;
  }

  getSelectedLineId(): number {
    const task: ProcessTask | null = this.findTask(this.selectedTaskId);
    return task ? task.lineId : 0;
  }

  getSelectedTaskSummary(): string {
    const task: ProcessTask | null = this.findTask(this.selectedTaskId);
    if (!task) {
      return '请先选择一个待执行任务';
    }
    return task.workOrderCode + ' · ' + task.processName + ' · ' + task.lineName;
  }

  switchTab(tabIndex: number): void {
    this.currentTab = tabIndex;
  }

  async startTask(taskId: number): Promise<void> {
    this.selectTask(taskId);
    try {
      const res = await this.api.transitionWorkOrder(taskId, 'start');
      if (res.code === 0) {
        await this.loadTasks();
      } else {
        // 可以添加错误提示
        console.error(res.msg);
      }
    } catch (e) {
      console.error(e);
    }
  }

  async reportTask(taskId: number): Promise<void> {
    try {
      // 假设报工前需要先将状态流转为“待报工”或“生产完成”
      // 这里我们直接调用后端接口将其流转为“生产完成”或“待报工”
      // 根据 workorder.js，生产中 -> 生产完成 (complete) -> 待报工 (confirm)
      // 为了简化，如果当前是生产中，我们先 complete
      const task = this.inProgressTask?.id === taskId ? this.inProgressTask : this.currentTask;
      if (task && task.status === '生产中') {
        await this.api.transitionWorkOrder(taskId, 'complete');
      } else if (task && task.status === '已派工') {
        // 如果是已派工直接点报工，可能需要先 start 再 complete
        await this.api.transitionWorkOrder(taskId, 'start');
        await this.api.transitionWorkOrder(taskId, 'complete');
      }
      await this.loadTasks();
    } catch (e) {
      console.error(e);
    }
  }

  getTabLabel(tabIndex: number): string {
    if (tabIndex === 0) return '待执行';
    if (tabIndex === 1) return '进行中';
    if (tabIndex === 2) return '已报工';
    return '';
  }

  private findTask(taskId: number): ProcessTask | null {
    if (this.currentTask && this.currentTask.id === taskId) {
      return this.currentTask;
    }
    if (this.inProgressTask && this.inProgressTask.id === taskId) {
      return this.inProgressTask;
    }
    for (let i: number = 0; i < this.queueTasks.length; i++) {
      if (this.queueTasks[i].id === taskId) {
        return this.queueTasks[i];
      }
    }
    for (let i: number = 0; i < this.reportedTasks.length; i++) {
      if (this.reportedTasks[i].id === taskId) {
        return this.reportedTasks[i];
      }
    }
    return null;
  }
}
