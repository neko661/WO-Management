import { WorkOrderDetailViewModel } from '../viewModel/WorkOrderDetailViewModel';
import { WorkOrder } from 'utils';
import promptAction from '@ohos.promptAction';

@ComponentV2
export struct WorkOrderDetailView {
  @Param viewModel: WorkOrderDetailViewModel = new WorkOrderDetailViewModel();
  @Param orderId: number = 0;
  @Event onBack?: () => void;
  @Event onModify?: () => void;
  @Event onStatusChanged?: (orderId: number, action: string) => void;
  private navStack: NavPathStack | null = null;

  aboutToAppear(): void {
    this.navStack = AppStorage.get('navPathStack') as NavPathStack;
    this.viewModel.onStatusChanged = (orderId: number, action: string) => {
      if (this.onStatusChanged) {
        this.onStatusChanged(orderId, action);
      }
    };
    if (this.orderId > 0) {
      this.viewModel.init(this.orderId);
    }
  }

  build() {
    if (this.viewModel.isLoading && !this.viewModel.order) {
      Column() {
        LoadingProgress().width('36vp').height('36vp').color('#0D9488')
        Text('加载中...').fontSize('14fp').fontColor('#999999').margin({ top: '12vp' })
      }
      .width('100%').height('100%')
      .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
      .backgroundColor('#F0F4F8')
    } else if (!this.viewModel.order) {
      Column() {
        Text('加载失败').fontSize('16fp').fontColor('#999999')
      }
      .width('100%').height('100%')
      .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
      .backgroundColor('#F0F4F8')
    } else {
      Column() {
        this.buildTopBar()
        Scroll() {
          Column() {
            if (this.viewModel.showReportSection) {
              this.buildReportStatusCard()
            }
            this.buildOrderInfoCard()
            if (this.viewModel.showDispatchSection) {
              this.buildDispatchSection()
            }
            if (this.viewModel.showStartSection) {
              this.buildStartSection()
            }
            if (this.viewModel.showPauseSection) {
              this.buildPauseSection()
            }
            if (this.viewModel.showResumeScrapSection) {
              this.buildResumeScrapSection()
            }
            if (this.viewModel.showIssueToDispatchSection) {
              this.buildIssueToDispatchSection()
            }
            if (this.viewModel.showConfirmHoursSection) {
              this.buildProgressIndicator()
              this.buildConfirmHoursSection()
            }
            this.buildProcessRouteCard()
            if (this.viewModel.showAutoProductionResult) {
              this.buildAutoProductionResultCard()
            }
            if (this.viewModel.showReportSection) {
              this.buildReportFormCard()
            }
            Blank().height('24vp')
          }
          .width('100%')
          .padding({ left: '16vp', right: '16vp' })
        }
        .layoutWeight(1).width('100%')
        .scrollBar(BarState.Off).backgroundColor('#F0F4F8')
      }
      .width('100%').height('100%').backgroundColor('#F0F4F8')
    }
  }

