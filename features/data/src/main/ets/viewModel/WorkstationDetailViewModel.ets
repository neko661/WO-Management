import { BaseViewModel } from 'utils';
import { WorkstationFullDetail, StationStateData } from '../model/DataTypes';

@ObservedV2
export class WorkstationDetailViewModel extends BaseViewModel {
  @Trace detail: WorkstationFullDetail | null = null;
  @Trace toastMsg: string = '';
  @Trace showToast: boolean = false;

  // 当前运行状态: 'running' | 'stopped' | 'reset' | 'fault'
  @Trace runState: string = 'running';

  // 确认弹窗
  @Trace showConfirmDialog: boolean = false;
  @Trace confirmAction: string = '';
  @Trace confirmActionLabel: string = '';

  // 异常上报弹窗
  @Trace showExceptionDialog: boolean = false;
  @Trace exceptionText: string = '';
  @Trace exceptionDetail: string = '';

  // 工作动作映射
  private workActions: Record<string, string> = {
    '上料': '机械臂上料', '检测': '视觉检测', '装配': '自动装配',
    '焊接': '激光焊接', '测试': '功能测试', '包装': '自动包装', '下料': '机械臂下料'
  };
  private workActionDescs: Record<string, string> = {
    '上料': '原材料拾取放置', '检测': '产品外观与尺寸检测', '装配': '组件自动化装配',
    '焊接': '精密焊点焊接', '测试': '电气性能与功能测试', '包装': '成品包装与标签', '下料': '成品分拣与码垛'
  };

  private getStateData(state: string, stationName?: string): StationStateData {
    if (state === 'running') {
      const name: string = stationName || '';
      return {
        deviceStatus: '运行', deviceStatusDesc: '设备正常运转',
        workStatus: '加工中',
        workAction: this.workActions[name] || '',
        workActionDesc: this.workActionDescs[name] || '当前工序执行中',
        conveyorStatus: '运行', conveyorDirection: '正转', conveyorDesc: '物料传送方向',
        workorderStatus: '生产中'
      };
    } else if (state === 'stopped') {
      return {
        deviceStatus: '待机', deviceStatusDesc: '已选择工艺，等待启动',
        workStatus: '空闲', workAction: '', workActionDesc: '等待操作员启动',
        conveyorStatus: '停止', conveyorDirection: '—', conveyorDesc: '物料传送方向',
        workorderStatus: '暂停中'
      };
    } else if (state === 'reset') {
      return {
        deviceStatus: '待机', deviceStatusDesc: '设备未启动',
        workStatus: '空闲', workAction: '', workActionDesc: '等待产线启动',
        conveyorStatus: '停止', conveyorDirection: '—', conveyorDesc: '物料传送方向',
        workorderStatus: '—'
      };
    } else {
      return {
        deviceStatus: '故障', deviceStatusDesc: '设备发生故障，等待维修',
        workStatus: '停机', workAction: '', workActionDesc: '等待维修处理',
        conveyorStatus: '停止', conveyorDirection: '—', conveyorDesc: '传送带已停止',
        workorderStatus: '暂停中'
      };
    }
  }

  // 各状态按钮启用情况
  get isStartEnabled(): boolean {
    return this.runState === 'stopped' || this.runState === 'reset';
  }
  get isStopEnabled(): boolean {
    return this.runState === 'running';
  }
  get isResetEnabled(): boolean {
    return this.runState === 'running' || this.runState === 'stopped';
  }
  get isExceptionEnabled(): boolean {
    return true; // 任何状态都可以异常上报
  }

  init(stationId: number): void {
    this.loadDetail(stationId);
  }

