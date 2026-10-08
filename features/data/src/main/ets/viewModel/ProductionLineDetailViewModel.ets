import { BaseViewModel } from 'utils';
import { LineDetailFull, WorkstationDetail } from '../model/DataTypes';

export interface SelectTaskItem {
  id: number;
  code: string;
  productName: string;
  processName: string;
  planQty: number;
  operatorName: string;
  lineName: string;
}

@ObservedV2
export class ProductionLineDetailViewModel extends BaseViewModel {
  @Trace lineDetail: LineDetailFull | null = null;
  @Trace workstationStatusList: WorkstationDetail[] = [];
  @Trace availableTasks: SelectTaskItem[] = [];
  @Trace selectedTaskId: number = 0;
  @Trace selectedTaskCode: string = '';
  @Trace selectedTaskProduct: string = '';
  @Trace currentRole: string = '';
  @Trace showConfirmDialog: boolean = false;
  @Trace confirmAction: string = '';
  @Trace confirmStationId: number = 0;
  @Trace confirmStationName: string = '';
  @Trace showExceptionDialog: boolean = false;
  @Trace exceptionText: string = '';
  @Trace toastMessage: string = '';
  @Trace showToast: boolean = false;

  init(lineId: number, role: string = ''): void {
    this.currentRole = role;
    this.loadLineDetail(lineId);
    this.loadSelectableTasks(lineId);
  }

  isAdmin(): boolean {
    return this.currentRole === 'admin';
  }

  isLineActionDisabled(): boolean {
    return !this.isAdmin();
  }

  isSelectionDisabled(): boolean {
    return !this.isAdmin() || this.isRunning();
  }

  isTaskCardClickDisabled(): boolean {
    return !this.isAdmin() || this.isRunning();
  }

  hasSelectedTask(): boolean {
    return this.selectedTaskId > 0;
  }

  isRunning(): boolean {
    return !!this.lineDetail && this.lineDetail.status === 'running';
  }

  isPaused(): boolean {
    return !!this.lineDetail && this.lineDetail.status === 'stopped';
  }

  hasExceptionStation(): boolean {
    for (let i: number = 0; i < this.workstationStatusList.length; i++) {
      if (this.workstationStatusList[i].status === '异常') {
        return true;
      }
    }
    return false;
  }

  getExceptionSummary(): string {
    for (let i: number = 0; i < this.workstationStatusList.length; i++) {
      const station: WorkstationDetail = this.workstationStatusList[i];
      if (station.status === '异常') {
        return station.code + ' ' + station.name + ' 异常，请及时处理';
      }
    }
    return '';
  }

  getCurrentTaskSummary(): string {
    if (this.selectedTaskCode.length > 0) {
      return this.selectedTaskCode + ' · ' + this.selectedTaskProduct;
    }
    return '请先选择生产任务';
  }

  getLineActionTitle(): string {
    return this.isAdmin() ? '整线操作' : '整线状态';
  }

  getReadOnlyTip(): string {
    return this.isAdmin() ? '' : '当前账号仅可查看产线详情，只有管理员可以操作';
  }

  private loadSelectableTasks(lineId: number): void {
    const taskSeed: SelectTaskItem[] = [
      { id: 1, code: 'MO000002', productName: '无线充电器组装', processName: '柔性组装', planQty: 100, operatorName: '刘伟', lineName: '柔性组装线' },
      { id: 2, code: 'MO000006', productName: '无线充电器组装', processName: '锁螺丝', planQty: 80, operatorName: '刘伟', lineName: '柔性组装线' },
      { id: 3, code: 'MO000008', productName: '智能插座组装', processName: '整机装配', planQty: 120, operatorName: '李强', lineName: '智能组装线' },
      { id: 4, code: 'MO000009', productName: 'PCB焊接', processName: '焊接检测', planQty: 200, operatorName: '赵明', lineName: 'SMT产线' },
      { id: 5, code: 'MO000010', productName: '金属件加工', processName: '精加工', planQty: 60, operatorName: '王磊', lineName: '机加工线' }
    ];
    const lineName: string = this.getLineName(lineId);
    const result: SelectTaskItem[] = [];
    for (let i: number = 0; i < taskSeed.length; i++) {
      if (taskSeed[i].lineName === lineName) {
        result.push(taskSeed[i]);
      }
    }
    this.availableTasks = result;
    const storedTaskId: number = (AppStorage.get('line_selected_task_' + lineId.toString()) as number) || 0;
    if (storedTaskId > 0) {
      this.selectTask(storedTaskId);
    } else if (this.availableTasks.length > 0 && this.isRunning()) {
      this.selectTask(this.availableTasks[0].id);
    }
  }

