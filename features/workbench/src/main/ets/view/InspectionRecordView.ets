import { WorkOrder, HttpApiService } from 'utils';

class InspectRecord {
  code: string = '';
  productName: string = '';
  lineName: string = '';
  operatorName: string = '';
  planQty: number = 0;
  inspectQty: number = 0;
  goodQty: number = 0;
  ngQty: number = 0;
  result: string = '';
  resultColor: string = '';
  submitTime: string = '';

  constructor() {}
}

@ComponentV2
export struct InspectionRecordView {
  @Param cardPadding: number = 16;
  @Event onBack?: () => void;
  @Event onOrderClick?: (orderId: number) => void;
  @Local records: WorkOrder[] = [];
  @Local inspectResults: InspectRecord[] = [];
  private api: HttpApiService = HttpApiService.getInstance();

  async aboutToAppear(): Promise<void> {
    await this.loadRecords();
    this.loadInspectResults();
  }

  async loadRecords(): Promise<void> {
    try {
      const res = await this.api.getWorkOrders({ pageSize: 100 });
      if (res.code === 0 && res.data) {
        // 过滤出已抽检的工单（这里简单用 AppStorage 里的记录来判断）
        const allOrders = res.data.list;
        const inspectedOrders: WorkOrder[] = [];
        for (let i = 0; i < allOrders.length; i++) {
          const order = allOrders[i];
          const inspected = AppStorage.get('inspected_' + order.code) as string;
          if (inspected === 'true') {
            inspectedOrders.push(order);
          }
        }
        this.records = inspectedOrders.sort((a, b) => b.id - a.id);
      }
    } catch (e) {
      console.error('Failed to load records', e);
    }
  }

  loadInspectResults(): void {
    // 从 AppStorage 读取已提交的抽检结果
    const results: InspectRecord[] = [];
    // 遍历 records，获取对应的抽检结果
    for (let i: number = 0; i < this.records.length; i++) {
      const code = this.records[i].code;
      const raw: string = AppStorage.get('inspect_record_' + code) as string;
      if (raw && raw.length > 0) {
        const obj: Record<string, Object> = JSON.parse(raw) as Record<string, Object>;
        const rec: InspectRecord = new InspectRecord();
        rec.code = obj['code'] as string;
        rec.productName = obj['productName'] as string;
        rec.lineName = obj['lineName'] as string;
        rec.operatorName = obj['operatorName'] as string;
        rec.planQty = obj['planQty'] as number;
        rec.inspectQty = obj['inspectQty'] as number;
        rec.goodQty = obj['goodQty'] as number;
        rec.ngQty = obj['ngQty'] as number;
        rec.result = obj['result'] as string;
        rec.resultColor = obj['resultColor'] as string;
        rec.submitTime = obj['submitTime'] as string;
        results.push(rec);
      }
    }
    this.inspectResults = results;
  }

  addInspectedOrder(rec: InspectRecord): void {
    // 检查是否已存在
    for (let i: number = 0; i < this.records.length; i++) {
      if (this.records[i].code === rec.code) return;
    }
    const newOrder: WorkOrder = {
      id: 100 + this.records.length,
      code: rec.code,
      type: '量产',
      productId: 1,
      productName: rec.productName,
      productCode: 'PROD-WC-001',
      source: '抽检录入',
      planQty: rec.planQty,
      status: '已抽检',
      lineId: 1,
      lineName: rec.lineName,
      processId: 1,
      processName: rec.productName
    };
    const arr: WorkOrder[] = [];
    for (let i: number = 0; i < this.records.length; i++) {
      arr.push(this.records[i]);
    }
    arr.push(newOrder);
    this.records = arr;
  }

  getInspectResult(code: string): InspectRecord | null {
    for (let i: number = 0; i < this.inspectResults.length; i++) {
      if (this.inspectResults[i].code === code) {
        return this.inspectResults[i];
      }
    }
    return null;
  }