  loadDetail(stationId: number): void {
    const lineId: number = Math.floor(stationId / 100);
    const stationIndex: number = (stationId % 100) - 1;
    const stationCodes: string[] = ['OP10', 'OP20', 'OP30', 'OP40', 'OP50', 'OP60', 'OP70'];
    const stationNames: string[] = ['上料', '检测', '装配', '焊接', '测试', '包装', '下料'];
    const lineNames: string[] = ['柔性组装线', '智能组装线', 'SMT产线', '机加工线'];
    const processes: string[] = ['无线充电器组装', '智能手机组装', 'PCB焊接', '金属件加工'];
    const devices: string[] = ['EQ-LOAD-01', 'EQ-INS-02', 'EQ-ASM-03', 'EQ-WLD-04', 'EQ-TST-05', 'EQ-PKG-06', 'EQ-ULD-07'];
    const times: string[] = ['2.5s', '3.0s', '4.2s', '5.1s', '3.8s', '2.0s', '1.5s'];

    const idx: number = stationIndex >= 0 && stationIndex < 7 ? stationIndex : 0;
    const name: string = lineNames[lineId - 1] || '柔性组装线';
    const sName: string = stationNames[idx];

    // 读取产线详情页保存的状态
    const savedState: string = AppStorage.get('station_state_' + stationId.toString()) as string;
    const initState: string = (savedState && savedState.length > 0) ? savedState : 'running';
    this.runState = initState;
    const s: StationStateData = this.getStateData(initState, sName);

    this.detail = {
      id: stationId,
      code: stationCodes[idx],
      name: sName,
      lineId: lineId,
      lineName: name,
      deviceCode: devices[idx],
      deviceStatus: s.deviceStatus,
      deviceStatusDesc: s.deviceStatusDesc,
      workStatus: s.workStatus,
      workAction: s.workAction,
      workActionDesc: s.workActionDesc,
      conveyorStatus: s.conveyorStatus,
      conveyorDirection: s.conveyorDirection,
      conveyorDesc: s.conveyorDesc,
      currentProcess: processes[lineId - 1] || '无线充电器组装',
      workorderCode: 'MO000002',
      productName: '无线充电器组装',
      operatorName: '刘伟',
      workorderStatus: s.workorderStatus,
      processedCount: (initState === 'stopped' || initState === 'reset' || initState === 'fault') ? 0 : (150 - idx * 10),
      rawMaterial: (initState === 'stopped' || initState === 'reset' || initState === 'fault') ? 0 : 81,
      goodCount: (initState === 'stopped' || initState === 'reset' || initState === 'fault') ? 0 : (148 - idx * 10),
      ngCount: (initState === 'stopped' || initState === 'reset' || initState === 'fault') ? 0 : 2,
      processingTime: times[idx],
    };
  }

  // 应用状态
  applyState(state: string): void {
    if (!this.detail) return;
    const s: StationStateData = this.getStateData(state, this.detail.name);

    this.runState = state;
    AppStorage.setOrCreate('station_state_' + this.detail.id.toString(), state);
    this.detail.deviceStatus = s.deviceStatus;
    this.detail.deviceStatusDesc = s.deviceStatusDesc;
    this.detail.workStatus = s.workStatus;
    this.detail.workAction = s.workAction;
    this.detail.workActionDesc = s.workActionDesc;
    this.detail.conveyorStatus = s.conveyorStatus;
    this.detail.conveyorDirection = s.conveyorDirection;
    this.detail.conveyorDesc = s.conveyorDesc;
    this.detail.workorderStatus = s.workorderStatus;

    if (state === 'stopped' || state === 'reset' || state === 'fault') {
      this.detail.processedCount = 0;
      this.detail.rawMaterial = 0;
      this.detail.goodCount = 0;
      this.detail.ngCount = 0;
    }

    if (state === 'running' && this.detail.processedCount === 0) {
      const stationIndex: number = (this.detail.id % 100) - 1;
      const idx: number = stationIndex >= 0 && stationIndex < 7 ? stationIndex : 0;
      this.detail.processedCount = 150 - idx * 10;
      this.detail.rawMaterial = 81;
      this.detail.goodCount = 148 - idx * 10;
      this.detail.ngCount = 2;
    }
  }

  // 确认弹窗
  showActionConfirm(action: string, label: string): void {
    this.confirmAction = action;
    this.confirmActionLabel = label;
    this.showConfirmDialog = true;
  }