  selectTask(taskId: number): void {
    if (this.isTaskCardClickDisabled()) {
      return;
    }
    for (let i: number = 0; i < this.availableTasks.length; i++) {
      const task: SelectTaskItem = this.availableTasks[i];
      if (task.id === taskId) {
        this.selectedTaskId = task.id;
        this.selectedTaskCode = task.code;
        this.selectedTaskProduct = task.productName;
        AppStorage.setOrCreate('line_selected_task_' + this.getCurrentLineId().toString(), task.id);
        return;
      }
    }
  }

  isTaskSelected(taskId: number): boolean {
    return this.selectedTaskId === taskId;
  }

  loadLineDetail(lineId: number): void {
    const lineName: string = this.getLineName(lineId);
    const processName: string = this.getProcessName(lineId);
    const currentState: string = this.getLineRunState(lineId);
    const isRunning: boolean = currentState === 'running';
    const hasFault: boolean = currentState === 'fault';
    const isStopped: boolean = currentState === 'stopped';
    const isReset: boolean = currentState === 'reset';
    const statusTag: string = isRunning ? '运行中' : hasFault ? '异常' : isStopped ? '暂停中' : isReset ? '已复位' : '待启动';
    const workorderStatus: string = isRunning ? '生产中' : hasFault || isStopped ? '暂停中' : isReset ? '已复位' : '待启动';

    this.lineDetail = {
      id: lineId,
      name: lineName,
      status: currentState,
      statusTag: statusTag,
      workorderCode: isRunning ? this.selectedTaskCode || this.getDefaultTaskCode(lineId) : (this.selectedTaskCode || '—'),
      currentProcess: processName,
      processDescription: '单操作员整线执行 · 先选任务再操作',
      operatorName: isRunning ? this.getOperatorName(lineId) : (this.selectedTaskId > 0 ? this.getSelectedTaskOperator() : '未分配'),
      workorderStatus: workorderStatus,
      rawMaterial: isRunning ? 81 : 0,
      finishedProduct: isRunning ? 65 : 0,
      ngCount: isRunning ? 2 : 0,
    };

    this.loadWorkstations(lineId);
  }

  loadWorkstations(lineId: number): void {
    const stationNames: string[] = ['上料', '主板组装', '后盖组装', '螺丝锁付', '激光打标', '成品检测', '下料'];
    const stationCodes: string[] = ['OP10', 'OP20', 'OP30', 'OP40', 'OP50', 'OP60', 'OP70'];
    const products: string[] = ['PROD-WC-001', 'PROD-WC-001', 'PROD-WC-001', 'PROD-WC-001', 'PROD-WC-001', 'PROD-WC-001', 'PROD-WC-001'];
    const times: string[] = ['2.5s', '3.0s', '4.2s', '5.1s', '3.8s', '2.0s', '1.5s'];
    const currentState: string = this.getLineRunState(lineId);
    const list: WorkstationDetail[] = [];

    for (let i: number = 0; i < 7; i++) {
      const stationId: number = lineId * 100 + i + 1;
      const savedState: string = (AppStorage.get('station_state_' + stationId.toString()) as string) || currentState;
      const state: string = savedState.length > 0 ? savedState : currentState;
      const ws: WorkstationDetail = {
        id: stationId,
        code: stationCodes[i],
        name: stationNames[i],
        deviceStatus: this.getDeviceStatusByState(state),
        workStatus: this.getWorkStatusByState(state),
        conveyorStatus: state === 'running' ? '运行' : '停止',
        productCode: products[i],
        processingTime: times[i],
        processedCount: state === 'running' ? 150 - i * 10 : 0,
        goodCount: state === 'running' ? 148 - i * 10 : 0,
        ngCount: state === 'running' ? 2 : 0,
        status: this.getStatusTextByState(state),
      };
      list.push(ws);
    }
    this.workstationStatusList = list;
    this.syncLineStateFromStations();
  }

