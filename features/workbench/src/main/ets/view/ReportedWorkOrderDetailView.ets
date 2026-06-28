@ComponentV2
export struct ReportedWorkOrderDetailView {
  @Param cardPadding: number = 16;
  @Event onBack?: () => void;
  @Local orderId: number = 1;

  // 弹窗状态
  @Local showConfirmDialog: boolean = false;
  @Local confirmAction: string = '';
  @Local confirmLabel: string = '';

  aboutToAppear(): void {
    // 加载工单数据
  }

  build() {
    Stack() {
      Column() {
        // 顶部标题
        Row() {
          Column() {
            Text('‹').fontSize('24fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold)
          }
          .width('36vp').height('36vp').borderRadius('18vp').backgroundColor('#FFFFFF')
          .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          .margin({ right: '12vp' })
          .onClick(() => { this.onBack?.(); })

          Column() {
            Text('工单详情').fontSize('18fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold)
            Text('已报工 · 待质检').fontSize('12fp').fontColor('#6B7B8C').margin({ top: '2vp' })
          }
          .alignItems(HorizontalAlign.Start).layoutWeight(1)
        }
        .width('100%')
        .padding({ left: this.cardPadding, right: this.cardPadding, top: '16vp', bottom: '12vp' })

        Scroll() {
          Column() {
            // 1. 产品标题区
            this.buildProductHeader()

            // 2. 工单信息卡片
            this.buildWorkOrderInfo()

            // 3. 时间信息卡片
            this.buildTimeInfo()

            // 4. 报工数据卡片
            this.buildReportData()

            // 5. 异常说明
            this.buildExceptionNote()

            // 6. 质检状态区
            this.buildQCStatus()

            // 7. 操作按钮区
            this.buildActionButtons()

            // 8. 状态流转图
            this.buildStatusFlow()

            Blank().height('20vp')
          }
          .width('100%')
        }
        .layoutWeight(1).scrollBar(BarState.Off).backgroundColor('#E8EDF2')
      }
      .width('100%').height('100%').backgroundColor('#E8EDF2')

      // 二次确认弹窗
      if (this.showConfirmDialog) {
        this.buildConfirmDialog()
      }
    }
    .width('100%').height('100%')
  }

  // ========= 1. 产品标题区 =========
  @Builder
  buildProductHeader() {
    Column() {
      Text('无线充电器组装')
        .fontSize('22fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold).width('100%')
      Text('PROD-WC-001')
        .fontSize('13fp').fontColor('#6B7B8C').width('100%').margin({ top: '4vp' })
    }
    .width('100%').padding('16vp').borderRadius('12vp').backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp' })
  }

  // ========= 2. 工单信息卡片 =========
  @Builder
  buildWorkOrderInfo() {
    Column() {
      Text('工单信息').fontSize('16fp').fontColor('#1A2B3C').fontWeight(FontWeight.Medium)
        .width('100%').margin({ bottom: '10vp' })

      Grid() {
        GridItem() { this.buildInfoCell('工单类型', '量产') }
        GridItem() { this.buildInfoCell('计划数量', '100') }
        GridItem() { this.buildInfoCell('车间', '柔性车间') }
        GridItem() { this.buildInfoCell('资源', '柔性线') }
        GridItem() { this.buildInfoCell('操作员', '刘伟') }
      }
      .width('100%').columnsTemplate('1fr 1fr').columnsGap('10vp').rowsGap('8vp')
    }
    .width('100%').padding('14vp').borderRadius('12vp').backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp' })
    .shadow({ radius: 3, color: '#0F000000', offsetY: 1 })
  }

  @Builder
  buildInfoCell(label: string, value: string) {
    Column() {
      Text(label).fontSize('10fp').fontColor('#999999')
      Text(value).fontSize('14fp').fontColor('#1A2B3C').fontWeight(FontWeight.Medium).margin({ top: '4vp' })
    }
    .width('100%').padding('10vp').borderRadius('8vp').backgroundColor('#F8F9FB')
    .alignItems(HorizontalAlign.Start)
  }

  // ========= 3. 时间信息卡片 =========
  @Builder
  buildTimeInfo() {
    Column() {
      Text('时间信息').fontSize('16fp').fontColor('#1A2B3C').fontWeight(FontWeight.Medium)
        .width('100%').margin({ bottom: '10vp' })

      this.buildTimeRow('实际开始时间', '2026-05-01 08:05')
      this.buildTimeRow('实际完成时间', '2026-05-01 09:55')
      this.buildTimeRow('计划开始时间', '2026-05-01 08:00')
      this.buildTimeRow('计划结束时间', '2026-05-01 18:00')
    }
    .width('100%').padding('14vp').borderRadius('12vp').backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp' })
    .shadow({ radius: 3, color: '#0F000000', offsetY: 1 })
  }

  @Builder
  buildTimeRow(label: string, value: string) {
    Row() {
      Text(label).fontSize('12fp').fontColor('#6B7B8C').width('100vp')
      Text(value).fontSize('13fp').fontColor('#1A2B3C').fontWeight(FontWeight.Medium).layoutWeight(1)
    }
    .width('100%').padding({ top: '8vp', bottom: '8vp' })
    .border({ width: { bottom: '0.5vp' }, color: '#F0F2F5' })
  }

  // ========= 4. 报工数据卡片 =========
  @Builder
  buildReportData() {
    Column() {
      Text('报工数据').fontSize('16fp').fontColor('#1A2B3C').fontWeight(FontWeight.Medium)
        .width('100%').margin({ bottom: '10vp' })

      Row() {
        Column() {
          Text('申报工时').fontSize('11fp').fontColor('#6B7B8C')
          Text('1.8h').fontSize('26fp').fontColor('#007DFF').fontWeight(FontWeight.Bold).margin({ top: '6vp' })
        }
        .layoutWeight(1).height('80vp')
        .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        .borderRadius('10vp').backgroundColor('#E3F2FD')

        Column() {
          Text('良品').fontSize('11fp').fontColor('#6B7B8C')
          Text('96').fontSize('26fp').fontColor('#4CAF50').fontWeight(FontWeight.Bold).margin({ top: '6vp' })
        }
        .layoutWeight(1).height('80vp')
        .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        .borderRadius('10vp').backgroundColor('#E8F5E9')
        .margin({ left: '8vp', right: '8vp' })

        Column() {
          Text('NG').fontSize('11fp').fontColor('#6B7B8C')
          Text('4').fontSize('26fp').fontColor('#F44336').fontWeight(FontWeight.Bold).margin({ top: '6vp' })
        }
        .layoutWeight(1).height('80vp')
        .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        .borderRadius('10vp').backgroundColor('#FFEBEE')
      }
      .width('100%')
    }
    .width('100%').padding('14vp').borderRadius('12vp').backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp' })
    .shadow({ radius: 3, color: '#0F000000', offsetY: 1 })
  }

  // ========= 5. 异常说明 =========
  @Builder
  buildExceptionNote() {
    Row() {
      Text('⚠').fontSize('16fp').margin({ right: '8vp' })
      Text('生产完成后存在 1 次整线停止，已由班组长确认恢复。')
        .fontSize('12fp').fontColor('#6B7B8C').layoutWeight(1)
    }
    .width('100%').padding('14vp').borderRadius('10vp').backgroundColor('#FFF8E1')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp' })
  }

  // ========= 6. 质检状态区 =========
  @Builder
  buildQCStatus() {
    Column() {
      Row() {
        Text('质检状态').fontSize('16fp').fontColor('#1A2B3C').fontWeight(FontWeight.Medium)
        Blank()
        Text('待抽检')
          .fontSize('12fp').fontColor('#FF9800').fontWeight(FontWeight.Bold)
          .padding({ left: '12vp', right: '12vp', top: '4vp', bottom: '4vp' })
          .borderRadius('8vp')
          .backgroundColor('#FFF3E0')
      }
      .width('100%').margin({ bottom: '10vp' })

      Text('质检员尚未完成抽检，抽检后班组长可确认工时')
        .fontSize('12fp').fontColor('#6B7B8C').width('100%')
    }
    .width('100%').padding('14vp').borderRadius('12vp').backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp' })
    .shadow({ radius: 3, color: '#0F000000', offsetY: 1 })
  }

  // ========= 7. 操作按钮区 =========
  @Builder
  buildActionButtons() {
    Column() {
      Row() {
        Button() {
          Text('确认完工').fontSize('15fp').fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1).height('44vp').borderRadius('8vp').backgroundColor('#007DFF')
        .margin({ right: '8vp' })
        .onClick(() => {
          this.confirmAction = 'complete';
          this.confirmLabel = '确认完工';
          this.showConfirmDialog = true;
        })

        Button() {
          Text('报废').fontSize('15fp').fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1).height('44vp').borderRadius('8vp').backgroundColor('#F44336')
        .onClick(() => {
          this.confirmAction = 'scrap';
          this.confirmLabel = '报废';
          this.showConfirmDialog = true;
        })
      }
      .width('100%')

      Text('班组长审核报工数据，确认工时后工单完结')
        .fontSize('11fp').fontColor('#6B7B8C').width('100%').margin({ top: '10vp' })
    }
    .width('100%').padding('14vp').borderRadius('12vp').backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp' })
    .shadow({ radius: 3, color: '#0F000000', offsetY: 1 })
  }

  // ========= 8. 状态流转图 =========
  @Builder
  buildStatusFlow() {
    Column() {
      Text('状态流转').fontSize('16fp').fontColor('#1A2B3C').fontWeight(FontWeight.Medium)
        .width('100%').margin({ bottom: '12vp' })

      Row() {
        this.buildFlowStep('待派工', true)
        this.buildFlowArrow()
        this.buildFlowStep('已派工', true)
        this.buildFlowArrow()
        this.buildFlowStep('生产中', true)
        this.buildFlowArrow()
        this.buildFlowStep('生产完成', true)
        this.buildFlowArrow()
        this.buildFlowStep('已报工', false)
        this.buildFlowArrow()
        this.buildFlowStep('完工/报废', true)
      }
      .width('100%')
    }
    .width('100%').padding('14vp').borderRadius('12vp').backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp' })
    .shadow({ radius: 3, color: '#0F000000', offsetY: 1 })
  }

  @Builder
  buildFlowStep(label: string, completed: boolean) {
    Text(label)
      .fontSize('10fp')
      .fontColor(completed ? '#FFFFFF' : '#FFFFFF')
      .fontWeight(completed ? FontWeight.Normal : FontWeight.Bold)
      .padding({ left: '6vp', right: '6vp', top: '3vp', bottom: '3vp' })
      .borderRadius('6vp')
      .backgroundColor(completed ? '#B0BEC5' : '#FF9800')
  }

  @Builder
  buildFlowArrow() {
    Text('→').fontSize('10fp').fontColor('#B0BEC5').margin({ left: '2vp', right: '2vp' })
  }

  // ========= 确认弹窗 =========
  @Builder
  buildConfirmDialog() {
    Column() {
      Column() {
        Text('确认操作').fontSize('18fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold)
          .margin({ bottom: '12vp' })
        Text('确认' + this.confirmLabel + '该工单？').fontSize('14fp').fontColor('#6B7B8C')
          .margin({ bottom: '6vp' })
        Text('此操作不可撤销').fontSize('13fp').fontColor('#F44336')
          .margin({ bottom: '20vp' })

        Row() {
          Button() {
            Text('取消').fontSize('15fp').fontColor('#666666').fontWeight(FontWeight.Medium)
          }
          .layoutWeight(1).height('44vp').borderRadius('8vp').backgroundColor('#F0F0F0')
          .margin({ right: '10vp' })
          .onClick(() => { this.showConfirmDialog = false; })

          Button() {
            Text('确认').fontSize('15fp').fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
          }
          .layoutWeight(1).height('44vp').borderRadius('8vp')
          .backgroundColor(this.confirmAction === 'scrap' ? '#F44336' : '#007DFF')
          .onClick(() => {
            this.showConfirmDialog = false;
            // 状态变更逻辑
          })
        }
        .width('100%')
      }
      .width('80%').padding('24vp').borderRadius('16vp').backgroundColor('#FFFFFF')
      .shadow({ radius: 20, color: '#30000000' })
    }
    .width('100%').height('100%')
    .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
    .backgroundColor('#60000000')
    .onClick(() => { this.showConfirmDialog = false; })
  }
}
