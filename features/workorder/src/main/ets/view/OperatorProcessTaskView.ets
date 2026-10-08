import { OperatorProcessTaskViewModel, ProcessTask } from '../viewModel/OperatorProcessTaskViewModel';

@ComponentV2
export struct OperatorProcessTaskView {
  @Param viewModel: OperatorProcessTaskViewModel = new OperatorProcessTaskViewModel();
  @Param cardPadding: number = 20;
  @Event onBack?: () => void;
  @Event onViewDetail?: (orderId: number) => void;
  @Event onEnterLine?: (lineId: number) => void;
  private navStack: NavPathStack | null = null;

  aboutToAppear(): void {
    this.navStack = AppStorage.get('navPathStack') as NavPathStack;
    this.viewModel.init();
  }

  build() {
    Column() {
      this.buildHeader()
      this.buildTabBar()
      Scroll() {
        Column() {
          if (this.viewModel.currentTab === 0) {
            this.buildPendingTab()
          } else if (this.viewModel.currentTab === 1) {
            this.buildInProgressTab()
          } else {
            this.buildReportedTab()
          }
          Blank().height('24vp')
        }
        .width('100%')
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F4F8')
  }

  @Builder
  buildHeader() {
    Row() {
      Row() {
        Text('‹')
          .fontSize('26fp')
          .fontColor('#64748B')
          .fontWeight(FontWeight.Normal)
      }
      .width('40vp')
      .height('40vp')
      .borderRadius('12vp')
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        if (this.onBack) {
          this.onBack();
        } else if (this.navStack) {
          this.navStack.pop();
        }
      })

      Column() {
        Text('我的工序任务')
          .fontSize('22fp')
          .fontColor('#0F172A')
          .fontWeight(FontWeight.Bold)
        Text('生产人员 · WS-A-010')
          .fontSize('13fp')
          .fontColor('#64748B')
          .margin({ top: '2vp' })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: '12vp' })

      Row() {
        Text('👤')
          .fontSize('20fp')
      }
      .width('48vp')
      .height('48vp')
      .borderRadius('24vp')
      .backgroundColor('#E2E8F0')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '16vp', bottom: '16vp' })
    .backgroundColor('#F0F4F8')
  }

  @Builder
  buildTabBar() {
    Row() {
      this.buildTabItem(0, '待执行')
      this.buildTabItem(1, '进行中')
      this.buildTabItem(2, '已报工')
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, bottom: '16vp' })
  }

  @Builder
  buildTabItem(index: number, label: string) {
    Text(label)
      .fontSize('15fp')
      .fontColor(this.viewModel.currentTab === index ? '#FFFFFF' : '#64748B')
      .fontWeight(this.viewModel.currentTab === index ? FontWeight.Bold : FontWeight.Medium)
      .layoutWeight(1)
      .height('44vp')
      .borderRadius('14vp')
      .backgroundColor(this.viewModel.currentTab === index ? '#0D9488' : '#FFFFFF')
      .textAlign(TextAlign.Center)
      .onClick(() => {
        this.viewModel.switchTab(index);
      })
  }

  @Builder
  buildPendingTab() {
    Column() {
      this.buildSelectionNotice()

      if (this.viewModel.currentTask) {
        this.buildCurrentTaskCard(this.viewModel.currentTask!)
      }

      Text('队列')
        .fontSize('16fp')
        .fontColor('#64748B')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ top: '20vp', bottom: '12vp' })

      ForEach(this.viewModel.queueTasks, (task: ProcessTask) => {
        this.buildQueueTaskCard(task)
      }, (task: ProcessTask) => task.id.toString())
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding })
  }

  @Builder
  buildInProgressTab() {
    Column() {
      if (this.viewModel.inProgressTask) {
        this.buildInProgressTaskCard(this.viewModel.inProgressTask!)
      }

      Text('队列')
        .fontSize('16fp')
        .fontColor('#64748B')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ top: '20vp', bottom: '12vp' })

      ForEach(this.viewModel.queueTasks, (task: ProcessTask) => {
        this.buildQueueTaskCard(task)
      }, (task: ProcessTask) => task.id.toString())
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding })
  }

  @Builder
  buildReportedTab() {
    Column() {
      ForEach(this.viewModel.reportedTasks, (task: ProcessTask) => {
        this.buildReportedTaskCard(task)
      }, (task: ProcessTask) => task.id.toString())
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding })
  }

  @Builder
  buildCurrentTaskCard(task: ProcessTask) {
    Column() {
      Row() {
        Row() {
          Text('⚙️')
            .fontSize('28fp')
        }
        .width('72vp')
        .height('72vp')
        .borderRadius('16vp')
        .backgroundColor('#E0F2FE')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .margin({ right: '14vp' })

        Column() {
          Text(task.workOrderCode + ' / ' + task.processCode)
            .fontSize('13fp')
            .fontColor('#0F766E')
            .fontWeight(FontWeight.Medium)

          Text(task.processName + ' · ' + task.productName)
            .fontSize('18fp')
            .fontColor('#0F172A')
            .fontWeight(FontWeight.Bold)
            .margin({ top: '6vp' })

          Text('计划剩余 ' + task.remainQty.toString() + ' 件 · ' + task.remark)
            .fontSize('14fp')
            .fontColor('#64748B')
            .margin({ top: '6vp' })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      Row() {
        Row() {
          Text(this.viewModel.isTaskSelected(task.id) ? '已选中' : '选择任务')
            .fontSize('16fp')
            .fontColor('#0F766E')
            .fontWeight(FontWeight.Bold)
        }
        .layoutWeight(1)
        .height('52vp')
        .backgroundColor('#FFFFFF')
        .borderRadius('16vp')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          this.viewModel.selectTask(task.id);
        })

        Blank().width('12vp')

        Row() {
          Text('进入产线 →')
            .fontSize('16fp')
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
        }
        .layoutWeight(1)
        .height('52vp')
        .backgroundColor('#0D9488')
        .borderRadius('16vp')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .opacity(this.viewModel.canEnterLine() ? 1 : 0.65)
        .onClick(() => {
          this.viewModel.selectTask(task.id);
          if (this.onEnterLine) {
            this.onEnterLine(this.viewModel.getSelectedLineId());
          }
        })
      }
      .width('100%')
      .margin({ top: '16vp' })
    }
    .width('100%')
    .padding({ left: '18vp', right: '18vp', top: '18vp', bottom: 0 })
    .borderRadius('20vp')
    .backgroundColor('#ECFDF5')
    .border({ width: this.viewModel.isTaskSelected(task.id) ? '2vp' : '1vp', color: this.viewModel.isTaskSelected(task.id) ? '#10B981' : '#A7F3D0' })
    .margin({ bottom: '12vp' })
  }

  @Builder
  buildInProgressTaskCard(task: ProcessTask) {
    Column() {
      Text(task.workOrderCode + ' / ' + task.processCode)
        .fontSize('13fp')
        .fontColor('#0F766E')
        .fontWeight(FontWeight.Medium)
        .width('100%')

      Text('进行中：' + task.processName)
        .fontSize('18fp')
        .fontColor('#0F172A')
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .margin({ top: '6vp' })

      Text('已执行 ' + this.viewModel.elapsedMinutes.toString() + ' 分钟 · 进度 ' + this.viewModel.progressPercent.toString() + '%')
        .fontSize('14fp')
        .fontColor('#64748B')
        .width('100%')
        .margin({ top: '6vp' })

      Row() {
        Row() {
          Text('报工 →')
            .fontSize('16fp')
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
        }
        .layoutWeight(1)
        .height('52vp')
        .backgroundColor('#0D9488')
        .borderRadius('16vp')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .onClick(async () => {
          await this.viewModel.reportTask(task.id);
          if (this.onViewDetail) {
            this.onViewDetail(task.workOrderId);
          }
        })
      }
      .width('100%')
      .margin({ top: '16vp' })
    }
    .width('100%')
    .padding('18vp')
    .borderRadius('20vp')
    .backgroundColor('#FFFFFF')
    .border({ width: '1vp', color: '#E2E8F0' })
    .margin({ bottom: '12vp' })
  }

  @Builder
  buildReportedTaskCard(task: ProcessTask) {
    Column() {
      Text(task.workOrderCode + ' / ' + task.processCode)
        .fontSize('13fp')
        .fontColor('#64748B')
        .fontWeight(FontWeight.Medium)
        .width('100%')

      Text('已报工：' + task.processName)
        .fontSize('18fp')
        .fontColor('#0F172A')
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .margin({ top: '6vp' })

      Text('完工 ' + task.completedQty.toString() + ' 件 · 合格率 ' + (task.planQty > 0 ? ((task.completedQty / task.planQty) * 100).toFixed(1) : '0') + '%')
        .fontSize('14fp')
        .fontColor('#059669')
        .width('100%')
        .margin({ top: '6vp' })
    }
    .width('100%')
    .padding('18vp')
    .borderRadius('20vp')
    .backgroundColor('#FFFFFF')
    .border({ width: '1vp', color: '#E2E8F0' })
    .margin({ bottom: '12vp' })
  }

  @Builder
  buildQueueTaskCard(task: ProcessTask) {
    Row() {
      Row() {
        Text('⚙️')
          .fontSize('24fp')
      }
      .width('56vp')
      .height('56vp')
      .borderRadius('16vp')
      .backgroundColor('#F1F5F9')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .margin({ right: '14vp' })

      Column() {
        Text(task.workOrderCode + ' / ' + task.processCode)
          .fontSize('12fp')
          .fontColor('#64748B')
          .fontWeight(FontWeight.Medium)

        Text(task.processName + ' · ' + task.productName)
          .fontSize('16fp')
          .fontColor('#0F172A')
          .fontWeight(FontWeight.Bold)
          .margin({ top: '4vp' })

        Text(task.estimatedTime + (task.estimatedTime && task.remark ? ' · ' : '') + task.remark)
          .fontSize('13fp')
          .fontColor(task.isUrgent ? '#EF4444' : '#64748B')
          .margin({ top: '4vp' })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(this.viewModel.isTaskSelected(task.id) ? '已选' : '选择')
        .fontSize('11fp')
        .fontColor(this.viewModel.isTaskSelected(task.id) ? '#FFFFFF' : '#0F766E')
        .padding({ left: '10vp', right: '10vp', top: '4vp', bottom: '4vp' })
        .borderRadius('10vp')
        .backgroundColor(this.viewModel.isTaskSelected(task.id) ? '#10B981' : '#ECFDF5')
    }
    .width('100%')
    .padding('16vp')
    .borderRadius('20vp')
    .backgroundColor('#FFFFFF')
    .border({ width: this.viewModel.isTaskSelected(task.id) ? '2vp' : '1vp', color: this.viewModel.isTaskSelected(task.id) ? '#10B981' : '#E2E8F0' })
    .margin({ bottom: '10vp' })
    .onClick(() => {
      this.viewModel.selectTask(task.id);
    })
  }

  @Builder
  buildSelectionNotice() {
    Column() {
      Text('先选择任务，再进入产线')
        .fontSize('16fp')
        .fontColor('#0F172A')
        .fontWeight(FontWeight.Bold)
        .width('100%')
      Text(this.viewModel.getSelectedTaskSummary())
        .fontSize('13fp')
        .fontColor('#64748B')
        .width('100%')
        .margin({ top: '6vp' })

      Row() {
        Button('进入产线')
          .layoutWeight(1)
          .height('44vp')
          .fontColor('#FFFFFF')
          .backgroundColor('#0D9488')
          .borderRadius('12vp')
          .enabled(this.viewModel.canEnterLine())
          .opacity(this.viewModel.canEnterLine() ? 1 : 0.65)
          .onClick(() => {
            if (this.onEnterLine) {
              this.onEnterLine(this.viewModel.getSelectedLineId());
            }
          })
      }
      .width('100%')
      .margin({ top: '12vp' })
    }
    .width('100%')
    .padding('16vp')
    .borderRadius('18vp')
    .backgroundColor('#FFFFFF')
    .border({ width: '1vp', color: '#E2E8F0' })
    .margin({ bottom: '14vp' })
  }
}
