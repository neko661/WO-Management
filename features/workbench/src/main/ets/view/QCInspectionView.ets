import { HttpApiService } from 'utils';

@ComponentV2
export struct QCInspectionView {
  @Param cardPadding: number = 16;
  @Param orderCode: string = 'MO000003';
  @Event onBack?: () => void;
  @Local orderId: number = 0;
  @Local productName: string = '无线充电器组装';
  @Local lineName: string = '柔性组装线';
  @Local operatorName: string = '刘伟';
  @Local planQty: number = 100;
  @Local reportedHours: number = 1.8;
  @Local reportedGoodQty: number = 96;
  @Local reportedNgQty: number = 4;

  // 抽检录入
  @Local inspectQty: number = 5;
  @Local goodQty: number = 5;
  @Local ngQty: number = 0;

  // 不良原因
  @Local defectDesc: string = '';

  // 常见不良多选
  @Local defectTypes: string[] = [];
  @Local defectOptions: string[] = ['外观缺陷', '尺寸偏差', '功能失效', '装配不良'];

  // 校验提示
  @Local showToast: boolean = false;
  @Local toastMsg: string = '';
  @Local showSubmitDialog: boolean = false;

  private api: HttpApiService = HttpApiService.getInstance();

  aboutToAppear() {
    this.loadOrderDetails();
  }

  async loadOrderDetails() {
    try {
      const res = await this.api.getWorkOrders({ keyword: this.orderCode, pageSize: 1 });
      if (res.code === 0 && res.data && res.data.list.length > 0) {
        const order = res.data.list[0];
        this.orderId = order.id;
        this.productName = order.productName;
        this.lineName = order.lineName || '柔性组装线';
        this.operatorName = order.operatorName || '刘伟';
        this.planQty = order.planQty;
        this.reportedGoodQty = order.goodQty || 0;
        this.reportedNgQty = order.ngQty || 0;
        this.reportedHours = order.reportedHours || 0;
      }
    } catch (e) {
      console.error('Failed to load order details', e);
    }
  }

  build() {
    Stack() {
      Column() {
        // Header
        this.buildHeader()

        Scroll() {
          Column() {
            // 1. 工单信息
            this.buildOrderInfo()

            // 2. 抽检录入
            this.buildInspectInput()

            // 3. 不良原因描述
            this.buildDefectInput()

            // 4. 常见不良类型
            this.buildDefectTypes()

            // 5. 说明区
            this.buildNotice()

            // 6. 操作按钮
            this.buildSubmitButtons()

            Blank().height('20vp')
          }
          .width('100%')
        }
        .layoutWeight(1).scrollBar(BarState.Off).align(Alignment.TopStart).backgroundColor('#E8EDF2')
      }
      .width('100%').height('100%').backgroundColor('#E8EDF2')

      // Toast
      if (this.showToast) {
        Column() {
          Text(this.toastMsg).fontSize('14fp').fontColor('#FFFFFF')
            .padding({ left: '20vp', right: '20vp', top: '10vp', bottom: '10vp' })
            .borderRadius('20vp').backgroundColor('#CC000000')
        }
        .width('100%').position({ x: 0, y: '70%' }).alignItems(HorizontalAlign.Center)
      }

      // 提交确认弹窗
      if (this.showSubmitDialog) {
        this.buildSubmitConfirm()
      }
    }
    .width('100%').height('100%')
  }