  showActionConfirm(stationId: number, stationName: string, action: string): void {
    if (action === 'exception') {
      this.showExceptionDialog = true;
      this.confirmStationId = stationId;
      this.confirmStationName = stationName;
      return;
    }
    if (this.isLineActionDisabled()) {
      this.showToastMsg('当前账号仅可查看，不能执行整线操作');
      return;
    }
    if (action === 'start' && !this.hasSelectedTask()) {
      this.showToastMsg('请先选择生产任务');
      return;
    }
    this.confirmStationId = stationId;
    this.confirmStationName = stationName;
    this.confirmAction = action;
    this.showConfirmDialog = true;
  }

  showLineActionConfirm(action: string): void {
    this.showActionConfirm(0, '整线', action);
  }

  confirmActionChange(): void {
    this.showConfirmDialog = false;
    if (this.confirmAction === 'start') {
      this.applyLineState('running');
      this.showToastMsg('整线已启动，保持运行中');
    } else if (this.confirmAction === 'stop') {
      this.applyLineState('stopped');
      this.showToastMsg('整线已暂停');
    } else if (this.confirmAction === 'reset') {
      this.applyLineState('reset');
      this.showToastMsg('整线已复位');
    }
    this.confirmAction = '';
    this.confirmStationId = 0;
    this.confirmStationName = '';
  }

  cancelAction(): void {
    this.showConfirmDialog = false;
    this.showExceptionDialog = false;
    this.confirmAction = '';
    this.confirmStationId = 0;
    this.confirmStationName = '';
    this.exceptionText = '';
  }

  submitException(): void {
    if (this.exceptionText.trim().length === 0) {
      this.showToastMsg('请填写异常描述');
      return;
    }
    this.showExceptionDialog = false;
    this.applyLineState('fault');
    this.showToastMsg('异常已上报');
    this.exceptionText = '';
  }

  onExceptionTextChange(text: string): void {
    this.exceptionText = text;
  }

  getConfirmActionLabel(): string {
    if (this.confirmAction === 'start') return '启动';
    if (this.confirmAction === 'stop') return '暂停';
    if (this.confirmAction === 'reset') return '复位';
    return '';
  }

  getStatusBgColor(status: string): string {
    if (status === '运行中') return '#10B981';
    if (status === '暂停中') return '#F59E0B';
    if (status === '已复位') return '#64748B';
    if (status === '异常') return '#EF4444';
    return '#94A3B8';
  }

  getCardBgColor(status: string): string {
    if (status === '运行中') return '#F0FDF4';
    if (status === '暂停中') return '#FFF7ED';
    if (status === '已复位') return '#F8FAFC';
    if (status === '异常') return '#FEF2F2';
    return '#FFFFFF';
  }

  getCardBorderColor(status: string): string {
    if (status === '运行中') return '#BBF7D0';
    if (status === '暂停中') return '#FED7AA';
    if (status === '已复位') return '#CBD5E1';
    if (status === '异常') return '#FCA5A5';
    return '#E2E8F0';
  }

  getActionButtonBg(action: string): string {
    if (this.isLineActionDisabled()) return '#E5E7EB';
    if (action === 'start') return this.hasSelectedTask() && !this.isRunning() ? '#10B981' : '#D1D5DB';
    if (action === 'stop') return this.isRunning() ? '#F59E0B' : '#D1D5DB';
    if (action === 'reset') return this.isRunning() || this.isPaused() || this.hasExceptionStation() ? '#64748B' : '#D1D5DB';
    return '#E5E7EB';
  }

  isActionEnabled(action: string): boolean {
    if (this.isLineActionDisabled()) {
      return false;
    }
    if (action === 'start') {
      return this.hasSelectedTask() && !this.isRunning();
    }
    if (action === 'stop') {
      return this.isRunning();
    }
    if (action === 'reset') {
      return this.isRunning() || this.isPaused() || this.hasExceptionStation();
    }
    return true;
  }

  private applyLineState(state: string): void {
    const lineId: number = this.getCurrentLineId();
    AppStorage.setOrCreate('line_state_' + lineId.toString(), state);
    for (let i: number = 0; i < this.workstationStatusList.length; i++) {
      const station: WorkstationDetail = this.workstationStatusList[i];
      let stationState: string = state;
      if (state === 'fault' && station.id !== this.confirmStationId && this.confirmStationId > 0) {
        stationState = 'stopped';
      }
      AppStorage.setOrCreate('station_state_' + station.id.toString(), stationState);
    }
    this.loadLineDetail(lineId);
  }