  hasInspectResult(code: string): boolean {
    const r: InspectRecord | null = this.getInspectResult(code);
    return r !== null && r.result.length > 0;
  }

  getResultLabel(code: string): string {
    const r: InspectRecord | null = this.getInspectResult(code);
    return r ? r.result : '合格';
  }

  getResultColor(code: string): string {
    const r: InspectRecord | null = this.getInspectResult(code);
    if (r && r.result.length > 0) return r.resultColor;
    return '#4CAF50'; // 默认绿色=合格
  }

  getInspectDetail(code: string): string {
    const r: InspectRecord | null = this.getInspectResult(code);
    if (r && r.result.length > 0) {
      return '抽检: ' + r.inspectQty.toString() + '件 / 良品 ' + r.goodQty.toString() + ' / NG ' + r.ngQty.toString();
    }
    return '';
  }

  build() {
    Column() {
      Row() {
        Column() {
          Text('‹').fontSize('24fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold)
        }
        .width('36vp').height('36vp').borderRadius('18vp').backgroundColor('#FFFFFF')
        .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        .margin({ right: '12vp' })
        .onClick(() => { this.onBack?.(); })

        Column() {
          Text('抽检记录').fontSize('18fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold)
          Text('已报工 · 抽检结果').fontSize('12fp').fontColor('#6B7B8C').margin({ top: '2vp' })
        }
        .alignItems(HorizontalAlign.Start).layoutWeight(1)
      }
      .width('100%')
      .padding({ left: this.cardPadding, right: this.cardPadding, top: '16vp', bottom: '12vp' })

      Scroll() {
        Column() {
          ForEach(this.records, (order: WorkOrder) => {
            this.buildOrderCard(order)
          })

          if (this.records.length === 0) {
            Text('暂无抽检记录').fontSize('15fp').fontColor('#999999').width('100%').padding({ top: '60vp' })
          }

          Blank().height('20vp')
        }
        .width('100%')
      }
      .layoutWeight(1).scrollBar(BarState.Off).align(Alignment.TopStart).backgroundColor('#E8EDF2')
    }
    .width('100%').height('100%').backgroundColor('#E8EDF2')
  }

  @Builder
  buildOrderCard(order: WorkOrder) {
    Column() {
      Row() {
        Column() {
          Text(order.code).fontSize('15fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold)
          Text(order.productName).fontSize('13fp').fontColor('#666666').margin({ top: '4vp' })
        }
        .layoutWeight(1).alignItems(HorizontalAlign.Start)

        Text(this.getResultLabel(order.code))
          .fontSize('12fp').fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
          .padding({ left: '12vp', right: '12vp', top: '4vp', bottom: '4vp' })
          .borderRadius('8vp').backgroundColor(this.getResultColor(order.code))
      }
      .width('100%')

      Row() {
        Text(order.type).fontSize('11fp').fontColor('#007DFF')
          .padding({ left: '6vp', right: '6vp', top: '2vp', bottom: '2vp' })
          .borderRadius('4vp').backgroundColor('#E3F2FD')
        Text(' · ' + order.lineName).fontSize('11fp').fontColor('#999999')
        Text(' · 计划: ' + order.planQty.toString()).fontSize('11fp').fontColor('#999999')
        Blank()
        Text('已报工').fontSize('11fp').fontColor('#4CAF50').fontWeight(FontWeight.Medium)
      }
      .width('100%').margin({ top: '10vp' })

      if (this.hasInspectResult(order.code)) {
        Row() {
          Text(this.getInspectDetail(order.code))
            .fontSize('11fp').fontColor('#6B7B8C')
        }
        .width('100%').margin({ top: '6vp' })
      }
    }
    .width('100%').padding('14vp').borderRadius('12vp').backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, bottom: '8vp' })
    .shadow({ radius: 3, color: '#0F000000', offsetY: 1 })
    .onClick(() => {
      this.onOrderClick?.(order.id);
    })
  }
}