  // ========== 顶部导航栏 ==========
  @Builder
  buildTopBar() {
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
      .backgroundColor('#F1F5F9')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        if (this.navStack) this.navStack.pop();
        if (this.onBack) this.onBack();
      })

      Column() {
        Text(this.viewModel.order!.code)
          .fontSize('12fp')
          .fontColor('#0EA5E9')
          .fontWeight(FontWeight.Medium)
        Text(this.viewModel.showReportSection ? '工单详情·待报工' : '工单详情')
          .fontSize('20fp')
          .fontColor('#0F172A')
          .fontWeight(FontWeight.Bold)
          .margin({ top: '2vp' })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: '12vp' })

      Text('修改')
        .fontSize('14fp')
        .fontColor('#0EA5E9')
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          if (this.onModify) this.onModify();
        })
    }
    .width('100%')
    .padding({ left: '16vp', right: '16vp', top: '14vp', bottom: '12vp' })
    .backgroundColor('#F0F4F8')
  }

  // ========== 工单基本信息卡片 ==========
  @Builder
  buildOrderInfoCard() {
    Column() {
      Row() {
        Text(this.viewModel.order!.productName)
          .fontSize('20fp')
          .fontColor('#0F172A')
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
        Text(this.viewModel.order!.status)
          .fontSize('13fp')
          .fontColor(this.viewModel.getStatusColor(this.viewModel.order!.status))
          .fontWeight(FontWeight.Medium)
          .padding({ left: '12vp', right: '12vp', top: '5vp', bottom: '5vp' })
          .borderRadius('10vp')
          .backgroundColor(this.viewModel.getStatusBgColor(this.viewModel.order!.status))
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Text('产品编码 ' + this.viewModel.order!.productCode)
        .fontSize('13fp')
        .fontColor('#64748B')
        .width('100%')
        .margin({ top: '8vp' })

      Column() {
        this.buildInfoGrid()
      }
      .width('100%')
      .margin({ top: '16vp' })
    }
    .width('100%')
    .padding('18vp')
    .borderRadius('18vp')
    .backgroundColor('#FFFFFF')
    .margin({ top: '4vp', bottom: '12vp' })
    .shadow({ radius: 10, color: "rgba(15, 23, 42, 0.04)", offsetY: 2 })
  }

  @Builder
  buildInfoGrid() {
    Column() {
      Row() {
        this.buildInfoItem('工单类型', this.viewModel.order!.type)
        Blank().width('12vp')
        this.buildInfoItem('计划数量', this.viewModel.order!.planQty.toString())
      }
      .width('100%')
      .margin({ bottom: '12vp' })

      Row() {
        this.buildInfoItem('车间', this.viewModel.getWorkshop())
        Blank().width('12vp')
        this.buildInfoItem('资源', this.viewModel.order!.resource || '柔性线')
      }
      .width('100%')
      .margin({ bottom: '12vp' })

      Row() {
        this.buildInfoItem('产线', this.viewModel.order!.lineName || '—')
        Blank().width('12vp')
        this.buildInfoItem('工艺', this.viewModel.order!.processName || '—')
      }
      .width('100%')
      .margin({ bottom: '12vp' })

      Row() {
        this.buildInfoItem('来源', this.viewModel.order!.source || '—')
        Blank().width('12vp')
        this.buildInfoItem('产品编码', this.viewModel.order!.productCode || '—')
      }
      .width('100%')
      .margin({ bottom: '12vp' })

      if (this.viewModel.showReportSection) {
        Row() {
          this.buildOperatorItem('操作员', this.viewModel.order!.operatorName || '—')
          Blank().width('12vp')
          this.buildInfoItem('报工状态', this.viewModel.order!.status)
        }
        .width('100%')
        .margin({ bottom: '12vp' })

        Row() {
          this.buildDateTimeItem('实际开始时间', this.viewModel.order!.actualStartTime)
          Blank().width('12vp')
          this.buildDateTimeItem('实际完成时间', this.viewModel.order!.actualEndTime)
        }
        .width('100%')
        .margin({ bottom: '12vp' })

        Row() {
          this.buildDateTimeItem('计划开始时间', this.viewModel.order!.planStartTime)
          Blank().width('12vp')
          this.buildDateTimeItem('计划结束时间', this.viewModel.order!.planEndTime)
        }
        .width('100%')
        .margin({ bottom: '12vp' })

        Row() {
          this.buildInfoItem('当前状态流', this.viewModel.order!.statusFlow || '—')
        }
        .width('100%')
      } else {
        Row() {
          this.buildInfoItem('派工操作员', this.viewModel.order!.operatorName || '—')
          Blank().width('12vp')
          this.buildDateTimeItem('计划开始时间', this.viewModel.order!.planStartTime)
        }
        .width('100%')
        .margin({ bottom: '12vp' })

        Row() {
          this.buildDateTimeItem('计划结束时间', this.viewModel.order!.planEndTime)
          Blank().width('12vp')
          this.buildDateTimeItem('派工时间', this.viewModel.order!.dispatchTime)
        }
        .width('100%')
        .margin({ bottom: '12vp' })

        Row() {
          this.buildDateTimeItem('实际开始时间', this.viewModel.order!.actualStartTime)
          Blank().width('12vp')
          this.buildInfoItem('当前状态流', this.viewModel.order!.statusFlow || '—')
        }
        .width('100%')
      }
    }
    .width('100%')
  }

  @Builder
  buildOperatorItem(label: string, value: string) {
    Column() {
      Text(label)
        .fontSize('12fp')
        .fontColor('#64748B')
        .width('100%')
        .margin({ bottom: '6vp' })
      Text(value)
        .fontSize('16fp')
        .fontColor('#059669')
        .fontWeight(FontWeight.Bold)
        .width('100%')
    }
    .layoutWeight(1)
    .padding('14vp')
    .borderRadius('14vp')
    .backgroundColor('#ECFDF5')
    .border({ width: '1vp', color: '#6EE7B7' })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildInfoItem(label: string, value: string) {
    Column() {
      Text(label)
        .fontSize('12fp')
        .fontColor('#64748B')
        .width('100%')
        .margin({ bottom: '6vp' })
      Text(value)
        .fontSize('16fp')
        .fontColor('#0F172A')
        .fontWeight(FontWeight.Bold)
        .width('100%')
    }
    .layoutWeight(1)
    .padding('14vp')
    .borderRadius('14vp')
    .backgroundColor('#F8FAFC')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildDateTimeItem(label: string, dateTimeStr?: string) {
    Column() {
      Text(label)
        .fontSize('12fp')
        .fontColor('#64748B')
        .width('100%')
        .margin({ bottom: '6vp' })
      Column() {
        Text(this.viewModel.splitDateTime(dateTimeStr).date)
          .fontSize('14fp')
          .fontColor('#0F172A')
          .fontWeight(FontWeight.Bold)
        if (this.viewModel.splitDateTime(dateTimeStr).time) {
          Text(this.viewModel.splitDateTime(dateTimeStr).time)
            .fontSize('14fp')
            .fontColor('#0F172A')
            .fontWeight(FontWeight.Bold)
            .margin({ top: '2vp' })
        }
      }
      .alignItems(HorizontalAlign.Start)
    }
    .layoutWeight(1)
    .padding('14vp')
    .borderRadius('14vp')
    .backgroundColor('#F8FAFC')
    .alignItems(HorizontalAlign.Start)
  }

  // ========== 派工操作区域 ==========
  @Builder
  buildDispatchSection() {
    Column() {
      Row() {
        Text('派工操作')
          .fontSize('18fp')
          .fontColor('#B45309')
          .fontWeight(FontWeight.Bold)
        Blank()
        Text('待派工')
          .fontSize('12fp')
          .fontColor('#B45309')
          .fontWeight(FontWeight.Medium)
          .padding({ left: '10vp', right: '10vp', top: '4vp', bottom: '4vp' })
          .borderRadius('8vp')
          .backgroundColor('#FEF3C7')
      }
      .width('100%')

      Text('将此工单派工给一个操作员执行生产')
        .fontSize('13fp')
        .fontColor('#78716C')
        .width('100%')
        .margin({ top: '10vp' })

      Row() {
        ForEach(this.viewModel.order!.availableOperators || [], (name: string) => {
          this.buildOperatorButton(name)
        }, (name: string) => name)
      }
      .width('100%')
      .margin({ top: '14vp' })

      Button() {
        Text('确认派工')
          .fontSize('16fp')
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .height('48vp')
      .borderRadius('14vp')
      .linearGradient({
        direction: GradientDirection.Left,
        colors: [["#0EA5E9", 0.0], ["#0284C7", 1.0]]
      })
      .margin({ top: '14vp' })
      .shadow({ radius: 8, color: "rgba(14, 165, 233, 0.3)", offsetY: 4 })
      .onClick(async () => {
        await this.viewModel.confirmDispatch();
      })
    }
    .width('100%')
    .padding('18vp')
    .borderRadius('18vp')
    .backgroundColor('#FFFBEB')
    .border({ width: '1vp', color: '#FDE68A' })
    .margin({ bottom: '12vp' })
    .shadow({ radius: 10, color: "rgba(251, 191, 36, 0.1)", offsetY: 2 })
  }

  // ========== 启动生产操作区域 ==========
  @Builder
  buildStartSection() {
    Column() {
      Row() {
        Text('生产准备')
          .fontSize('18fp')
          .fontColor('#D97706')
          .fontWeight(FontWeight.Bold)
        Blank()
        Text('已派工')
          .fontSize('12fp')
          .fontColor('#D97706')
          .fontWeight(FontWeight.Medium)
          .padding({ left: '10vp', right: '10vp', top: '4vp', bottom: '4vp' })
          .borderRadius('8vp')
          .backgroundColor('#FEF3C7')
      }
      .width('100%')

      Text('工单已派工，操作员可启动生产')
        .fontSize('13fp')
        .fontColor('#78716C')
        .width('100%')
        .margin({ top: '10vp' })

      Row() {
        Column() {
          Text('操作员')
            .fontSize('12fp')
            .fontColor('#64748B')
            .margin({ bottom: '6vp' })
          Text(this.viewModel.order!.operatorName || '—')
            .fontSize('16fp')
            .fontColor('#0F172A')
            .fontWeight(FontWeight.Bold)
        }
        .layoutWeight(1)
        .padding('14vp')
        .borderRadius('14vp')
        .backgroundColor('#FFFBEB')
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .margin({ top: '14vp' })

      Row() {
        Button() {
          Text('启动生产')
            .fontSize('16fp')
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
        }
        .layoutWeight(1)
        .height('48vp')
        .borderRadius('14vp')
        .linearGradient({
          direction: GradientDirection.Left,
          colors: [["#10B981", 0.0], ["#059669", 1.0]]
        })
        .shadow({ radius: 8, color: "rgba(16, 185, 129, 0.3)", offsetY: 4 })
        .onClick(async () => {
          await this.viewModel.doTransition('start');
        })

        Blank().width('12vp')

        Button() {
          Text('取消派工')
            .fontSize('16fp')
            .fontColor('#DC2626')
            .fontWeight(FontWeight.Bold)
        }
        .layoutWeight(1)
        .height('48vp')
        .borderRadius('14vp')
        .backgroundColor('#FEF2F2')
        .border({ width: '1vp', color: '#FECDD3' })
        .onClick(async () => {
          await this.viewModel.doTransition('cancel_dispatch');
        })
      }
      .width('100%')
      .margin({ top: '14vp' })
    }
    .width('100%')
    .padding('18vp')
    .borderRadius('18vp')
    .backgroundColor('#FFFBEB')
    .border({ width: '1vp', color: '#FDE68A' })
    .margin({ bottom: '12vp' })
    .shadow({ radius: 10, color: "rgba(251, 191, 36, 0.1)", offsetY: 2 })
  }

  // ========== 生产中操作区域 ==========
  @Builder
  buildPauseSection() {
    Column() {
      Text('生产进行中')
        .fontSize('20fp')
        .fontColor('#0D9488')
        .fontWeight(FontWeight.Bold)
        .width('100%')

      Text('工单正在生产中，可暂停或完成生产')
        .fontSize('16fp')
        .fontColor('#0D9488')
        .width('100%')
        .margin({ top: '12vp' })

      Row() {
        Button() {
          Text('生产完成')
            .fontSize('18fp')
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
        }
        .layoutWeight(1)
        .height('50vp')
        .borderRadius('16vp')
        .backgroundColor('#0D9488')
        .onClick(async () => {
          await this.viewModel.doTransition('complete');
        })

        Blank().width('12vp')

        Button() {
          Text('暂停')
            .fontSize('18fp')
            .fontColor('#DC2626')
            .fontWeight(FontWeight.Bold)
        }
        .layoutWeight(1)
        .height('50vp')
        .borderRadius('16vp')
        .backgroundColor('#FEF2F2')
        .border({ width: '1vp', color: '#FECDD3' })
        .onClick(async () => {
          await this.viewModel.doTransition('pause');
        })
      }
      .width('100%')
      .margin({ top: '16vp' })
    }
    .width('100%')
    .padding('20vp')
    .borderRadius('20vp')
    .backgroundColor('#F0FDF9')
    .border({ width: '2vp', color: '#5EEAD4' })
    .margin({ bottom: '12vp' })
  }

  @Builder
  buildOperatorButton(name: string) {
    Row() {
      Text(name)
        .fontSize('18fp')
        .fontColor(this.viewModel.selectedOperator === name ? '#0D9488' : '#64748B')
        .fontWeight(FontWeight.Bold)
    }
    .layoutWeight(1)
    .height('48vp')
    .borderRadius('16vp')
    .backgroundColor(this.viewModel.selectedOperator === name ? '#ECFDF5' : '#F1F5F9')
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .margin({ right: name === '赵敏' ? '0' : '10vp' })
    .onClick(() => {
      this.viewModel.selectOperator(name);
    })
  }

  // ========== 暂停中操作区域 ==========
  @Builder
  buildResumeScrapSection() {
    Column() {
      Text('工单已暂停')
        .fontSize('20fp')
        .fontColor('#B45309')
        .fontWeight(FontWeight.Bold)
        .width('100%')

      Text('工单当前处于暂停状态，可恢复生产或直接报废')
        .fontSize('16fp')
        .fontColor('#B45309')
        .width('100%')
        .margin({ top: '12vp' })

      Row() {
        Button() {
          Text('恢复生产')
            .fontSize('18fp')
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
        }
        .layoutWeight(1)
        .height('50vp')
        .borderRadius('16vp')
        .backgroundColor('#0D9488')
        .onClick(async () => {
          await this.viewModel.doTransition('resume');
        })

        Blank().width('12vp')

        Button() {
          Text('报废')
            .fontSize('18fp')
            .fontColor('#DC2626')
            .fontWeight(FontWeight.Bold)
        }
        .layoutWeight(1)
        .height('50vp')
        .borderRadius('16vp')
        .backgroundColor('#FEF2F2')
        .border({ width: '1vp', color: '#FECDD3' })
        .onClick(async () => {
          await this.viewModel.doTransition('scrap');
        })
      }
      .width('100%')
      .margin({ top: '16vp' })
    }
    .width('100%')
    .padding('20vp')
    .borderRadius('20vp')
    .backgroundColor('#FFFBEB')
    .border({ width: '2vp', color: '#FDE68A' })
    .margin({ bottom: '12vp' })
  }

  // ========== 发放状态操作区域 ==========
  @Builder
  buildIssueToDispatchSection() {
    Column() {
      Text('工单已发放')
        .fontSize('20fp')
        .fontColor('#0D9488')
        .fontWeight(FontWeight.Bold)
        .width('100%')

      Text('工单已发放，可转为待派工状态以分配给操作员')
        .fontSize('16fp')
        .fontColor('#0D9488')
        .width('100%')
        .margin({ top: '12vp' })

      Row() {
        Button() {
          Text('转为待派工')
            .fontSize('18fp')
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
        }
        .layoutWeight(1)
        .height('50vp')
        .borderRadius('16vp')
        .backgroundColor('#0D9488')
        .onClick(async () => {
          await this.viewModel.doTransition('issue_to_dispatch');
        })
      }
      .width('100%')
      .margin({ top: '16vp' })
    }
    .width('100%')
    .padding('20vp')
    .borderRadius('20vp')
    .backgroundColor('#F0FDF9')
    .border({ width: '2vp', color: '#5EEAD4' })
    .margin({ bottom: '12vp' })
  }

  // ========== 黄色进度指示条 ==========
  @Builder
  buildProgressIndicator() {
    Row() {
      Row() {
      }
      .width('50%')
      .height('6vp')
      .borderRadius('3vp')
      .backgroundColor('#FBBF24')
    }
    .width('100%')
    .height('6vp')
    .margin({ bottom: '-3vp' })
    .zIndex(1)
  }

  // ========== 确认工时区域 ==========
  @Builder
  buildConfirmHoursSection() {
    Column() {
      Text('确认工时')
        .fontSize('20fp')
        .fontColor('#0F766E')
        .fontWeight(FontWeight.Bold)
        .width('100%')

      Text('操作员已报工，请确认工时信息')
        .fontSize('16fp')
        .fontColor('#0D9488')
        .width('100%')
        .margin({ top: '10vp' })

      Row() {
        this.buildHoursCard('申报工时', (this.viewModel.order!.reportedHours?.toString() || '0') + ' h')
        Blank().width('10vp')
        this.buildHoursCard('良品数量', this.viewModel.order!.goodQty?.toString() || '0')
        Blank().width('10vp')
        this.buildHoursCard('NG 数量', this.viewModel.order!.ngQty?.toString() || '0')
      }
      .width('100%')
      .margin({ top: '16vp' })

      Row() {
        Button() {
          Text('确认完工')
            .fontSize('18fp')
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
        }
        .layoutWeight(1)
        .height('50vp')
        .borderRadius('16vp')
        .backgroundColor('#0D9488')
        .onClick(async () => {
          const success = await this.viewModel.confirmComplete();
          if (success) {
            promptAction.showToast({
              message: '已经确认完工',
              duration: 2000,
              bottom: 80
            });
          }
        })

        Blank().width('12vp')

        Button() {
          Text('报废')
            .fontSize('18fp')
            .fontColor('#BE123C')
            .fontWeight(FontWeight.Bold)
        }
        .layoutWeight(1)
        .height('50vp')
        .borderRadius('16vp')
        .backgroundColor('#FEF2F2')
        .border({ width: '1vp', color: '#FECDD3' })
        .onClick(async () => {
          await this.viewModel.scrap();
        })
      }
      .width('100%')
      .margin({ top: '16vp' })
    }
    .width('100%')
    .padding('20vp')
    .borderRadius('20vp')
    .backgroundColor('#F0FDF9')
    .border({ width: '2vp', color: '#5EEAD4' })
    .margin({ bottom: '12vp' })
  }

  @Builder
  buildHoursCard(label: string, value: string) {
    Column() {
      Text(label)
        .fontSize('14fp')
        .fontColor('#64748B')
        .width('100%')
        .margin({ bottom: '8vp' })
      Text(value || '—')
        .fontSize('22fp')
        .fontColor('#1E293B')
        .fontWeight(FontWeight.Bold)
        .width('100%')
    }
    .layoutWeight(1)
    .padding('14vp')
    .borderRadius('14vp')
    .backgroundColor('#FFFFFF')
    .border({ width: '1vp', color: '#99F6E4' })
    .alignItems(HorizontalAlign.Start)
  }

  // ========== 工艺路线区域 ==========
  @Builder
  buildProcessRouteCard() {
    Column() {
      Row() {
        Text('工艺路线')
          .fontSize('18fp')
          .fontColor('#64748B')
          .fontWeight(FontWeight.Bold)
        Blank()
        Text(this.viewModel.order?.status === '待报工' ? '(已完成)' : '整线自动按工艺顺序执行')
          .fontSize('14fp')
          .fontColor(this.viewModel.order?.status === '待报工' ? '#059669' : '#94A3B8')
      }
      .width('100%')
      .margin({ bottom: '16vp' })

      Column() {
        ForEach(this.viewModel.getProcessSteps(), (step: string, idx: number) => {
          this.buildProcessStep(idx + 1, step, this.viewModel.order?.status === '待报工')
        }, (step: string, idx: number) => step + idx)
      }
      .width('100%')
    }
    .width('100%')
    .padding('20vp')
    .borderRadius('20vp')
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 2, color: '#0A000000', offsetY: 1 })
    .margin({ top: '12vp' })
  }

  @Builder
  buildProcessStep(stepNum: number, stepName: string, isCompleted: boolean) {
    Row() {
      if (isCompleted) {
        Text('✓')
          .fontSize('18fp')
          .fontColor('#059669')
          .fontWeight(FontWeight.Bold)
          .margin({ right: '12vp' })
      }
      Text(stepNum.toString() + ' / ' + stepName)
        .fontSize('16fp')
        .fontColor(isCompleted ? '#059669' : '#1E293B')
        .layoutWeight(1)
    }
    .width('100%')
    .height('48vp')
    .padding({ left: '20vp', right: '20vp' })
    .borderRadius('14vp')
    .backgroundColor(isCompleted ? '#ECFDF5' : '#F8FAFC')
    .border({ width: '1vp', color: isCompleted ? '#6EE7B7' : '#E2E8F0' })
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: stepNum === 7 ? '0' : '10vp' })
  }

  @Builder
  buildReportStatusCard() {
    Row() {
      Row() {
        Text('🏭')
          .fontSize('28fp')
      }
      .width('56vp')
      .height('56vp')
      .borderRadius('16vp')
      .backgroundColor('#E0F2FE')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .margin({ right: '14vp' })

      Column() {
        Text('生产完成·待报工')
          .fontSize('18fp')
          .fontColor('#0369A1')
          .fontWeight(FontWeight.Bold)
        Text('整线自动生产已完成，请操作员报工')
          .fontSize('14fp')
          .fontColor('#0284C7')
          .margin({ top: '4vp' })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding('18vp')
    .borderRadius('20vp')
    .backgroundColor('#E0F2FE')
    .border({ width: '1vp', color: '#7DD3FC' })
    .margin({ bottom: '12vp' })
  }

  @Builder
  buildAutoProductionResultCard() {
    Column() {
      Row() {
        Text('📊')
          .fontSize('18fp')
          .margin({ right: '8vp' })
        Text('自动生产结果')
          .fontSize('17fp')
          .fontColor('#0369A1')
          .fontWeight(FontWeight.Bold)
        Blank()
        Text('整线自动完成')
          .fontSize('12fp')
          .fontColor('#0369A1')
          .padding({ left: '10vp', right: '10vp', top: '4vp', bottom: '4vp' })
          .borderRadius('8vp')
          .backgroundColor('#E0F2FE')
      }
      .width('100%')
      .margin({ bottom: '16vp' })

      Row() {
        Column() {
          Text('总产出')
            .fontSize('14fp')
            .fontColor('#64748B')
            .margin({ bottom: '8vp' })
          Text(((this.viewModel.order!.goodQty || 0) + (this.viewModel.order!.ngQty || 0)).toString())
            .fontSize('24fp')
            .fontColor('#0369A1')
            .fontWeight(FontWeight.Bold)
        }
        .layoutWeight(1)
        .padding({ top: '16vp', bottom: '16vp' })
        .borderRadius('16vp')
        .backgroundColor('#FFFFFF')
        .border({ width: '1.5vp', color: '#7DD3FC' })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        Blank().width('12vp')

        Column() {
          Text('良品')
            .fontSize('14fp')
            .fontColor('#64748B')
            .margin({ bottom: '8vp' })
          Text((this.viewModel.order!.goodQty || 0).toString())
            .fontSize('24fp')
            .fontColor('#059669')
            .fontWeight(FontWeight.Bold)
        }
        .layoutWeight(1)
        .padding({ top: '16vp', bottom: '16vp' })
        .borderRadius('16vp')
        .backgroundColor('#FFFFFF')
        .border({ width: '1.5vp', color: '#6EE7B7' })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        Blank().width('12vp')

        Column() {
          Text('NG')
            .fontSize('14fp')
            .fontColor('#64748B')
            .margin({ bottom: '8vp' })
          Text((this.viewModel.order!.ngQty || 0).toString())
            .fontSize('24fp')
            .fontColor('#DC2626')
            .fontWeight(FontWeight.Bold)
        }
        .layoutWeight(1)
        .padding({ top: '16vp', bottom: '16vp' })
        .borderRadius('16vp')
        .backgroundColor('#FFFFFF')
        .border({ width: '1.5vp', color: '#FCA5A5' })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .margin({ bottom: '12vp' })

      Row() {
        Column() {
          Text('产出率')
            .fontSize('13fp')
            .fontColor('#64748B')
            .margin({ bottom: '6vp' })
          Text(this.viewModel.calculateOutputRate())
            .fontSize('20fp')
            .fontColor('#059669')
            .fontWeight(FontWeight.Bold)
        }
        .layoutWeight(1)
        .padding({ top: '14vp', bottom: '14vp' })
        .borderRadius('14vp')
        .backgroundColor('#ECFDF5')
        .border({ width: '1vp', color: '#6EE7B7' })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        Blank().width('12vp')

        Column() {
          Text('良品率')
            .fontSize('13fp')
            .fontColor('#64748B')
            .margin({ bottom: '6vp' })
          Text(this.viewModel.calculateGoodRate())
            .fontSize('20fp')
            .fontColor('#059669')
            .fontWeight(FontWeight.Bold)
        }
        .layoutWeight(1)
        .padding({ top: '14vp', bottom: '14vp' })
        .borderRadius('14vp')
        .backgroundColor('#ECFDF5')
        .border({ width: '1vp', color: '#6EE7B7' })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        Blank().width('12vp')

        Column() {
          Text('运行时长')
            .fontSize('13fp')
            .fontColor('#64748B')
            .margin({ bottom: '6vp' })
          Text((this.viewModel.order!.reportedHours || 0).toString() + 'h')
            .fontSize('20fp')
            .fontColor('#0369A1')
            .fontWeight(FontWeight.Bold)
        }
        .layoutWeight(1)
        .padding({ top: '14vp', bottom: '14vp' })
        .borderRadius('14vp')
        .backgroundColor('#E0F2FE')
        .border({ width: '1vp', color: '#7DD3FC' })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
    }
    .width('100%')
    .padding('20vp')
    .borderRadius('20vp')
    .backgroundColor('#F0F9FF')
    .border({ width: '1.5vp', color: '#7DD3FC' })
    .margin({ top: '12vp' })
  }

  @Builder
  buildReportFormCard() {
    Column() {
      Row() {
        Text('📝')
          .fontSize('18fp')
          .margin({ right: '8vp' })
        Text('报工')
          .fontSize('17fp')
          .fontColor('#065F46')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .margin({ bottom: '8vp' })

      Text('生产已完成，请录入实际工时及生产数量（工时为核心，数量为佐证）')
        .fontSize('14fp')
        .fontColor('#047857')
        .width('100%')
        .margin({ bottom: '16vp' })

      Row() {
        Column() {
          Text('实际工时（小时）')
            .fontSize('14fp')
            .fontColor('#6B7280')
            .width('100%')
            .margin({ bottom: '6vp' })
          TextInput({ text: this.viewModel.reportHours })
            .width('100%')
            .height('52vp')
            .backgroundColor('#FFFFFF')
            .borderRadius('14vp')
            .fontSize('17fp')
            .fontColor('#1F2937')
            .fontWeight(FontWeight.Bold)
            .border({ width: '2vp', color: '#6EE7B7' })
            .padding({ left: '14vp', right: '14vp' })
            .onChange((value: string) => {
              this.viewModel.reportHours = value;
            })
        }
        .layoutWeight(1)

        Blank().width('12vp')

        Column() {
          Text('计划数量')
            .fontSize('14fp')
            .fontColor('#6B7280')
            .width('100%')
            .margin({ bottom: '6vp' })
          TextInput({ text: this.viewModel.order!.planQty.toString() })
            .width('100%')
            .height('52vp')
            .backgroundColor('#F3F4F6')
            .borderRadius('14vp')
            .fontSize('17fp')
            .fontColor('#6B7280')
            .fontWeight(FontWeight.Bold)
            .border({ width: '1vp', color: '#D1D5DB' })
            .padding({ left: '14vp', right: '14vp' })
            .enabled(false)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: '14vp' })

      Row() {
        Column() {
          Text('良品数量')
            .fontSize('14fp')
            .fontColor('#6B7280')
            .width('100%')
            .margin({ bottom: '6vp' })
          TextInput({ text: this.viewModel.reportGoodQty })
            .width('100%')
            .height('52vp')
            .backgroundColor('#FFFFFF')
            .borderRadius('14vp')
            .fontSize('17fp')
            .fontColor('#1F2937')
            .border({ width: '1vp', color: '#A7F3D0' })
            .padding({ left: '14vp', right: '14vp' })
            .onChange((value: string) => {
              this.viewModel.reportGoodQty = value;
            })
        }
        .layoutWeight(1)

        Blank().width('12vp')

        Column() {
          Text('NG 数量')
            .fontSize('14fp')
            .fontColor('#6B7280')
            .width('100%')
            .margin({ bottom: '6vp' })
          TextInput({ text: this.viewModel.reportNgQty })
            .width('100%')
            .height('52vp')
            .backgroundColor('#FFFFFF')
            .borderRadius('14vp')
            .fontSize('17fp')
            .fontColor('#1F2937')
            .border({ width: '1vp', color: '#FCA5A5' })
            .padding({ left: '14vp', right: '14vp' })
            .onChange((value: string) => {
              this.viewModel.reportNgQty = value;
            })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: '14vp' })

      Row() {
        Column() {
          Text('产出率')
            .fontSize('14fp')
            .fontColor('#6B7280')
            .width('100%')
            .margin({ bottom: '6vp' })
          TextInput({ text: this.calculateOutputRate() })
            .width('100%')
            .height('52vp')
            .backgroundColor('#ECFDF5')
            .borderRadius('14vp')
            .fontSize('17fp')
            .fontColor('#059669')
            .fontWeight(FontWeight.Bold)
            .border({ width: '1vp', color: '#6EE7B7' })
            .padding({ left: '14vp', right: '14vp' })
            .enabled(false)
        }
        .layoutWeight(1)

        Blank().width('12vp')

        Column() {
          Text('良品率')
            .fontSize('14fp')
            .fontColor('#6B7280')
            .width('100%')
            .margin({ bottom: '6vp' })
          TextInput({ text: this.calculateGoodRate() })
            .width('100%')
            .height('52vp')
            .backgroundColor('#ECFDF5')
            .borderRadius('14vp')
            .fontSize('17fp')
            .fontColor('#059669')
            .fontWeight(FontWeight.Bold)
            .border({ width: '1vp', color: '#6EE7B7' })
            .padding({ left: '14vp', right: '14vp' })
            .enabled(false)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: '16vp' })

      Text('故障/异常说明')
        .fontSize('14fp')
        .fontColor('#6B7280')
        .width('100%')
        .margin({ bottom: '8vp' })

      TextArea({ text: this.viewModel.reportRemark, placeholder: '如有异常请说明，若无异常请填写"正常"' })
        .width('100%')
        .height('100vp')
        .backgroundColor('#FFFFFF')
        .borderRadius('16vp')
        .fontSize('15fp')
        .fontColor('#1F2937')
        .border({ width: '1vp', color: '#A7F3D0' })
        .padding('14vp')
        .onChange((value: string) => {
          this.viewModel.reportRemark = value;
        })

      Row() {
        Text('📤')
          .fontSize('18fp')
          .margin({ right: '8vp' })
        Text('提交报工')
          .fontSize('17fp')
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .height('56vp')
      .backgroundColor('#0D9488')
      .borderRadius('20vp')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .margin({ top: '20vp' })
      .onClick(async () => {
        const success = await this.viewModel.submitReport();
        if (success) {
          promptAction.showToast({ message: '报工成功' });
          if (this.navStack) this.navStack.pop();
          if (this.onBack) this.onBack();
        }
      })

      Text('提交后工单状态变为"已报工"，等待质检员抽检')
        .fontSize('13fp')
        .fontColor('#059669')
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: '12vp' })
    }
    .width('100%')
    .padding('20vp')
    .borderRadius('20vp')
    .backgroundColor('#ECFDF5')
    .border({ width: '1.5vp', color: '#6EE7B7' })
    .margin({ top: '12vp' })
  }

  private calculateOutputRate(): string {
    const planQty = parseInt(this.viewModel.order!.planQty.toString()) || 0;
    const goodQty = parseInt(this.viewModel.reportGoodQty) || 0;
    const ngQty = parseInt(this.viewModel.reportNgQty) || 0;
    if (planQty === 0) return '0%';
    return ((goodQty + ngQty) / planQty * 100).toFixed(1) + '%';
  }

  private calculateGoodRate(): string {
    const goodQty = parseInt(this.viewModel.reportGoodQty) || 0;
    const ngQty = parseInt(this.viewModel.reportNgQty) || 0;
    const total = goodQty + ngQty;
    if (total === 0) return '0%';
    return (goodQty / total * 100).toFixed(1) + '%';
  }

  @Builder
  buildResultRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize('15fp')
        .fontColor('#64748B')
      Blank()
      Text(value)
        .fontSize('15fp')
        .fontColor('#0F172A')
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .height('44vp')
    .alignItems(VerticalAlign.Center)
  }
}
