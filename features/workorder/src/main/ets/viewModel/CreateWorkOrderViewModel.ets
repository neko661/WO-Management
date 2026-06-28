import { HttpApiService } from 'utils';

export interface ProductOption {
  id: number;
  name: string;
  code: string;
}

export interface LineOption {
  id: number;
  name: string;
}

@ObservedV2
export class CreateWorkOrderViewModel {
  @Trace newCode: string = '';
  @Trace orderType: string = '量产';
  @Trace productId: number = 1;
  @Trace productName: string = '';
  @Trace productCode: string = '';
  @Trace planQty: number = 100;
  @Trace lineId: number = 1;
  @Trace lineName: string = '';
  @Trace processName: string = '标准组装工艺';
  @Trace planStartTime: string = '';
  @Trace planEndTime: string = '';
  @Trace source: string = 'APP';
  @Trace note: string = '';
  @Trace isLoading: boolean = false;
  @Trace errorMessage: string = '';

  private api: HttpApiService = HttpApiService.getInstance();

  readonly orderTypes: string[] = ['量产', '试产', '返工', '维修'];
  readonly sourceOptions: string[] = ['APP', 'Web', '教学演示'];
  
  readonly productOptions: ProductOption[] = [
    { id: 1, name: '智能手机 Pro', code: 'P-SP-001' } as ProductOption,
    { id: 2, name: '智能手表 Watch', code: 'P-SW-002' } as ProductOption,
    { id: 3, name: '无线耳机 Buds', code: 'P-WE-003' } as ProductOption,
  ];

  readonly lineOptions: LineOption[] = [
    { id: 1, name: '柔性组装线' } as LineOption,
    { id: 2, name: '智能组装线' } as LineOption,
    { id: 3, name: 'SMT产线' } as LineOption,
    { id: 4, name: '机加工线' } as LineOption,
  ];

  init(): void {
    this.generateNewCode();
    
    // Default selections
    this.selectProduct(0);
    this.selectLine(0);

    // Default times
    const now: Date = new Date();
    const start: string = `${now.getFullYear()}-${this.pad(now.getMonth() + 1)}-${this.pad(now.getDate())} 08:00`;
    const end: string = `${now.getFullYear()}-${this.pad(now.getMonth() + 1)}-${this.pad(now.getDate() + 2)} 18:00`;
    this.planStartTime = start;
    this.planEndTime = end;
  }

  selectProduct(index: number): void {
    if (index >= 0 && index < this.productOptions.length) {
      this.productId = this.productOptions[index].id;
      this.productName = this.productOptions[index].name;
      this.productCode = this.productOptions[index].code;
    }
  }

  selectLine(index: number): void {
    if (index >= 0 && index < this.lineOptions.length) {
      this.lineId = this.lineOptions[index].id;
      this.lineName = this.lineOptions[index].name;
    }
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
    this.newCode = `MO${dateStr}${rand}`;
  }

  private pad(n: number): string {
    return n < 10 ? '0' + n.toString() : n.toString();
  }
}
