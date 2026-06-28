import { BaseViewModel, HttpApiService, WorkOrder } from 'utils';

export interface ProcessTask {
  id: number;
  workOrderId: number;
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

  private api: HttpApiService = HttpApiService.getInstance();

  async init(): Promise<void> {
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
            // 已派工的作为待执行任务
            if (!this.currentTask && !this.inProgressTask) {
              this.currentTask = task;
            } else {
              this.queueTasks.push(task);
            }
          } else {
            this.queueTasks.push(task);
          }
        }
        
        // 对 reportedTasks 进行排序，最新的排在前面
        this.reportedTasks.sort((a, b) => b.id - a.id);

        // 如果有进行中的任务，自动切换到进行中 tab
        if (this.inProgressTask) {
          this.currentTab = 1;
        } else if (this.currentTask) {
          this.currentTab = 0;
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

  switchTab(tabIndex: number): void {
    this.currentTab = tabIndex;
  }

  async startTask(taskId: number): Promise<void> {
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
}