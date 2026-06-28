import { CreateWorkOrderViewModel, ProductOption, LineOption } from '../viewModel/CreateWorkOrderViewModel';

@ComponentV2
export struct CreateWorkOrderView {
  @Param viewModel: CreateWorkOrderViewModel = new CreateWorkOrderViewModel();
  @Event onSaved?: () => void;
  @Event onBack?: () => void;
  private navStack: NavPathStack | null = null;

  aboutToAppear(): void {
    this.navStack = AppStorage.get('navPathStack') as NavPathStack;
    this.viewModel.init();
  }

  build() {
    Column() {
      this.buildTopBar()
      Scroll() {
        Column() {
          this.buildWorkOrderForm()
          this.buildProcessRouteSection()
          this.buildValidationRulesSection()
          Blank().height('24vp')
        }
        .width('100%')
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)

      this.buildFooterSection()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder
  buildTopBar() {
    Row() {
      Column() {
        Text('‹')
          .fontSize('24fp')
          .fontColor('#64748B')
          .fontWeight(FontWeight.Bold)
      }
      .width('42vp')
      .height('42vp')
      .backgroundColor('#FFFFFF')
      .borderRadius('21vp')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .shadow({ radius: 8, color: '#12000000', offsetY: 2 })
      .onClick(() => {
        if (this.navStack) this.navStack.pop();
        if (this.onBack) this.onBack();
      })

      Column() {
        Text('创建工单')
          .fontSize('22fp')
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
        Text('创建新的生产工单')
          .fontSize('13fp')
          .fontColor('#94A3B8')
          .margin({ top: '4vp' })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: '14vp' })
    }
    .width('100%')
    .padding({ left: '14vp', right: '14vp', top: '18vp', bottom: '10vp' })
  }

  @Builder
  buildWorkOrderForm() {
    Column() {
      Text('工单信息')
        .fontSize('16fp')
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A2B3C')
        .width('100%')
        .margin({ bottom: '12vp' })

      this.buildFormItem('工单号', this.viewModel.newCode, true)
      
      Column() {
        Text('工单类型 *')
          .fontSize('13fp')
          .fontColor('#64748B')
          .width('100%')
          .margin({ bottom: '6vp' })
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.viewModel.orderTypes, (item: string) => {
            Text(item)
              .fontSize('13fp')
              .fontColor(this.viewModel.orderType === item ? '#FFFFFF' : '#475569')
              .padding({ left: '14vp', right: '14vp', top: '8vp', bottom: '8vp' })
              .backgroundColor(this.viewModel.orderType === item ? '#0EA5E9' : '#F1F5F9')
              .borderRadius('18vp')
              .margin({ right: '8vp', bottom: '8vp' })
              .onClick(() => {
                this.viewModel.orderType = item;
              })
          }, (item: string) => item)
        }
        .width('100%')
      }
      .width('100%')
      .margin({ top: '12vp' })

      Column() {
        Text('选择产线 *')
          .fontSize('13fp')
          .fontColor('#64748B')
          .width('100%')
          .margin({ bottom: '6vp' })
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.viewModel.lineOptions, (line: LineOption, index: number) => {
            Text(line.name)
              .fontSize('13fp')
              .fontColor(this.viewModel.lineId === line.id ? '#FFFFFF' : '#475569')
              .padding({ left: '14vp', right: '14vp', top: '8vp', bottom: '8vp' })
              .backgroundColor(this.viewModel.lineId === line.id ? '#0EA5E9' : '#F1F5F9')
              .borderRadius('18vp')
              .margin({ right: '8vp', bottom: '8vp' })
              .onClick(() => {
                this.viewModel.selectLine(index);
              })
          }, (line: LineOption) => line.id.toString())
        }
        .width('100%')
      }
      .width('100%')
      .margin({ top: '12vp' })

      Column() {
        Text('选择产品 *')
          .fontSize('13fp')
          .fontColor('#64748B')
          .width('100%')
          .margin({ bottom: '6vp' })
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.viewModel.productOptions, (product: ProductOption, index: number) => {
            Text(product.name)
              .fontSize('13fp')
              .fontColor(this.viewModel.productId === product.id ? '#FFFFFF' : '#475569')
              .padding({ left: '14vp', right: '14vp', top: '8vp', bottom: '8vp' })
              .backgroundColor(this.viewModel.productId === product.id ? '#0EA5E9' : '#F1F5F9')
              .borderRadius('18vp')
              .margin({ right: '8vp', bottom: '8vp' })
              .onClick(() => {
                this.viewModel.selectProduct(index);
              })
          }, (product: ProductOption) => product.id.toString())
        }
        .width('100%')
      }
      .width('100%')
      .margin({ top: '12vp' })

      this.buildFormItem('产品编码', this.viewModel.productCode || '选择产品后自动填入', true)
      
      Column() {
        Text('计划数量 *')
          .fontSize('13fp')
          .fontColor('#64748B')
          .width('100%')
          .margin({ bottom: '6vp' })
        TextInput({ placeholder: '请输入整数数量', text: this.viewModel.planQty.toString() })
          .width('100%')
          .height('44vp')
          .backgroundColor('#F5F7FA')
          .borderRadius('12vp')
          .padding({ left: '14vp', right: '14vp' })
          .fontSize('15fp')
          .type(InputType.Number)
          .onChange((value: string) => {
            const n: number = parseInt(value);
            if (!isNaN(n) && n > 0) this.viewModel.planQty = n;
          })
      }
      .width('100%')
      .margin({ top: '12vp' })

      Row() {
        Column() {
          Text('计划开始时间 *')
            .fontSize('13fp')
            .fontColor('#64748B')
            .width('100%')
            .margin({ bottom: '6vp' })
          Row() {
            Text(this.viewModel.planStartTime || '年/月/日 --:--')
              .fontSize('15fp')
              .fontColor(this.viewModel.planStartTime ? '#1A2B3C' : '#9AA5B1')
              .layoutWeight(1)
            Text('📅')
              .fontSize('16fp')
          }
          .width('100%')
          .height('44vp')
          .backgroundColor('#F5F7FA')
          .borderRadius('12vp')
          .padding({ left: '14vp', right: '14vp' })
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            DatePickerDialog.show({
              start: new Date('2020-01-01'),
              end: new Date('2030-12-31'),
              selected: this.viewModel.planStartTime ? new Date(this.viewModel.planStartTime.split(' ')[0]) : new Date(),
              onAccept: (value: DatePickerResult) => {
                const year = value.year;
                const month = (value.month || 0) + 1;
                const day = value.day;
                const dateStr = `${year}-${month.toString().padStart(2, '0')}-${day?.toString().padStart(2, '0')}`;
                this.viewModel.planStartTime = `${dateStr} 08:00`;
              }
            })
          })
        }
        .layoutWeight(1)

        Blank().width('12vp')

        Column() {
          Text('计划结束时间 *')
            .fontSize('13fp')
            .fontColor('#64748B')
            .width('100%')
            .margin({ bottom: '6vp' })
          Row() {
            Text(this.viewModel.planEndTime || '年/月/日 --:--')
              .fontSize('15fp')
              .fontColor(this.viewModel.planEndTime ? '#1A2B3C' : '#9AA5B1')
              .layoutWeight(1)
            Text('📅')
              .fontSize('16fp')
          }
          .width('100%')
          .height('44vp')
          .backgroundColor('#F5F7FA')
          .borderRadius('12vp')
          .padding({ left: '14vp', right: '14vp' })
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            DatePickerDialog.show({
              start: new Date('2020-01-01'),
              end: new Date('2030-12-31'),
              selected: this.viewModel.planEndTime ? new Date(this.viewModel.planEndTime.split(' ')[0]) : new Date(),
              onAccept: (value: DatePickerResult) => {
                const year = value.year;
                const month = (value.month || 0) + 1;
                const day = value.day;
                const dateStr = `${year}-${month.toString().padStart(2, '0')}-${day?.toString().padStart(2, '0')}`;
                this.viewModel.planEndTime = `${dateStr} 18:00`;
              }
            })
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ top: '12vp' })

      if (this.viewModel.errorMessage) {
        Text(this.viewModel.errorMessage)
          .fontSize('12fp')
          .fontColor('#F44336')
          .width('100%')
          .margin({ top: '12vp' })
          .textAlign(TextAlign.Center)
      }
    }
    .width('100%')
    .padding('16vp')
    .backgroundColor('#FFFFFF')
    .borderRadius('16vp')
    .margin({ left: '16vp', right: '16vp', top: '12vp' })
  }

  @Builder
  buildFormItem(label: string, value: string, disabled: boolean) {
    Column() {
      Text(label + (disabled ? ' (自动生成)' : ''))
        .fontSize('13fp')
        .fontColor('#64748B')
        .width('100%')
        .margin({ bottom: '6vp' })
      Row() {
          Text(value)
            .fontSize('15fp')
            .fontColor(disabled ? '#9AA5B1' : '#1A2B3C')
            .layoutWeight(1)
        }
        .width('100%')
        .height('44vp')
        .backgroundColor('#F5F7FA')
        .borderRadius('12vp')
        .padding({ left: '14vp', right: '14vp' })
        .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .margin({ top: '12vp' })
  }

  @Builder
  buildProcessRouteSection() {
    Column() {
      Text('工艺路线')
        .fontSize('16fp')
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A2B3C')
        .width('100%')
        .margin({ bottom: '12vp' })

      if (!this.viewModel.productCode) {
        Column() {
          Text('选择产品编码后自动带出')
            .fontSize('13fp')
            .fontColor('#9AA5B1')
            .margin({ bottom: '8vp' })
          Text('请先选择产品编码')
            .fontSize('14fp')
            .fontColor('#F97316')
        }
        .width('100%')
        .height('100vp')
        .backgroundColor('#F5F7FA')
        .borderRadius('12vp')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Column() {
          Text('标准组装工艺')
            .fontSize('14fp')
            .fontColor('#1A2B3C')
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .margin({ bottom: '12vp' })
            
          Row() {
            this.buildProcessStep('1', '贴片', true)
            this.buildProcessLine()
            this.buildProcessStep('2', '组装', false)
            this.buildProcessLine()
            this.buildProcessStep('3', '测试', false)
            this.buildProcessLine()
            this.buildProcessStep('4', '包装', false)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%')
        .padding('16vp')
        .backgroundColor('#F5F7FA')
        .borderRadius('12vp')
      }
    }
    .width('100%')
    .padding('16vp')
    .backgroundColor('#FFFFFF')
    .borderRadius('16vp')
    .margin({ left: '16vp', right: '16vp', top: '12vp' })
  }

  @Builder
  buildProcessStep(step: string, name: string, isFirst: boolean) {
    Column() {
      Text(step)
        .fontSize('12fp')
        .fontColor('#FFFFFF')
        .width('24vp')
        .height('24vp')
        .borderRadius('12vp')
        .backgroundColor('#0EA5E9')
        .textAlign(TextAlign.Center)
        .lineHeight('24vp')
      Text(name)
        .fontSize('12fp')
        .fontColor('#1A2B3C')
        .margin({ top: '6vp' })
    }
  }

  @Builder
  buildProcessLine() {
    Row()
      .layoutWeight(1)
      .height('2vp')
      .backgroundColor('#E2E8F0')
      .margin({ bottom: '20vp', left: '4vp', right: '4vp' })
  }

  @Builder
  buildValidationRulesSection() {
    Column() {
      Text('保存校验规则')
        .fontSize('14fp')
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A2B3C')
        .width('100%')
        .margin({ bottom: '8vp' })

      Text('• 带 * 为必填项。')
        .fontSize('12fp')
        .fontColor('#64748B')
        .width('100%')
        .margin({ bottom: '4vp' })
      Text('• 计划数量必须为正整数。')
        .fontSize('12fp')
        .fontColor('#64748B')
        .width('100%')
        .margin({ bottom: '4vp' })
      Text('• 计划开始时间需大于等于当前时间。')
        .fontSize('12fp')
        .fontColor('#64748B')
        .width('100%')
        .margin({ bottom: '4vp' })
      Text('• 计划结束时间需大于计划开始时间。')
        .fontSize('12fp')
        .fontColor('#64748B')
        .width('100%')
    }
    .width('100%')
    .padding('16vp')
    .backgroundColor('#FFFFFF')
    .borderRadius('16vp')
    .margin({ left: '16vp', right: '16vp', top: '12vp' })
  }

  @Builder
  buildInputRow(label: string, value: string, editable: boolean) {
    Column() {
      Text(label)
        .fontSize('13fp')
        .fontColor('#64748B')
        .width('100%')
      Text(value)
        .fontSize('14fp')
        .fontColor(editable ? '#111827' : '#475569')
        .width('100%')
        .margin({ top: '8vp' })
    }
    .width('100%')
    .padding('12vp')
    .backgroundColor('#F8FAFC')
    .borderRadius('12vp')
    .margin({ top: '14vp' })
  }

  @Builder
  buildFooterSection() {
    Column() {
      Button() {
        if (this.viewModel.isLoading) {
          LoadingProgress().width('24vp').height('24vp').color('#FFFFFF')
        } else {
          Text('创建工单').fontSize('15fp').fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
        }
      }
      .width('100%')
      .height('44vp')
      .backgroundColor('#111827')
      .borderRadius('12vp')
      .enabled(!this.viewModel.isLoading)
      .onClick(async () => {
        const ok = await this.viewModel.save();
        if (ok) {
          if (this.navStack) this.navStack.pop();
          if (this.onSaved) this.onSaved();
        }
      })
    }
    .width('100%')
    .padding('20vp')
    .backgroundColor('#FFFFFF')
    .borderRadius('24vp')
    .shadow({ radius: 16, color: '#12000000', offsetY: 4 })
    .margin({ left: '12vp', right: '12vp', top: '14vp' })
  }
}