import { BaseViewModel } from 'utils';
import { LineDetailFull, WorkstationDetail } from '../model/DataTypes';

@ObservedV2
export class ProductionLineDetailViewModel extends BaseViewModel {
  @Trace lineDetail: LineDetailFull | null = null;
  @Trace workstationStatusList: WorkstationDetail[] = [];

  // 确认弹窗状态
  @Trace showConfirmDialog: boolean = false;
  @Trace confirmAction: string = '';
  @Trace confirmStationId: number = 0;
  @Trace confirmStationName: string = '';

  init(lineId: number): void {
    this.loadLineDetail(lineId);
  }

  loadLineDetail(lineId: number): void {
    const lineNames: string[] = ['柔性组装线', '智能组装线', 'SMT产线', '机加工线'];
    const processes: string[] = ['无线充电器组装', '智能手机组装', 'PCB焊接', '金属件加工'];
    const workorderCodes: string[] = ['MO000002', 'MO000008', 'MO000009', 'MO000010'];
    const operators: string[] = ['刘伟', '李强', '赵明', '王磊'];
    const statuses: string[] = ['生产中', '空闲', '生产中', '空闲'];

    const name: string = lineNames[lineId - 1] || '柔性组装线';
    const isRunning: boolean = statuses[lineId - 1] === '生产中';

    this.lineDetail = {
      id: lineId,
      name: name,
      status: isRunning ? 'running' : 'idle',
      statusTag: isRunning ? '生产中' : '空闲',
      workorderCode: isRunning ? workorderCodes[lineId - 1] : '—',
      currentProcess: processes[lineId - 1],
      processDescription: '单操作员整线执行',
      operatorName: isRunning ? operators[lineId - 1] : '—',
      workorderStatus: isRunning ? '生产中' : '—',
      rawMaterial: isRunning ? 81 : 0,
      finishedProduct: isRunning ? 65 : 0,
      ngCount: isRunning ? 2 : 0,
    };

    this.loadWorkstations(lineId);
  }

  loadWorkstations(lineId: number): void {
    const stationNames: string[] = ['上料', '检测', '装配', '焊接', '测试', '包装', '下料'];
    const stationCodes: string[] = ['OP10', 'OP20', 'OP30', 'OP40', 'OP50', 'OP60', 'OP70'];
    const products: string[] = ['PROD-WC-001', 'PROD-WC-001', 'PROD-WC-001', 'PROD-WC-001', 'PROD-WC-001', 'PROD-WC-001', 'PROD-WC-001'];
    const times: string[] = ['2.5s', '3.0s', '4.2s', '5.1s', '3.8s', '2.0s', '1.5s'];

    this.workstationStatusList = [];
    for (let i: number = 0; i < 7; i++) {
      const stationId: number = lineId * 100 + i + 1;
      const savedState: string = AppStorage.get('station_state_' + stationId.toString()) as string;

      let deviceStatus: string = '运行';
      let workStatus: string = '加工中';
      let conveyorStatus: string = '运行';
      let status: string = '运行中';
      let processedCount: number = 150 - i * 10;
      let goodCount: number = 148 - i * 10;
      let ngCount: number = 2;

      if (savedState === 'stopped') {
        deviceStatus = '待机'; workStatus = '空闲'; conveyorStatus = '停止';
        status = '已停止'; processedCount = 0; goodCount = 0; ngCount = 0;
      } else if (savedState === 'reset') {
        deviceStatus = '待机'; workStatus = '空闲'; conveyorStatus = '停止';
        status = '已复位'; processedCount = 0; goodCount = 0; ngCount = 0;
      } else if (savedState === 'fault') {
        deviceStatus = '故障'; workStatus = '停机'; conveyorStatus = '停止';
        status = '异常'; processedCount = 0; goodCount = 0; ngCount = 0;
      }

      const ws: WorkstationDetail = {
        id: stationId,
        code: stationCodes[i],
        name: stationNames[i],
        deviceStatus: deviceStatus,
        workStatus: workStatus,
        conveyorStatus: conveyorStatus,
        productCode: products[i],
        processingTime: times[i],
        processedCount: processedCount,
        goodCount: goodCount,
        ngCount: ngCount,
        status: status,
      };
      this.workstationStatusList.push(ws);
    }
  }

  // 打开确认弹窗
  showActionConfirm(stationId: number, stationName: string, action: string): void {
    this.confirmStationId = stationId;
    this.confirmStationName = stationName;
    this.confirmAction = action;
    this.showConfirmDialog = true;
  }