  @Builder
  buildHeader() {
    Row() {
      Column() {
        Text('‹').fontSize('24fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold)
      }
      .width('36vp').height('36vp').borderRadius('18vp').backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
      .margin({ right: '12vp' })
      .onClick(() => { this.onBack?.(); })

      Column() {
        Text('质检抽检').fontSize('18fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold)
        Text('录入抽检结果和不良原因').fontSize('12fp').fontColor('#6B7B8C').margin({ top: '2vp' })
      }
      .alignItems(HorizontalAlign.Start).layoutWeight(1)
    }
    .width('100%').padding({ left: this.cardPadding, right: this.cardPadding, top: '16vp', bottom: '12vp' })
  }

  // ====== 1. 工单信息 ======
  @Builder
  buildOrderInfo() {
    Column() {
      Text(this.orderCode).fontSize('20fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold).width('100%')
      Row() {
        Text(this.productName + ' / ' + this.lineName + ' / 状态：生产完成')
          .fontSize('12fp').fontColor('#6B7B8C').layoutWeight(1)
        Text('待报工')
          .fontSize('11fp').fontColor('#FF9800').fontWeight(FontWeight.Medium)
          .padding({ left: '8vp', right: '8vp', top: '3vp', bottom: '3vp' })
          .borderRadius('6vp').backgroundColor('#FFF3E0')
      }
      .width('100%').margin({ top: '6vp' })

      Row() {
        Text(this.lineName).fontSize('12fp').fontColor('#6B7B8C')
        Text(' / 操作员 ' + this.operatorName).fontSize('12fp').fontColor('#6B7B8C')
        Text(' / 计划产量 ' + this.planQty.toString()).fontSize('12fp').fontColor('#6B7B8C')
      }
      .width('100%').margin({ top: '4vp' })

      Text('已完成生产并报工').fontSize('12fp').fontColor('#4CAF50').width('100%').margin({ top: '6vp' })

      // 报工数据
      Row() {
        this.buildMiniStat('申报工时', this.reportedHours.toString() + 'h', '#007DFF', '#E3F2FD')
        this.buildMiniStat('报工良品', this.reportedGoodQty.toString(), '#4CAF50', '#E8F5E9')
        this.buildMiniStat('报工NG', this.reportedNgQty.toString(), '#F44336', '#FFEBEE')
      }
      .width('100%').margin({ top: '8vp' })
    }
    .width('100%').padding('14vp').borderRadius('12vp').backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp' })
    .shadow({ radius: 3, color: '#0F000000', offsetY: 1 })
  }

  @Builder
  buildMiniStat(label: string, val: string, color: string, bg: string) {
    Column() {
      Text(label).fontSize('10fp').fontColor('#999999')
      Text(val).fontSize('18fp').fontColor(color).fontWeight(FontWeight.Bold).margin({ top: '3vp' })
    }
    .layoutWeight(1).height('60vp')
    .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
    .borderRadius('8vp').backgroundColor(bg)
    .margin({ left: label === '申报工时' ? '0vp' : '8vp' })
  }

  // ====== 2. 抽检录入 ======
  @Builder
  buildInspectInput() {
    Column() {
      Text('抽检录入').fontSize('16fp').fontColor('#1A2B3C').fontWeight(FontWeight.Medium)
        .width('100%').margin({ bottom: '10vp' })

      Text('抽检良品 + 抽检NG = 抽检数量')
        .fontSize('11fp').fontColor(this.goodQty + this.ngQty === this.inspectQty ? '#4CAF50' : '#F44336')
        .width('100%').margin({ bottom: '8vp' })

      Grid() {
        GridItem() { this.buildNumInput('抽检数量', this.inspectQty) }
        GridItem() { this.buildNumInput('抽检良品', this.goodQty) }
        GridItem() { this.buildNumInput('抽检NG', this.ngQty) }
      }
      .width('100%').columnsTemplate('1fr 1fr 1fr').columnsGap('8vp')
    }
    .width('100%').padding('14vp').borderRadius('12vp').backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp' })
    .shadow({ radius: 3, color: '#0F000000', offsetY: 1 })
  }

  @Builder
  buildNumInput(label: string, val: number) {
    Column() {
      Text(label).fontSize('11fp').fontColor('#6B7B8C').width('100%')
      TextInput({ text: val.toString(), placeholder: '0' })
        .fontSize('22fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold)
        .backgroundColor('transparent')
        .type(InputType.Number)
        .width('100%').height('36vp')
        .margin({ top: '4vp' })
        .onChange((v: string) => { this.onNumChange(label, v); })
    }
    .width('100%').padding('10vp').borderRadius('8vp').backgroundColor('#F8F9FB')
    .alignItems(HorizontalAlign.Start)
  }

  onNumChange(field: string, val: string): void {
    const num: number = parseInt(val);
    if (isNaN(num)) return;
    if (field === '抽检数量' && num >= 0 && num <= 999) {
      this.inspectQty = num;
    } else if (field === '抽检良品' && num >= 0) {
      this.goodQty = num;
    } else if (field === '抽检NG' && num >= 0) {
      this.ngQty = num;
    }
  }

  // ====== 3. 不良原因描述 ======
  @Builder
  buildDefectInput() {
    Column() {
      Text('不良原因描述').fontSize('16fp').fontColor('#1A2B3C').fontWeight(FontWeight.Medium)
        .width('100%').margin({ bottom: '10vp' })

      TextInput({ text: this.defectDesc, placeholder: '请描述发现的不良现象和原因，如：外观划伤、尺寸偏差等' })
        .fontSize('14fp').fontColor('#1A2B3C').backgroundColor('#F5F7FA')
        .borderRadius('8vp').height('80vp').padding('12vp')
        .type(InputType.Normal).maxLines(4)
        .onChange((v: string) => { this.defectDesc = v; })
    }
    .width('100%').padding('14vp').borderRadius('12vp').backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp' })
    .shadow({ radius: 3, color: '#0F000000', offsetY: 1 })
  }

  // ====== 4. 常见不良类型 ======
  @Builder
  buildDefectTypes() {
    Column() {
      Text('常见不良类型（多选）').fontSize('16fp').fontColor('#1A2B3C').fontWeight(FontWeight.Medium)
        .width('100%').margin({ bottom: '10vp' })

      Row() {
        ForEach(this.defectOptions, (opt: string) => {
          this.buildDefectChip(opt)
        })
      }
      .width('100%')
    }
    .width('100%').padding('14vp').borderRadius('12vp').backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp' })
    .shadow({ radius: 3, color: '#0F000000', offsetY: 1 })
  }

  @Builder
  buildDefectChip(opt: string) {
    Row() {
      Text((this.defectTypes.indexOf(opt) >= 0) ? '✓ ' : '○ ').fontSize('12fp')
      Text(opt).fontSize('12fp')
    }
    .padding({ left: '10vp', right: '10vp', top: '6vp', bottom: '6vp' })
    .borderRadius('16vp')
    .backgroundColor((this.defectTypes.indexOf(opt) >= 0) ? '#E3F2FD' : '#F5F7FA')
    .border({ width: '1vp', color: (this.defectTypes.indexOf(opt) >= 0) ? '#007DFF' : '#E0E5EB' })
    .margin({ right: '8vp', bottom: '8vp' })
    .onClick(() => { this.toggleDefect(opt); })
  }

  toggleDefect(opt: string): void {
    const idx: number = this.defectTypes.indexOf(opt);
    if (idx >= 0) {
      const arr: string[] = [];
      for (let i: number = 0; i < this.defectTypes.length; i++) {
        if (i !== idx) arr.push(this.defectTypes[i]);
      }
      this.defectTypes = arr;
    } else {
      const arr: string[] = [];
      for (let i: number = 0; i < this.defectTypes.length; i++) {
        arr.push(this.defectTypes[i]);
      }
      arr.push(opt);
      this.defectTypes = arr;
    }
  }

  // ====== 5. 说明区 ======
  @Builder
  buildNotice() {
    Text('质检员对已报工的工单进行抽检，建议抽检数量为批量的5%-10%。抽检完成后录入良品和NG数量，如有不良请详细描述不良原因。提交后工单质检信息将被更新，班组长可查看抽检结果并确认工时。')
      .fontSize('11fp').fontColor('#6B7B8C').width('100%')
      .padding('14vp').borderRadius('10vp').backgroundColor('#F5F7FA')
      .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp' })
  }

  // ====== 6. 操作按钮 ======
  @Builder
  buildSubmitButtons() {
    Row() {
      Button() {
        Text('取消').fontSize('15fp').fontColor('#666666').fontWeight(FontWeight.Medium)
      }
      .layoutWeight(1).height('44vp').borderRadius('8vp').backgroundColor('#F0F0F0')
      .margin({ right: '10vp' })
      .onClick(() => { this.onBack?.(); })

      Button() {
        Text('提交抽检').fontSize('15fp').fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
      }
      .layoutWeight(1).height('44vp').borderRadius('8vp').backgroundColor('#007DFF')
      .onClick(() => { this.validateAndSubmit(); })
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '12vp', bottom: '8vp' })
  }

  validateAndSubmit(): void {
    if (this.goodQty + this.ngQty !== this.inspectQty) {
      this.showToastMsg('抽检良品 + 抽检NG 必须等于抽检数量');
      return;
    }
    if (this.ngQty > 0 && this.defectDesc.trim().length === 0) {
      this.showToastMsg('存在不良品时，请填写不良原因描述');
      return;
    }
    if (this.ngQty > 0 && this.defectTypes.length === 0) {
      this.showToastMsg('存在不良品时，请选择常见不良类型');
      return;
    }
    this.showSubmitDialog = true;
  }

  @Builder
  buildSubmitConfirm() {
    Column() {
      Column() {
        Text('确认提交').fontSize('18fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold).margin({ bottom: '12vp' })
        Text('确认提交抽检结果？').fontSize('14fp').fontColor('#6B7B8C').margin({ bottom: '20vp' })
        Row() {
          Button() { Text('取消').fontSize('15fp').fontColor('#666666').fontWeight(FontWeight.Medium) }
            .layoutWeight(1).height('44vp').borderRadius('8vp').backgroundColor('#F0F0F0').margin({ right: '10vp' })
            .onClick(() => { this.showSubmitDialog = false; })
          Button() { Text('确认提交').fontSize('15fp').fontColor('#FFFFFF').fontWeight(FontWeight.Medium) }
            .layoutWeight(1).height('44vp').borderRadius('8vp').backgroundColor('#4CAF50')
            .onClick(() => {
              this.showSubmitDialog = false;
              this.doSubmit();
            })
        }
        .width('100%')
      }
      .width('80%').padding('24vp').borderRadius('16vp').backgroundColor('#FFFFFF').shadow({ radius: 20, color: '#30000000' })
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
    .backgroundColor('#60000000').onClick(() => { this.showSubmitDialog = false; })
  }

  doSubmit(): void {
    // 计算判定：NG < 1% → 合格, 1%-3% → 条件放行, > 3% → 不合格
    const ngRate: number = this.inspectQty > 0 ? (this.ngQty / this.inspectQty) * 100 : 0;
    let result: string = '合格';
    let resultColor: string = '#4CAF50';
    if (ngRate < 1) {
      result = '合格'; resultColor = '#4CAF50';
    } else if (ngRate >= 1 && ngRate <= 3) {
      result = '条件放行'; resultColor = '#FF9800';
    } else {
      result = '不合格'; resultColor = '#F44336';
    }

    // 更新全局抽检计数
    this.updateGlobalInspectCount(result);

    // 保存抽检结果到 AppStorage
    const record: string = JSON.stringify({
      code: this.orderCode,
      productName: this.productName,
      lineName: this.lineName,
      operatorName: this.operatorName,
      planQty: this.planQty,
      type: '量产',
      inspectQty: this.inspectQty,
      goodQty: this.goodQty,
      ngQty: this.ngQty,
      result: result,
      resultColor: resultColor,
      submitTime: '2026-06-26',
    });
    AppStorage.setOrCreate('inspect_record_' + this.orderCode, record);
    // 标记工单已抽检，质检员工单页面据此移除
    AppStorage.setOrCreate('inspected_' + this.orderCode, 'true');
    // 触发工单页面刷新
    const oldTrigger: number = (AppStorage.get('inspect_trigger') as number) || 0;
    AppStorage.setOrCreate('inspect_trigger', oldTrigger + 1);

    this.showToastMsg('抽检提交成功 — ' + result);
    setTimeout(() => { this.onBack?.(); }, 800);
  }

  updateGlobalInspectCount(result: string): void {
    // 更新全局合格/条件放行/不合格计数
    const passCount: number = (AppStorage.get('global_pass_count') as number) || 0;
    const condCount: number = (AppStorage.get('global_cond_count') as number) || 0;
    const failCount: number = (AppStorage.get('global_fail_count') as number) || 0;
    if (result === '合格') {
      AppStorage.setOrCreate('global_pass_count', passCount + 1);
    } else if (result === '条件放行') {
      AppStorage.setOrCreate('global_cond_count', condCount + 1);
    } else {
      AppStorage.setOrCreate('global_fail_count', failCount + 1);
    }
    // 触发质检报告刷新
    const oldReportTrigger: number = (AppStorage.get('report_trigger') as number) || 0;
    AppStorage.setOrCreate('report_trigger', oldReportTrigger + 1);
  }

  showToastMsg(msg: string): void {
    this.toastMsg = msg;
    this.showToast = true;
    setTimeout(() => { this.showToast = false; }, 2000);
  }
}
