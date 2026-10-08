import { ProductionLineDetailViewModel, SelectTaskItem } from '../viewModel/ProductionLineDetailViewModel';
import { LineDetailFull, WorkstationDetail } from '../model/DataTypes';

@ComponentV2
export struct ProductionLineDetailView {
  @Param viewModel: ProductionLineDetailViewModel = new ProductionLineDetailViewModel();
  @Param lineId: number = 1;
  @Param role: string = '';
  @Param cardPadding: number = 16;
  @Event onBack?: () => void;
  @Event onStationClick?: (stationId: number) => void;

  aboutToAppear(): void {
    this.viewModel.init(this.lineId, this.role);
  }

  build() {
    Stack() {
      Column() {
        this.buildHeader()

        Scroll() {
          Column() {
            if (this.viewModel.lineDetail) {
              this.buildLineStatusCard(this.viewModel.lineDetail)
              this.buildTaskSelection()
              this.buildStatsRow(this.viewModel.lineDetail)
              this.buildWorkstationGrid()
              this.buildActionSection()
            }
            Blank().height('55vp')
          }
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
        .align(Alignment.TopStart)
        .backgroundColor('#E8EDF2')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#E8EDF2')

      if (this.viewModel.showConfirmDialog) {
        this.buildConfirmDialog()
      }

      if (this.viewModel.showExceptionDialog) {
        this.buildExceptionDialog()
      }

      if (this.viewModel.showToast) {
        this.buildToast()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildConfirmDialog() {
    Column() {
      Column() {
        Text('确认操作')
          .fontSize('18fp')
          .fontColor('#1A2B3C')
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: '12vp' })

        Text('确认是否执行当前整线操作？')
          .fontSize('14fp')
          .fontColor('#6B7B8C')
          .margin({ bottom: '6vp' })

        Text(this.viewModel.confirmStationName + ' → ' + this.viewModel.getConfirmActionLabel())
          .fontSize('15fp')
          .fontColor('#1A2B3C')
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: '20vp' })

        Row() {
          Button('取消')
            .layoutWeight(1)
            .height('44vp')
            .fontColor('#666666')
            .backgroundColor('#F0F0F0')
            .borderRadius('8vp')
            .margin({ right: '10vp' })
            .onClick(() => {
              this.viewModel.cancelAction();
            })

          Button('确认')
            .layoutWeight(1)
            .height('44vp')
            .fontColor('#FFFFFF')
            .backgroundColor('#007DFF')
            .borderRadius('8vp')
            .onClick(() => {
              this.viewModel.confirmActionChange();
            })
        }
        .width('100%')
      }
      .width('80%')
      .padding('24vp')
      .borderRadius('16vp')
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 20, color: '#30000000' })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#60000000')
  }

