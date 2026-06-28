import { HttpApiService, WorkOrder } from 'utils';

export interface LineOption {
  id: number;
  name: string;
}

@ObservedV2
export class CopyWorkOrderViewModel {
  @Trace sourceCode: string = '';
  @Trace newCode: string = '';
  @Trace orderType: string = '量产';
  @Trace productName: string = '';
  @Trace productCode: string = '';
  @Trace planQty: number = 100;
  @Trace lineId: number = 1;
  @Trace lineName: string = '';
  @Trace processName: string = '';
  @Trace planStartTime: string = '';
  @Trace planEndTime: string = '';
  @Trace isLoading: boolean = false;
  @Trace errorMessage: string = '';

  private api: HttpApiService = HttpApiService.getInstance();
  private sourceOrder: WorkOrder | null = null;

  readonly orderTypes: string[] = ['量产', '试产'];
  readonly lineOptions: LineOption[] = [
    { id: 1, name: '柔性组装线' } as LineOption,
    { id: 2, name: '智能组装线' } as LineOption,
    { id: 3, name: 'SMT产线' } as LineOption,
    { id: 4, name: '机加工线' } as LineOption,
  ];

  init(source: WorkOrder): void {
    this.sourceOrder = source;
    this.sourceCode = source.code;
    this.productName = source.productName;
    this.productCode = source.productCode;
    this.planQty = source.planQty;
    this.lineId = source.lineId;
    this.lineName = source.lineName;
    this.processName = source.processName;
    this.orderType = source.type || '量产';

    // Auto-generate new code
    this.generateNewCode();

    // Default times
    const now: Date = new Date();
    const start: string = `${now.getFullYear()}-${this.pad(now.getMonth() + 1)}-${this.pad(now.getDate())} 08:00`;
    const end: string = `${now.getFullYear()}-${this.pad(now.getMonth() + 1)}-${this.pad(now.getDate())} 14:00`;
    this.planStartTime = start;
    this.planEndTime = end;
  }

  getLineLabels(): string[] {
    const labels: string[] = [];
    for (let i: number = 0; i < this.lineOptions.length; i++) {
      labels.push(this.lineOptions[i].name);
    }
    return labels;
  }

  selectLine(index: number): void {
    if (index >= 0 && index < this.lineOptions.length) {
      this.lineId = this.lineOptions[index].id;
      this.lineName = this.lineOptions[index].name;
    }
  }

  getProcessSteps(): string[] {
    // Default process steps based on product
    return [
      'OP10 / 主板组装',
      'OP20 / 后盖组装',
      'OP30 / 成品检测',
    ];
  }

  async save(): Promise<boolean> {
    if (this.planQty <= 0) {
      this.errorMessage = '计划数量必须大于0';
      return false;
    }
    this.isLoading = true;
    this.errorMessage = '';
    try {
      const res = await this.api.createWorkOrder({
        productName: this.productName,
        productCode: this.productCode,
        planQty: this.planQty,
        lineId: this.lineId,
        lineName: this.lineName,
        processName: this.processName,
        type: this.orderType,
      });
      if (res.code === 0) {
        return true;
      } else {
        this.errorMessage = res.msg || '保存失败';
        return false;
      }
    } catch (_) {
      this.errorMessage = '网络错误';
      return false;
    } finally {
      this.isLoading = false;
    }
  }

  private generateNewCode(): void {
    const now: Date = new Date();
    const dateStr: string = `${now.getFullYear()}${this.pad(now.getMonth() + 1)}${this.pad(now.getDate())}`;
    const rand: string = this.pad(Math.floor(Math.random() * 99) + 1);
    this.newCode = `WO-${dateStr}-${rand}`;
  }

  private pad(n: number): string {
    return n < 10 ? '0' + n.toString() : n.toString();
  }
}