  // 确认操作
  confirmActionChange(): void {
    this.showConfirmDialog = false;
    if (this.confirmAction === 'start') {
      this.doStart(this.confirmStationId);
    } else if (this.confirmAction === 'stop') {
      this.doStop(this.confirmStationId);
    } else if (this.confirmAction === 'reset') {
      this.doReset(this.confirmStationId);
    } else if (this.confirmAction === 'exception') {
      this.doException(this.confirmStationId);
    }
    this.confirmAction = '';
    this.confirmStationId = 0;
    this.confirmStationName = '';
  }

  // 取消
  cancelAction(): void {
    this.showConfirmDialog = false;
    this.confirmAction = '';
    this.confirmStationId = 0;
    this.confirmStationName = '';
  }

  getConfirmActionLabel(): string {
    if (this.confirmAction === 'start') return '启动';
    if (this.confirmAction === 'stop') return '停止';
    if (this.confirmAction === 'reset') return '复位';
    if (this.confirmAction === 'exception') return '异常上报';
    return '';
  }

  // 查找工作站
  private findStation(stationId: number): WorkstationDetail | null {
    for (let i: number = 0; i < this.workstationStatusList.length; i++) {
      if (this.workstationStatusList[i].id === stationId) {
        return this.workstationStatusList[i];
      }
    }
    return null;
  }

  // 强制刷新列表以触发 UI 更新
  private refreshList(): void {
    const copy: WorkstationDetail[] = [];
    for (let i: number = 0; i < this.workstationStatusList.length; i++) {
      const old: WorkstationDetail = this.workstationStatusList[i];
      const item: WorkstationDetail = {
        id: old.id, code: old.code, name: old.name,
        deviceStatus: old.deviceStatus, workStatus: old.workStatus,
        conveyorStatus: old.conveyorStatus, productCode: old.productCode,
        processingTime: old.processingTime, processedCount: old.processedCount,
        goodCount: old.goodCount, ngCount: old.ngCount, status: old.status
      };
      copy.push(item);
    }
    this.workstationStatusList = copy;
  }

  // 启动 → 运行中 (green)
  doStart(stationId: number): void {
    const ws: WorkstationDetail | null = this.findStation(stationId);
    if (!ws) return;
    ws.status = '运行中';
    ws.deviceStatus = '运行';
    ws.workStatus = '加工中';
    ws.conveyorStatus = '运行';
    ws.processedCount = 150 - ((stationId % 100) - 1) * 10;
    ws.goodCount = 148 - ((stationId % 100) - 1) * 10;
    ws.ngCount = 2;
    this.saveStationState(stationId, 'running');
    this.refreshList();
  }

  // 停止 → 已停止 (orange) | 设备待机, 工作空闲, 传送带停止, 计数清零
  doStop(stationId: number): void {
    const ws: WorkstationDetail | null = this.findStation(stationId);
    if (!ws) return;
    ws.status = '已停止';
    ws.deviceStatus = '待机';
    ws.workStatus = '空闲';
    ws.conveyorStatus = '停止';
    ws.processedCount = 0;
    ws.goodCount = 0;
    ws.ngCount = 0;
    this.saveStationState(stationId, 'stopped');
    this.refreshList();
  }

  // 复位 → 已复位 (red) | 设备待机, 工作空闲, 传送带停止, 计数清零
  doReset(stationId: number): void {
    const ws: WorkstationDetail | null = this.findStation(stationId);
    if (!ws) return;
    ws.status = '已复位';
    ws.deviceStatus = '待机';
    ws.workStatus = '空闲';
    ws.conveyorStatus = '停止';
    ws.processedCount = 0;
    ws.goodCount = 0;
    ws.ngCount = 0;
    this.saveStationState(stationId, 'reset');
    this.refreshList();
  }

  // 异常上报 → 异常 (gray) | 设备故障, 工作停机, 传送带停止
  doException(stationId: number): void {
    const ws: WorkstationDetail | null = this.findStation(stationId);
    if (!ws) return;
    ws.status = '异常';
    ws.deviceStatus = '故障';
    ws.workStatus = '停机';
    ws.conveyorStatus = '停止';
    ws.processedCount = 0;
    ws.goodCount = 0;
    ws.ngCount = 0;
    this.saveStationState(stationId, 'fault');
    this.refreshList();
  }

  // 保存状态到 AppStorage，供工作站详情页读取
  saveStationState(stationId: number, state: string): void {
    AppStorage.setOrCreate('station_state_' + stationId.toString(), state);
  }

  getStatusBgColor(status: string): string {
    if (status === '运行中') return '#4CAF50';     // 绿色
    if (status === '已停止') return '#E65100';     // 深橙色
    if (status === '已复位') return '#F44336';     // 红色
    if (status === '异常') return '#9E9E9E';       // 灰色
    return '#4CAF50';
  }
}