  @Builder
  buildExceptionDialog() {
    Column() {
      Column() {
        Text('异常上报')
          .fontSize('18fp')
          .fontColor('#111827')
          .fontWeight(FontWeight.Bold)
          .width('100%')

        Text('请填写当前产线异常情况，提交后整线会切换为异常状态。')
          .fontSize('13fp')
          .fontColor('#6B7280')
          .width('100%')
          .margin({ top: '8vp', bottom: '14vp' })

        TextInput({ text: this.viewModel.exceptionText, placeholder: '例如：OP40 螺丝锁付工位卡料，等待维修处理' })
          .width('100%')
          .height('96vp')
          .backgroundColor('#F8FAFC')
          .borderRadius('12vp')
          .padding('12vp')
          .onChange((value: string) => {
            this.viewModel.onExceptionTextChange(value);
          })

        Row() {
          Button('取消')
            .layoutWeight(1)
            .height('44vp')
            .fontColor('#4B5563')
            .backgroundColor('#F3F4F6')
            .borderRadius('10vp')
            .margin({ right: '8vp' })
            .onClick(() => {
              this.viewModel.cancelAction();
            })

          Button('提交')
            .layoutWeight(1)
            .height('44vp')
            .fontColor('#FFFFFF')
            .backgroundColor('#EF4444')
            .borderRadius('10vp')
            .onClick(() => {
              this.viewModel.submitException();
            })
        }
        .width('100%')
        .margin({ top: '16vp' })
      }
      .width('84%')
      .padding('20vp')
      .borderRadius('18vp')
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#66000000')
  }

  @Builder
  buildToast() {
    Column() {
      Text(this.viewModel.toastMessage)
        .fontSize('13fp')
        .fontColor('#FFFFFF')
        .padding({ left: '16vp', right: '16vp', top: '10vp', bottom: '10vp' })
        .backgroundColor('#CC111827')
        .borderRadius('18vp')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .position({ x: 0, y: '78%' })
  }

  @Builder
  buildHeader() {
    Row() {
      Column() {
        Text('‹')
          .fontSize('24fp')
          .fontColor('#1A2B3C')
          .fontWeight(FontWeight.Bold)
      }
      .width('36vp')
      .height('36vp')
      .borderRadius('18vp')
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .margin({ right: '12vp' })
      .onClick(() => {
        this.onBack?.();
      })

      Column() {
        Text('产线详情')
          .fontSize('18fp')
          .fontColor('#1A2B3C')
          .fontWeight(FontWeight.Bold)
        Text(this.viewModel.lineDetail
          ? this.viewModel.lineDetail.name + ' · ' + this.viewModel.lineDetail.processDescription
          : '')
          .fontSize('12fp')
          .fontColor('#6B7B8C')
          .margin({ top: '2vp' })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '16vp', bottom: '12vp' })
  }

  @Builder
  buildLineStatusCard(detail: LineDetailFull) {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image($r('app.media.line_1'))
          .width('100%')
          .height('188vp')
          .objectFit(ImageFit.Cover)

        Column() {
          Text('当前整线状态')
            .fontSize('18fp')
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
          Text(detail.statusTag + ' · ' + detail.workorderCode + ' · 当前工艺：' + detail.currentProcess)
            .fontSize('11fp')
            .fontColor('rgba(255,255,255,0.85)')
            .margin({ top: '4vp' })
        }
        .padding({ left: '16vp', bottom: '16vp' })

        Row() {
          Text(detail.statusTag)
            .fontSize('11fp')
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
            .padding({ left: '10vp', right: '10vp', top: '4vp', bottom: '4vp' })
            .borderRadius('12vp')
            .backgroundColor(this.viewModel.getStatusBgColor(detail.statusTag))
        }
        .position({ x: '100%', y: '16vp' })
        .markAnchor({ x: '100%', y: 0 })
        .offset({ x: '-16vp' })
      }
      .width('100%')

      if (!this.viewModel.isAdmin()) {
        Row() {
          Text(this.viewModel.getReadOnlyTip())
            .fontSize('12fp')
            .fontColor('#7C2D12')
        }
        .width('100%')
        .padding({ left: '12vp', right: '12vp', top: '10vp', bottom: '10vp' })
        .backgroundColor('#FFF7ED')
      }
    }
    .width('100%')
    .borderRadius('14vp')
    .backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp' })
    .clip(true)
  }