  private syncLineStateFromStations(): void {
    let hasFault: boolean = false;
    let hasRunning: boolean = false;
    let hasStopped: boolean = false;
    let hasIdle: boolean = false;
    let allReset: boolean = this.workstationStatusList.length > 0;
    for (let i: number = 0; i < this.workstationStatusList.length; i++) {
      const status: string = this.workstationStatusList[i].status;
      if (status === '异常') {
        hasFault = true;
      }
      if (status === '运行中') {
        hasRunning = true;
      }
      if (status === '暂停中') {
        hasStopped = true;
      }
      if (status === '待启动') {
        hasIdle = true;
      }
      if (status !== '已复位') {
        allReset = false;
      }
    }
    if (!this.lineDetail) {
      return;
    }
    if (hasFault) {
      this.lineDetail.status = 'fault';
      this.lineDetail.statusTag = '异常';
      this.lineDetail.workorderStatus = '暂停中';
    } else if (hasRunning) {
      this.lineDetail.status = 'running';
      this.lineDetail.statusTag = '运行中';
      this.lineDetail.workorderStatus = '生产中';
    } else if (allReset) {
      this.lineDetail.status = 'reset';
      this.lineDetail.statusTag = '已复位';
      this.lineDetail.workorderStatus = '已复位';
    } else if (hasStopped) {
      this.lineDetail.status = 'stopped';
      this.lineDetail.statusTag = '暂停中';
      this.lineDetail.workorderStatus = '暂停中';
    } else if (hasIdle) {
      this.lineDetail.status = 'idle';
      this.lineDetail.statusTag = '待启动';
      this.lineDetail.workorderStatus = '待启动';
    } else {
      this.lineDetail.status = 'idle';
      this.lineDetail.statusTag = '待启动';
      this.lineDetail.workorderStatus = '待启动';
    }
  }

  private getLineRunState(lineId: number): string {
    const state: string = (AppStorage.get('line_state_' + lineId.toString()) as string) || '';
    if (state.length > 0) {
      return state;
    }
    return lineId === 1 ? 'running' : 'idle';
  }

  private getCurrentLineId(): number {
    return this.lineDetail ? this.lineDetail.id : 1;
  }

  private getLineName(lineId: number): string {
    const lineNames: string[] = ['柔性组装线', '智能组装线', 'SMT产线', '机加工线'];
    return lineNames[lineId - 1] || '柔性组装线';
  }

  private getProcessName(lineId: number): string {
    const processes: string[] = ['无线充电器组装', '智能手机组装', 'PCB焊接', '金属件加工'];
    return processes[lineId - 1] || '无线充电器组装';
  }

  private getDefaultTaskCode(lineId: number): string {
    const codes: string[] = ['MO000002', 'MO000008', 'MO000009', 'MO000010'];
    return codes[lineId - 1] || 'MO000002';
  }

  private getOperatorName(lineId: number): string {
    if (this.selectedTaskId > 0) {
      return this.getSelectedTaskOperator();
    }
    const operators: string[] = ['刘伟', '李强', '赵明', '王磊'];
    return operators[lineId - 1] || '刘伟';
  }

  private getSelectedTaskOperator(): string {
    for (let i: number = 0; i < this.availableTasks.length; i++) {
      if (this.availableTasks[i].id === this.selectedTaskId) {
        return this.availableTasks[i].operatorName;
      }
    }
    return '未分配';
  }

  private getDeviceStatusByState(state: string): string {
    if (state === 'running') return '运行';
    if (state === 'fault') return '故障';
    return '待机';
  }

  private getWorkStatusByState(state: string): string {
    if (state === 'running') return '加工中';
    if (state === 'fault') return '停机';
    return '空闲';
  }

  private getStatusTextByState(state: string): string {
    if (state === 'running') return '运行中';
    if (state === 'stopped' || state === 'idle') return '暂停中';
    if (state === 'reset') return '已复位';
    if (state === 'fault') return '异常';
    return '待启动';
  }

  private showToastMsg(msg: string): void {
    this.toastMessage = msg;
    this.showToast = true;
    setTimeout(() => {
      this.showToast = false;
    }, 1800);
  }
}