  confirmActionChange(): void {
    this.showConfirmDialog = false;
    if (this.confirmAction === 'start') {
      this.applyState('running');
      this.showToastMsg('设备已启动，正常运行中');
    } else if (this.confirmAction === 'stop') {
      this.applyState('stopped');
      this.showToastMsg('设备已停止');
    } else if (this.confirmAction === 'reset') {
      this.applyState('reset');
      this.showToastMsg('设备已复位');
    }
    this.confirmAction = '';
    this.confirmActionLabel = '';
  }

  cancelAction(): void {
    this.showConfirmDialog = false;
    this.confirmAction = '';
    this.confirmActionLabel = '';
  }

  // 异常上报弹窗
  showExceptionReport(): void {
    this.exceptionText = '';
    this.exceptionDetail = '';
    this.showExceptionDialog = true;
  }

  submitException(): void {
    if (!this.exceptionText || this.exceptionText.trim().length === 0) {
      this.showToastMsg('请填写异常描述');
      return;
    }
    this.showExceptionDialog = false;
    this.applyState('fault');

    // 同步到操作员刘伟的待办事项
    if (this.detail) {
      const task: string = JSON.stringify({
        title: '异常处理',
        description: this.exceptionText.trim(),
        workorderCode: this.detail.workorderCode,
        stationCode: this.detail.code,
        stationName: this.detail.name,
        lineName: this.detail.lineName,
        time: '2026-06-26',
      });
      // 追加到异常列表
      const existing: string = AppStorage.get('operator_exception_tasks') as string;
      let tasks: string = '';
      if (existing && existing.length > 0) {
        tasks = existing + '|||' + task;
      } else {
        tasks = task;
      }
      AppStorage.setOrCreate('operator_exception_tasks', tasks);
      // 触发操作员工作台刷新
      const oldTrigger: number = (AppStorage.get('operator_todo_trigger') as number) || 0;
      AppStorage.setOrCreate('operator_todo_trigger', oldTrigger + 1);
    }

    this.showToastMsg('异常已上报，已通知操作员刘伟');
  }

  cancelException(): void {
    this.showExceptionDialog = false;
    this.exceptionText = '';
    this.exceptionDetail = '';
  }

  onExceptionTextChange(text: string): void {
    this.exceptionText = text;
  }

  onExceptionDetailChange(text: string): void {
    this.exceptionDetail = text;
  }

  // 状态颜色
  getStatusColor(status: string): string {
    if (status === '运行' || status === '运行中' || status === '加工中' || status === '正转' || status === '生产中') return '#4CAF50';
    if (status === '故障' || status === '停机') return '#F44336';
    if (status === '待机' || status === '空闲' || status === '停止' || status === '—') return '#9E9E9E';
    return '#4CAF50';
  }

  getDeviceStatusDotColor(): string {
    if (this.runState === 'running') return '#4CAF50';
    if (this.runState === 'stopped' || this.runState === 'reset') return '#9E9E9E';
    if (this.runState === 'fault') return '#F44336';
    return '#9E9E9E';
  }

  // 按钮颜色
  getBtnColor(action: string): string {
    if (action === 'start') return this.isStartEnabled ? '#4CAF50' : '#CCCCCC';
    if (action === 'stop') return this.isStopEnabled ? '#FF9800' : '#CCCCCC';
    if (action === 'reset') return this.isResetEnabled ? '#F44336' : '#CCCCCC';
    if (action === 'exception') return '#EEEEEE';
    return '#CCCCCC';
  }

  getBtnTextColor(action: string): string {
    if (action === 'exception') return '#757575';
    if (this.isBtnEnabled(action)) return '#FFFFFF';
    return '#999999';
  }

  isBtnEnabled(action: string): boolean {
    if (action === 'start') return this.isStartEnabled;
    if (action === 'stop') return this.isStopEnabled;
    if (action === 'reset') return this.isResetEnabled;
    if (action === 'exception') return this.isExceptionEnabled;
    return false;
  }

  showToastMsg(msg: string): void {
    this.toastMsg = msg;
    this.showToast = true;
    setTimeout(() => {
      this.showToast = false;
    }, 2000);
  }
}