  @Builder
  buildTaskSelection() {
    Column() {
      Row() {
        Text('生产任务')
          .fontSize('16fp')
          .fontColor('#111827')
          .fontWeight(FontWeight.Bold)
        Blank()
        Text(this.viewModel.hasSelectedTask() ? '已选择' : '未选择')
          .fontSize('12fp')
          .fontColor(this.viewModel.hasSelectedTask() ? '#059669' : '#DC2626')
      }
      .width('100%')

      Text('先选择任务，再执行整线启动、暂停、复位。')
        .fontSize('12fp')
        .fontColor('#6B7280')
        .width('100%')
        .margin({ top: '6vp', bottom: '12vp' })

      ForEach(this.viewModel.availableTasks, (task: SelectTaskItem) => {
        this.buildTaskCard(task)
      }, (task: SelectTaskItem) => task.id.toString())

      Row() {
        Text('当前任务：' + this.viewModel.getCurrentTaskSummary())
          .fontSize('12fp')
          .fontColor('#0F766E')
      }
      .width('100%')
      .padding({ left: '12vp', right: '12vp', top: '10vp', bottom: '10vp' })
      .borderRadius('10vp')
      .backgroundColor('#ECFDF5')
      .margin({ top: '12vp' })
    }
    .width('100%')
    .padding('14vp')
    .borderRadius('14vp')
    .backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '12vp' })
  }

  @Builder
  buildTaskCard(task: SelectTaskItem) {
    Column() {
      Row() {
        Column() {
          Text(task.code)
            .fontSize('14fp')
            .fontColor('#0F766E')
            .fontWeight(FontWeight.Bold)
          Text(task.productName + ' · ' + task.processName)
            .fontSize('13fp')
            .fontColor('#111827')
            .margin({ top: '4vp' })
          Text('计划 ' + task.planQty.toString() + ' 件 · 操作员 ' + task.operatorName)
            .fontSize('11fp')
            .fontColor('#6B7280')
            .margin({ top: '4vp' })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text(this.viewModel.isTaskSelected(task.id) ? '已选中' : '点击选择')
          .fontSize('11fp')
          .fontColor(this.viewModel.isTaskSelected(task.id) ? '#FFFFFF' : '#0F766E')
          .padding({ left: '10vp', right: '10vp', top: '4vp', bottom: '4vp' })
          .borderRadius('10vp')
          .backgroundColor(this.viewModel.isTaskSelected(task.id) ? '#10B981' : '#ECFDF5')
      }
      .width('100%')
    }
    .width('100%')
    .padding('12vp')
    .borderRadius('12vp')
    .backgroundColor(this.viewModel.isTaskSelected(task.id) ? '#F0FDF4' : '#F8FAFC')
    .border({
      width: this.viewModel.isTaskSelected(task.id) ? '2vp' : '1vp',
      color: this.viewModel.isTaskSelected(task.id) ? '#10B981' : '#E2E8F0'
    })
    .opacity(this.viewModel.isTaskCardClickDisabled() ? 0.65 : 1)
    .margin({ bottom: '10vp' })
    .onClick(() => {
      this.viewModel.selectTask(task.id);
    })
  }

  @Builder
  buildStatsRow(detail: LineDetailFull) {
    Row() {
      Column() {
        Text('当前操作员')
          .fontSize('11fp')
          .fontColor('#6B7B8C')
        Text(detail.operatorName)
          .fontSize('16fp')
          .fontColor('#1A2B3C')
          .fontWeight(FontWeight.Bold)
          .margin({ top: '4vp' })
      }
      .layoutWeight(1)
      .height('80vp')
      .borderRadius('12vp')
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Column() {
        Text('工单状态')
          .fontSize('11fp')
          .fontColor('#6B7B8C')
        Text(detail.workorderStatus)
          .fontSize('14fp')
          .fontColor(detail.status === 'running' ? '#10B981' : '#F59E0B')
          .fontWeight(FontWeight.Bold)
          .margin({ top: '4vp' })
      }
      .layoutWeight(1)
      .height('80vp')
      .borderRadius('12vp')
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .margin({ left: '8vp', right: '8vp' })

      Column() {
        Text('原料 / 成品 / NG')
          .fontSize('10fp')
          .fontColor('#6B7B8C')
        Text(detail.rawMaterial.toString() + ' / ' + detail.finishedProduct.toString() + ' / ' + detail.ngCount.toString())
          .fontSize('13fp')
          .fontColor('#1A2B3C')
          .fontWeight(FontWeight.Medium)
          .margin({ top: '4vp' })
      }
      .layoutWeight(1)
      .height('80vp')
      .borderRadius('12vp')
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '12vp' })
  }

  @Builder
  buildWorkstationGrid() {
    Column() {
      Row() {
        Row() {
          Blank()
            .width('6vp')
            .height('6vp')
            .borderRadius('3vp')
            .backgroundColor(this.viewModel.hasExceptionStation() ? '#EF4444' : '#4CAF50')
          Text('工位状态')
            .fontSize('16fp')
            .fontColor('#1A2B3C')
            .fontWeight(FontWeight.Medium)
            .margin({ left: '8vp' })
        }
        .layoutWeight(1)
        Text(this.viewModel.lineDetail ? this.viewModel.lineDetail.currentProcess : '')
          .fontSize('12fp')
          .fontColor('#6B7B8C')
      }
      .width('100%')
      .margin({ bottom: '12vp' })

      if (this.viewModel.hasExceptionStation()) {
        Row() {
          Text(this.viewModel.getExceptionSummary())
            .fontSize('12fp')
            .fontColor('#991B1B')
        }
        .width('100%')
        .padding({ left: '12vp', right: '12vp', top: '10vp', bottom: '10vp' })
        .backgroundColor('#FEF2F2')
        .borderRadius('10vp')
        .margin({ bottom: '12vp' })
      }

      ForEach(this.viewModel.workstationStatusList, (station: WorkstationDetail) => {
        this.buildWorkstationCard(station)
      }, (station: WorkstationDetail) => station.id.toString())
    }
    .width('100%')
    .padding('16vp')
    .borderRadius('14vp')
    .backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '12vp' })
  }

  @Builder
  buildWorkstationCard(station: WorkstationDetail) {
    Column() {
      Row() {
        Column() {
          Text(station.code + ' ' + station.name)
            .fontSize('14fp')
            .fontColor('#1A2B3C')
            .fontWeight(FontWeight.Bold)
          Text('设备: ' + station.deviceStatus + ' · 工作: ' + station.workStatus)
            .fontSize('11fp')
            .fontColor('#6B7B8C')
            .margin({ top: '2vp' })
          Text('产品: ' + station.productCode + ' · 加工 ' + station.processingTime)
            .fontSize('11fp')
            .fontColor('#6B7B8C')
            .margin({ top: '2vp' })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Row() {
          Text(station.status)
            .fontSize('11fp')
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
            .padding({ left: '10vp', right: '10vp', top: '4vp', bottom: '4vp' })
            .borderRadius('10vp')
            .backgroundColor(this.viewModel.getStatusBgColor(station.status))
          Text('›')
            .fontSize('16fp')
            .fontColor('#999999')
            .margin({ left: '8vp' })
        }
      }
      .width('100%')

      Row() {
        Text('加工 ' + station.processedCount.toString())
          .fontSize('11fp')
          .fontColor('#64748B')
        Text('  |  良品 ' + station.goodCount.toString())
          .fontSize('11fp')
          .fontColor('#059669')
        Text('  |  NG ' + station.ngCount.toString())
          .fontSize('11fp')
          .fontColor('#DC2626')
      }
      .width('100%')
      .margin({ top: '10vp' })
    }
    .width('100%')
    .padding('14vp')
    .borderRadius('10vp')
    .backgroundColor(this.viewModel.getCardBgColor(station.status))
    .border({ width: '1vp', color: this.viewModel.getCardBorderColor(station.status) })
    .margin({ bottom: '8vp' })
    .onClick(() => {
      this.onStationClick?.(station.id);
    })
  }

  @Builder
  buildActionSection() {
    Column() {
      Text(this.viewModel.getLineActionTitle())
        .fontSize('16fp')
        .fontColor('#111827')
        .fontWeight(FontWeight.Bold)
        .width('100%')

      Text(this.viewModel.isAdmin()
        ? '整线启动后保持运行中，暂停后统一进入暂停中，复位后回到待启动。'
        : '当前账号只能查看整线状态和工位情况。')
        .fontSize('12fp')
        .fontColor('#6B7280')
        .width('100%')
        .margin({ top: '6vp', bottom: '12vp' })

      Row() {
        this.buildActionButton('启动', 'start')
        this.buildActionButton('暂停', 'stop')
      }
      .width('100%')

      Row() {
        this.buildActionButton('复位', 'reset')
        this.buildActionButton('异常上报', 'exception')
      }
      .width('100%')
      .margin({ top: '10vp' })
    }
    .width('100%')
    .padding('14vp')
    .borderRadius('14vp')
    .backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '12vp' })
  }

  @Builder
  buildActionButton(label: string, action: string) {
    Button() {
      Text(label)
        .fontSize('15fp')
        .fontColor(action === 'exception' && this.viewModel.isAdmin() ? '#111827' : '#FFFFFF')
        .fontWeight(FontWeight.Bold)
    }
    .layoutWeight(1)
    .height('48vp')
    .borderRadius('12vp')
    .backgroundColor(action === 'exception' && this.viewModel.isAdmin() ? '#F3F4F6' : this.viewModel.getActionButtonBg(action))
    .opacity(this.canUseAction(action) ? 1 : 0.65)
    .enabled(this.canUseAction(action))
    .margin({ left: label === '启动' || label === '复位' ? '0vp' : '10vp' })
    .onClick(() => {
      this.viewModel.showLineActionConfirm(action);
    })
  }

  canUseAction(action: string): boolean {
    if (action === 'exception') {
      return this.viewModel.isAdmin();
    }
    return this.viewModel.isActionEnabled(action);
  }
}
