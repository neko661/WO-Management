import { HttpApiService } from 'utils';

export interface ProductCodeOption {
  code: string;
  name: string;
}

@ObservedV2
export class LeaderCreateWorkOrderViewModel {
  @Trace woCode: string = '';
  @Trace orderType: string = '';
  @Trace workshop: string = '';
  @Trace resource: string = '';
  @Trace productCode: string = '';
  @Trace productName: string = '';
  @Trace planQty: string = '';
  @Trace planStartTime: string = '';
  @Trace planEndTime: string = '';
  @Trace isLoading: boolean = false;
  @Trace errorMessage: string = '';

  private api: HttpApiService = HttpApiService.getInstance();

  readonly orderTypes: string[] = ['试产', '量产', '返工'];
  readonly workshops: string[] = ['柔性车间', '智能车间', 'SMT车间', '机加工车间'];
  readonly resources: string[] = ['柔性线', '智能线', 'SMT线', '机加工线'];
  readonly productCodes: ProductCodeOption[] = [
    { code: 'PROD-WC-001', name: '无线充电器组装' } as ProductCodeOption,
    { code: 'PROD-SS-001', name: '智能插座组装' } as ProductCodeOption,
    { code: 'PROD-SP-001', name: '智能手机组装' } as ProductCodeOption,
    { code: 'PROD-ST-001', name: '智能平板组装' } as ProductCodeOption,
    { code: 'PROD-DC-001', name: '数据采集器主板贴装' } as ProductCodeOption,
    { code: 'PROD-HS-001', name: '外壳加工' } as ProductCodeOption,
    { code: 'PROD-PM-001', name: '零件精加工' } as ProductCodeOption,
  ];

  init(): void {
    this.generateCode();
  }

  generateCode(): void {
    const now = new Date();
    const dateStr = `${now.getFullYear()}${this.pad(now.getMonth() + 1)}${this.pad(now.getDate())}`;
    const rand = this.pad(Math.floor(Math.random() * 999) + 1);
    this.woCode = `MO${dateStr}${rand}`;
  }

  selectProductCode(code: string): void {
    this.productCode = code;
    const product = this.productCodes.find((p) => p.code === code);
    this.productName = product ? product.name : '';
  }

  async save(): Promise<boolean> {
    if (!this.orderType) {
      this.errorMessage = '请选择工单类型';
      return false;
    }
    if (!this.workshop) {
      this.errorMessage = '请选择车间';
      return false;
    }
    if (!this.resource) {
      this.errorMessage = '请选择资源';
      return false;
    }
    if (!this.productCode) {
      this.errorMessage = '请选择产品编码';
      return false;
    }
    const qty = parseInt(this.planQty);
    if (!this.planQty || isNaN(qty) || qty <= 0) {
      this.errorMessage = '请输入有效计划数量';
      return false;
    }
    if (!this.planStartTime) {
      this.errorMessage = '请选择计划开始时间';
      return false;
    }
    if (!this.planEndTime) {
      this.errorMessage = '请选择计划结束时间';
      return false;
    }

    const startTime = new Date(this.planStartTime.replace(/-/g, '/')).getTime();
    const endTime = new Date(this.planEndTime.replace(/-/g, '/')).getTime();
    const now = new Date().getTime();

    // 允许开始时间比当前时间早一点点（比如今天早些时候），但为了严格匹配规则，这里可以做个简单的当天判断
    // 简单起见，直接比较时间戳，或者只比较日期
    if (startTime < now - 24 * 60 * 60 * 1000) { // 允许选择今天
      this.errorMessage = '计划开始时间需大于等于当前时间';
      return false;
    }

    if (endTime <= startTime) {
      this.errorMessage = '计划结束时间需大于计划开始时间';
      return false;
    }

    this.isLoading = true;
    this.errorMessage = '';
    try {
      const lineId = this.getLineIdByResource();
      const lineName = this.getLineNameByResource();
      const res = await this.api.createWorkOrder({
        productName: this.productName,
        productCode: this.productCode,
        planQty: qty,
        lineId: lineId,
        lineName: lineName,
        processName: this.productName,
        type: this.orderType,
      });
      if (res.code === 0) {
        return true;
      } else {
        this.errorMessage = res.msg || '创建失败';
        return false;
      }
    } catch (_) {
      this.errorMessage = '网络错误';
      return false;
    } finally {
      this.isLoading = false;
    }
  }

  private getLineIdByResource(): number {
    const map: Record<string, number> = {
      '柔性线': 1,
      '智能线': 2,
      'SMT线': 3,
      '机加工线': 4,
    };
    return map[this.resource] || 1;
  }

  private getLineNameByResource(): string {
    const map: Record<string, string> = {
      '柔性线': '柔性组装线',
      '智能线': '智能组装线',
      'SMT线': 'SMT产线',
      '机加工线': '机加工线',
    };
    return map[this.resource] || '柔性组装线';
  }

  private pad(n: number): string {
    return n < 10 ? '0' + n.toString() : n.toString();
  }
}
