import { CopyWorkOrderViewModel } from '../viewModel/CopyWorkOrderViewModel';
import { WorkOrder } from 'utils';

@ComponentV2
export struct CopyWorkOrderView {
  @Param viewModel: CopyWorkOrderViewModel = new CopyWorkOrderViewModel();
  @Param sourceOrder: WorkOrder | null = null;
  @Event onSaved?: () => void;
  @Event onBack?: () => void;
  private navStack: NavPathStack | null = null;

  aboutToAppear(): void {
    this.navStack = AppStorage.get('navPathStack') as NavPathStack;
    if (this.sourceOrder) {
      this.viewModel.init(this.sourceOrder);
    }
  }

  build() {
    Column() {
      this.buildTopBar()
      Scroll() {
        Column() {
          this.buildSourceTag()
          this.buildFormCard()
          this.buildProcessCard()
          Blank().height('24vp')
        }
        .width('100%')
        .padding({ left: '16vp', right: '16vp' })
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
      .backgroundColor('#E8EDF2')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#E8EDF2')
  }

  // ========== 顶部栏 ==========
  @Builder
  buildTopBar() {
    Row() {
      Row() {
        Text('‹')
          .fontSize('22fp')
          .fontColor('#1A2B3C')
          .fontWeight(FontWeight.Bold)
      }
      .width('34vp').height('34vp').borderRadius('17vp')
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
      .onClick(() => {
        if (this.navStack) this.navStack.pop();
        if (this.onBack) this.onBack();
      })

      Column() {
        Text('复制新增')
          .fontSize('18fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold)
        Text('除工单号外，自动带出原工单信息')
          .fontSize('11fp').fontColor('#999999').margin({ top: '1vp' })
      }
      .alignItems(HorizontalAlign.Start).layoutWeight(1).margin({ left: '10vp' })

      Button() {
        if (this.viewModel.isLoading) {
          LoadingProgress().width('18vp').height('18vp').color('#FFFFFF')
        } else {
          Text('保存').fontSize('13fp').fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
        }
      }
      .height('32vp')
      .padding({ left: '14vp', right: '14vp' })
      .borderRadius('6vp')
      .backgroundColor('#007DFF')
      .enabled(!this.viewModel.isLoading)
      .onClick(async () => {
        const ok: boolean = await this.viewModel.save();
        if (ok) {
          if (this.navStack) this.navStack.pop();
          if (this.onSaved) this.onSaved();
        }
      })
    }
    .width('100%')
    .padding({ left: '14vp', right: '14vp', top: '12vp', bottom: '10vp' })
    .backgroundColor('#E8EDF2')
  }

  // ========== 来源标签 ==========
  @Builder
  buildSourceTag() {
    Row() {
      Text('📋').fontSize('14fp')
      Text(' 复制来源：' + this.viewModel.sourceCode)
        .fontSize('13fp').fontColor('#007DFF').fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .padding({ left: '12vp', right: '12vp', top: '10vp', bottom: '10vp' })
    .borderRadius('8vp')
    .backgroundColor('#EBF5FF')
    .margin({ top: '12vp', bottom: '10vp' })
  }

  // ========== 工单信息表单 ==========
  @Builder
  buildFormCard() {
    Column() {
      Text('工单信息')
        .fontSize('15fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold)
        .width('100%').margin({ bottom: '16vp' })

      // Row 1: 新工单号 | 产品编码
      Row() {
        Column() { this.buildReadonlyField('新工单号', this.viewModel.newCode) }.layoutWeight(1)
        Blank().width('12vp')
        Column() { this.buildReadonlyField('产品编码', this.viewModel.productCode) }.layoutWeight(1)
      }
      .width('100%').margin({ bottom: '14vp' })

      // Row 2: 工单类型 | 计划数量
      Row() {
        Column() { this.buildTypePicker() }.layoutWeight(1)
        Blank().width('12vp')
        Column() { this.buildQtyInput() }.layoutWeight(1)
      }
      .width('100%').margin({ bottom: '14vp' })

      // Row 3: 产品名称 | 资源
      Row() {
        Column() { this.buildReadonlyField('产品名称', this.viewModel.productName) }.layoutWeight(1)
        Blank().width('12vp')
        Column() { this.buildLinePicker() }.layoutWeight(1)
      }
      .width('100%').margin({ bottom: '14vp' })

      // Row 4: 计划开始 | 计划完成
      Row() {
        Column() { this.buildDateField('计划开始', this.viewModel.planStartTime,
          (v: string) => { this.viewModel.planStartTime = v; }) }.layoutWeight(1)
        Blank().width('12vp')
        Column() { this.buildDateField('计划完成', this.viewModel.planEndTime,
          (v: string) => { this.viewModel.planEndTime = v; }) }.layoutWeight(1)
      }
      .width('100%').margin({ bottom: '14vp' })

      if (this.viewModel.errorMessage) {
        Text(this.viewModel.errorMessage)
          .fontSize('12fp').fontColor('#F44336')
          .width('100%').margin({ top: '10vp' }).textAlign(TextAlign.Center)
      }
    }
    .width('100%')
    .padding('16vp')
    .borderRadius('10vp')
    .backgroundColor('#FFFFFF')
    .margin({ bottom: '10vp' })
  }

  // ========== 只读字段 ==========
  @Builder
  buildReadonlyField(label: string, value: string) {
    Column() {
      Text(label)
        .fontSize('11fp').fontColor('#999999').width('100%').margin({ bottom: '5vp' })
      Text(value)
        .fontSize('13fp').fontColor('#1A2B3C')
        .width('100%').height('38vp')
        .padding({ left: '10vp' })
        .borderRadius('6vp')
        .backgroundColor('#F5F6F8')
        .border({ width: '1vp', color: '#E8EAED' })
        .textAlign(TextAlign.Start)
    }
    .width('100%')
  }

  // ========== 工单类型选择 ==========
  @Builder
  buildTypePicker() {
    Column() {
      Text('工单类型')
        .fontSize('11fp').fontColor('#999999').width('100%').margin({ bottom: '5vp' })
      Row() {
        ForEach(this.viewModel.orderTypes, (t: string) => {
          Text(t)
            .fontSize('13fp')
            .fontColor(this.viewModel.orderType === t ? '#FFFFFF' : '#666666')
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
            .height('34vp')
            .borderRadius('6vp')
            .backgroundColor(this.viewModel.orderType === t ? '#007DFF' : '#F0F1F3')
            .textAlign(TextAlign.Center)
            .margin({ right: t === '量产' ? '6vp' : 0 })
            .onClick(() => { this.viewModel.orderType = t; })
        })
      }
      .width('100%')
    }
    .width('100%')
  }

  // ========== 计划数量输入 ==========
  @Builder
  buildQtyInput() {
    Column() {
      Text('计划数量')
        .fontSize('11fp').fontColor('#999999').width('100%').margin({ bottom: '5vp' })
      TextInput({ text: this.viewModel.planQty.toString(), placeholder: '0' })
        .fontSize('13fp').fontColor('#1A2B3C')
        .backgroundColor('#FFFFFF')
        .borderRadius('6vp').height('38vp').width('100%')
        .border({ width: '1vp', color: '#E0E5EB' })
        .padding({ left: '10vp' })
        .type(InputType.Number)
        .onChange((v: string) => {
          const n: number = parseInt(v);
          if (n > 0) this.viewModel.planQty = n;
        })
    }
    .width('100%')
  }

  // ========== 产线选择 ==========
  @Builder
  buildLinePicker() {
    Column() {
      Text('资源')
        .fontSize('11fp').fontColor('#999999').width('100%').margin({ bottom: '5vp' })
      Select([
        { value: '柔性组装线' },
        { value: '智能组装线' },
        { value: 'SMT产线' },
        { value: '机加工线' },
      ])
        .selected(this.viewModel.lineId - 1)
        .width('100%')
        .height('38vp')
        .borderRadius('6vp')
        .border({ width: '1vp', color: '#E0E5EB' })
        .onSelect((index: number) => {
          this.viewModel.selectLine(index);
        })
    }
    .width('100%')
  }

  // ========== 日期字段 ==========
  @Builder
  buildDateField(label: string, value: string, onChange: (v: string) => void) {
    Column() {
      Text(label)
        .fontSize('11fp').fontColor('#999999').width('100%').margin({ bottom: '5vp' })
      TextInput({ text: value, placeholder: 'yyyy-MM-dd HH:mm' })
        .fontSize('12fp').fontColor('#1A2B3C')
        .backgroundColor('#FFFFFF')
        .borderRadius('6vp').height('38vp').width('100%')
        .border({ width: '1vp', color: '#E0E5EB' })
        .padding({ left: '10vp' })
        .onChange(onChange)
    }
    .width('100%')
  }

  // ========== 工艺路线 ==========
  @Builder
  buildProcessCard() {
    Column() {
      Row() {
        Text('工艺路线')
          .fontSize('15fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold)
        Blank()
        Text('只读')
          .fontSize('10fp').fontColor('#999999')
          .padding({ left: '8vp', right: '8vp', top: '2vp', bottom: '2vp' })
          .borderRadius('4vp')
          .backgroundColor('#F0F1F3')
      }
      .width('100%').margin({ bottom: '4vp' })

      Text('复制原工单的工艺路线，不支持编辑')
        .fontSize('11fp').fontColor('#999999')
        .width('100%').margin({ bottom: '14vp' })

      Column() {
        ForEach(this.viewModel.getProcessSteps(), (step: string, idx: number) => {
          Row() {
            Column() {
              Text((idx + 1).toString())
                .fontSize('11fp').fontColor('#FFFFFF').fontWeight(FontWeight.Bold)
            }
            .width('20vp').height('20vp').borderRadius('10vp')
            .backgroundColor('#007DFF')
            .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
            .margin({ right: '10vp' })

            Text(step)
              .fontSize('13fp').fontColor('#1A2B3C')
              .layoutWeight(1)
          }
          .width('100%')
          .height('32vp')
          .alignItems(VerticalAlign.Center)
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding('16vp')
    .borderRadius('10vp')
    .backgroundColor('#FFFFFF')
  }
}
