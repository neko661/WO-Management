import { LeaderCreateWorkOrderViewModel, ProductCodeOption } from '../viewModel/LeaderCreateWorkOrderViewModel';

@ComponentV2
export struct LeaderCreateWorkOrderView {
  @Param viewModel: LeaderCreateWorkOrderViewModel = new LeaderCreateWorkOrderViewModel();
  @Event onSaved?: () => void;
  @Event onBack?: () => void;
  private navStack: NavPathStack | null = null;

  @Local showTypePicker: boolean = false;
  @Local showWorkshopPicker: boolean = false;
  @Local showResourcePicker: boolean = false;
  @Local showProductPicker: boolean = false;

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

      this.buildBottomButton()

      this.buildTypePicker()
      this.buildWorkshopPicker()
      this.buildResourcePicker()
      this.buildProductPicker()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder
  buildTopBar() {
    Row() {
      Row() {
        Text('‹')
          .fontSize('28fp')
          .fontColor('#64748B')
      }
      .width('44vp')
      .height('44vp')
      .borderRadius('22vp')
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        if (this.navStack) this.navStack.pop();
        if (this.onBack) this.onBack();
      })

      Column() {
        Text('添加工单')
          .fontSize('24fp')
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A2B3C')
        Text('填写工单信息并创建')
          .fontSize('13fp')
          .fontColor('#9AA5B1')
          .margin({ top: '4vp' })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: '12vp' })
    }
    .width('100%')
    .padding({ left: '16vp', right: '16vp', top: '16vp', bottom: '12vp' })
    .backgroundColor('#F5F7FA')
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

      this.buildFormItem('工单号', this.viewModel.woCode, true)
      this.buildFormSelector('工单类型', this.viewModel.orderType || '请选择工单类型', () => { this.showTypePicker = true; })
      
      Row() {
        Column() {
          Text('车间')
            .fontSize('13fp')
            .fontColor('#64748B')
            .width('100%')
            .margin({ bottom: '6vp' })
          Row() {
            Text(this.viewModel.workshop || '请选择车间')
              .fontSize('15fp')
              .fontColor(this.viewModel.workshop ? '#1A2B3C' : '#9AA5B1')
              .layoutWeight(1)
            Text('▼')
              .fontSize('12fp')
              .fontColor('#9AA5B1')
          }
          .width('100%')
          .height('44vp')
          .backgroundColor('#FFFFFF')
          .borderRadius('12vp')
          .borderWidth(this.viewModel.workshop ? '2vp' : '0vp')
          .borderColor('#F97316')
          .padding({ left: '14vp', right: '14vp' })
          .alignItems(VerticalAlign.Center)
          .onClick(() => { this.showWorkshopPicker = true; })
        }
        .layoutWeight(1)

        Blank().width('12vp')

        Column() {
          Text('资源')
            .fontSize('13fp')
            .fontColor('#64748B')
            .width('100%')
            .margin({ bottom: '6vp' })
          Row() {
            Text(this.viewModel.resource || '请选择资源')
              .fontSize('15fp')
              .fontColor(this.viewModel.resource ? '#1A2B3C' : '#9AA5B1')
              .layoutWeight(1)
            Text('▼')
              .fontSize('12fp')
              .fontColor('#9AA5B1')
          }
          .width('100%')
          .height('44vp')
          .backgroundColor('#FFFFFF')
          .borderRadius('12vp')
          .borderWidth(this.viewModel.resource ? '2vp' : '0vp')
          .borderColor('#F97316')
          .padding({ left: '14vp', right: '14vp' })
          .alignItems(VerticalAlign.Center)
          .onClick(() => { this.showResourcePicker = true; })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ top: '12vp' })

      this.buildFormSelector('产品编码', this.viewModel.productCode || '请选择产品编码', () => { this.showProductPicker = true; })
      this.buildFormItem('产品名称', this.viewModel.productName || '选择产品编码后自动填入', true)
      this.buildFormInput('计划数量', this.viewModel.planQty, '请输入整数数量', (v: string) => { this.viewModel.planQty = v; })

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
          .backgroundColor('#FFFFFF')
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
          .backgroundColor('#FFFFFF')
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
  buildFormSelector(label: string, value: string, onClick: () => void) {
    Column() {
      Text(label + ' *')
        .fontSize('13fp')
        .fontColor('#64748B')
        .width('100%')
        .margin({ bottom: '6vp' })
      Row() {
        Text(value)
          .fontSize('15fp')
          .fontColor(value !== '请选择工单类型' && value !== '请选择产品编码' ? '#1A2B3C' : '#9AA5B1')
          .layoutWeight(1)
        Text('▼')
          .fontSize('12fp')
          .fontColor('#9AA5B1')
      }
      .width('100%')
      .height('44vp')
      .backgroundColor('#FFFFFF')
      .borderRadius('12vp')
      .borderWidth((value !== '请选择工单类型' && value !== '请选择产品编码') ? '2vp' : '0vp')
      .borderColor('#F97316')
      .padding({ left: '14vp', right: '14vp' })
      .alignItems(VerticalAlign.Center)
      .onClick(onClick)
    }
    .width('100%')
    .margin({ top: '12vp' })
  }

  @Builder
  buildFormInput(label: string, value: string, placeholder: string, onChange: (v: string) => void) {
    Column() {
      Text(label + ' *')
        .fontSize('13fp')
        .fontColor('#64748B')
        .width('100%')
        .margin({ bottom: '6vp' })
      TextInput({ placeholder: placeholder, text: value })
        .width('100%')
        .height('44vp')
        .backgroundColor('#FFFFFF')
        .borderRadius('12vp')
        .padding({ left: '14vp', right: '14vp' })
        .fontSize('15fp')
        .fontColor('#1A2B3C')
        .placeholderColor('#9AA5B1')
        .type(InputType.Number)
        .onChange(onChange)
    }
    .width('100%')
    .margin({ top: '12vp' })
  }

  @Builder
  buildBottomButton() {
    Button() {
      Row() {
        Text('+')
          .fontSize('20fp')
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .margin({ right: '6vp' })
        Text('创建工单')
          .fontSize('18fp')
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
      }
    }
    .width('100%')
    .height('56vp')
    .backgroundColor('#0D9488')
    .borderRadius('16vp')
    .margin({ left: '16vp', right: '16vp', bottom: '24vp' })
    .onClick(async () => {
      const ok = await this.viewModel.save();
      if (ok) {
        if (this.navStack) this.navStack.pop();
        if (this.onSaved) this.onSaved();
      }
    })
  }

  @Builder
  buildTypePicker() {
    if (this.showTypePicker) {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#60000000')
          .onClick(() => { this.showTypePicker = false; })

        Column() {
          Row() {
            Text('取消')
              .fontSize('16fp')
              .fontColor('#64748B')
              .layoutWeight(1)
              .onClick(() => { this.showTypePicker = false; })
            Text('工单类型')
              .fontSize('18fp')
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A2B3C')
            Text('确定')
              .fontSize('16fp')
              .fontColor('#0D9488')
              .layoutWeight(1)
              .textAlign(TextAlign.End)
              .onClick(() => { this.showTypePicker = false; })
          }
          .width('100%')
          .padding({ left: '16vp', right: '16vp', top: '16vp', bottom: '12vp' })

          ForEach(this.viewModel.orderTypes, (item: string) => {
            Row() {
              Text(item)
                .fontSize('16fp')
                .fontColor(this.viewModel.orderType === item ? '#0D9488' : '#1A2B3C')
                .layoutWeight(1)
              if (this.viewModel.orderType === item) {
                Text('✓')
                  .fontSize('20fp')
                  .fontColor('#0D9488')
              }
            }
            .width('100%')
            .height('52vp')
            .padding({ left: '16vp', right: '16vp' })
            .alignItems(VerticalAlign.Center)
            .onClick(() => { this.viewModel.orderType = item; })
          })
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius({ topLeft: '24vp', topRight: '24vp' })
        .alignSelf(ItemAlign.End)
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  buildWorkshopPicker() {
    if (this.showWorkshopPicker) {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#60000000')
          .onClick(() => { this.showWorkshopPicker = false; })

        Column() {
          Row() {
            Text('取消')
              .fontSize('16fp')
              .fontColor('#64748B')
              .layoutWeight(1)
              .onClick(() => { this.showWorkshopPicker = false; })
            Text('车间')
              .fontSize('18fp')
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A2B3C')
            Text('确定')
              .fontSize('16fp')
              .fontColor('#0D9488')
              .layoutWeight(1)
              .textAlign(TextAlign.End)
              .onClick(() => { this.showWorkshopPicker = false; })
          }
          .width('100%')
          .padding({ left: '16vp', right: '16vp', top: '16vp', bottom: '12vp' })

          ForEach(this.viewModel.workshops, (item: string) => {
            Row() {
              Text(item)
                .fontSize('16fp')
                .fontColor(this.viewModel.workshop === item ? '#0D9488' : '#1A2B3C')
                .layoutWeight(1)
              if (this.viewModel.workshop === item) {
                Text('✓')
                  .fontSize('20fp')
                  .fontColor('#0D9488')
              }
            }
            .width('100%')
            .height('52vp')
            .padding({ left: '16vp', right: '16vp' })
            .alignItems(VerticalAlign.Center)
            .onClick(() => { this.viewModel.workshop = item; })
          })
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius({ topLeft: '24vp', topRight: '24vp' })
        .alignSelf(ItemAlign.End)
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  buildResourcePicker() {
    if (this.showResourcePicker) {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#60000000')
          .onClick(() => { this.showResourcePicker = false; })

        Column() {
          Row() {
            Text('取消')
              .fontSize('16fp')
              .fontColor('#64748B')
              .layoutWeight(1)
              .onClick(() => { this.showResourcePicker = false; })
            Text('资源')
              .fontSize('18fp')
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A2B3C')
            Text('确定')
              .fontSize('16fp')
              .fontColor('#0D9488')
              .layoutWeight(1)
              .textAlign(TextAlign.End)
              .onClick(() => { this.showResourcePicker = false; })
          }
          .width('100%')
          .padding({ left: '16vp', right: '16vp', top: '16vp', bottom: '12vp' })

          ForEach(this.viewModel.resources, (item: string) => {
            Row() {
              Text(item)
                .fontSize('16fp')
                .fontColor(this.viewModel.resource === item ? '#0D9488' : '#1A2B3C')
                .layoutWeight(1)
              if (this.viewModel.resource === item) {
                Text('✓')
                  .fontSize('20fp')
                  .fontColor('#0D9488')
              }
            }
            .width('100%')
            .height('52vp')
            .padding({ left: '16vp', right: '16vp' })
            .alignItems(VerticalAlign.Center)
            .onClick(() => { this.viewModel.resource = item; })
          })
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius({ topLeft: '24vp', topRight: '24vp' })
        .alignSelf(ItemAlign.End)
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  buildProductPicker() {
    if (this.showProductPicker) {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#60000000')
          .onClick(() => { this.showProductPicker = false; })

        Column() {
          Row() {
            Text('取消')
              .fontSize('16fp')
              .fontColor('#64748B')
              .layoutWeight(1)
              .onClick(() => { this.showProductPicker = false; })
            Text('产品编码')
              .fontSize('18fp')
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A2B3C')
            Text('确定')
              .fontSize('16fp')
              .fontColor('#0D9488')
              .layoutWeight(1)
              .textAlign(TextAlign.End)
              .onClick(() => { this.showProductPicker = false; })
          }
          .width('100%')
          .padding({ left: '16vp', right: '16vp', top: '16vp', bottom: '12vp' })

          ForEach(this.viewModel.productCodes, (item: ProductCodeOption) => {
            Column() {
              Row() {
                Text(item.code)
                  .fontSize('16fp')
                  .fontColor(this.viewModel.productCode === item.code ? '#0D9488' : '#1A2B3C')
                  .layoutWeight(1)
                if (this.viewModel.productCode === item.code) {
                  Text('✓')
                    .fontSize('20fp')
                    .fontColor('#0D9488')
                }
              }
              Text(item.name)
                .fontSize('13fp')
                .fontColor('#64748B')
                .width('100%')
                .margin({ top: '4vp' })
            }
            .width('100%')
            .height('60vp')
            .padding({ left: '16vp', right: '16vp' })
            .justifyContent(FlexAlign.Center)
            .onClick(() => { this.viewModel.selectProductCode(item.code); })
          })
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius({ topLeft: '24vp', topRight: '24vp' })
        .alignSelf(ItemAlign.End)
      }
      .width('100%')
      .height('100%')
    }
  }
}
