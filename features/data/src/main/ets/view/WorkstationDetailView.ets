import { WorkstationDetailViewModel } from '../viewModel/WorkstationDetailViewModel';
import { WorkstationFullDetail } from '../model/DataTypes';

@ComponentV2
export struct WorkstationDetailView {
  @Param viewModel: WorkstationDetailViewModel = new WorkstationDetailViewModel();
  @Param stationId: number = 0;
  @Param cardPadding: number = 16;
  @Event onBack?: () => void;

  aboutToAppear(): void {
    this.viewModel.init(this.stationId);
  }

  build() {
    Stack() {
      Column() {
        this.buildHeader()

        if (this.viewModel.detail) {
          Scroll() {
            Column() {
              this.buildTaskCard(this.viewModel.detail)
              this.buildWorkstationInfo(this.viewModel.detail)
              this.buildDeviceStatus(this.viewModel.detail)
              this.buildProcessedCount(this.viewModel.detail)
              this.buildOutputStats(this.viewModel.detail)
              this.buildActionButtons()
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
      }
      .width('100%').height('100%')
      .backgroundColor('#E8EDF2')

      // Toast
      if (this.viewModel.showToast) {
        Column() {
          Text(this.viewModel.toastMsg)
            .fontSize('14fp').fontColor('#FFFFFF')
            .padding({ left: '20vp', right: '20vp', top: '10vp', bottom: '10vp' })
            .borderRadius('20vp').backgroundColor('#CC000000')
        }
        .width('100%').position({ x: 0, y: '70%' }).alignItems(HorizontalAlign.Center)
      }

      // 启停/复位确认弹窗
      if (this.viewModel.showConfirmDialog) {
        this.buildConfirmDialog()
      }

      // 异常上报弹窗（点击外部不关闭）
      if (this.viewModel.showExceptionDialog) {
        this.buildExceptionDialog()
      }
    }
    .width('100%').height('100%')
  }

  // =========== Header ===========
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
        Text('工作站详情').fontSize('18fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold)
        Text(this.viewModel.detail
          ? this.viewModel.detail.lineName + ' · ' + this.viewModel.detail.code + ' ' + this.viewModel.detail.name
          : '')
          .fontSize('12fp').fontColor('#6B7B8C').margin({ top: '2vp' })
      }
      .alignItems(HorizontalAlign.Start).layoutWeight(1)
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '16vp', bottom: '12vp' })
  }

  // =========== 1. 当前生产任务 ===========
  @Builder
  buildTaskCard(detail: WorkstationFullDetail) {
    Column() {
      Text('当前生产任务').fontSize('16fp').fontColor('#1A2B3C').fontWeight(FontWeight.Medium)
        .width('100%').margin({ bottom: '10vp' })
      Row() {
        Column() {
          Text(detail.workorderCode).fontSize('20fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold)
          Text(detail.productName).fontSize('13fp').fontColor('#666666').margin({ top: '4vp' })
        }
        .layoutWeight(1).alignItems(HorizontalAlign.Start)
        Column() {
          Text(detail.operatorName).fontSize('14fp').fontColor('#1A2B3C').fontWeight(FontWeight.Medium)
          Text(detail.workorderStatus).fontSize('13fp')
            .fontColor(detail.workorderStatus === '生产中' ? '#4CAF50'
              : detail.workorderStatus === '暂停中' ? '#FF9800' : '#999999')
            .fontWeight(FontWeight.Bold).margin({ top: '4vp' })
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
    }
    .width('100%').padding('14vp').borderRadius('12vp').backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp' })
    .shadow({ radius: 4, color: '#0F000000', offsetY: 1 })
  }

  // =========== 2. 工作站信息 2x2 ===========
  @Builder
  buildWorkstationInfo(detail: WorkstationFullDetail) {
    Column() {
      Text('工作站信息').fontSize('16fp').fontColor('#1A2B3C').fontWeight(FontWeight.Medium)
        .width('100%').margin({ bottom: '10vp' })
      Grid() {
        GridItem() { this.buildInfoItem('工作站名称', detail.code + ' ' + detail.name) }
        GridItem() { this.buildInfoItem('设备编码', detail.deviceCode) }
        GridItem() { this.buildInfoItem('所属产线', detail.lineName) }
        GridItem() { this.buildInfoItem('当前工艺', detail.currentProcess) }
      }
      .width('100%').columnsTemplate('1fr 1fr').columnsGap('12vp').rowsGap('10vp')
    }
    .width('100%').padding('14vp').borderRadius('12vp').backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp' })
    .shadow({ radius: 4, color: '#0F000000', offsetY: 1 })
  }

  @Builder
  buildInfoItem(label: string, value: string) {
    Column() {
      Text(label).fontSize('10fp').fontColor('#999999')
      Text(value).fontSize('13fp').fontColor('#1A2B3C').fontWeight(FontWeight.Medium).margin({ top: '4vp' })
    }
    .width('100%').padding('10vp').borderRadius('8vp').backgroundColor('#F8F9FB')
    .alignItems(HorizontalAlign.Start)
  }

  // =========== 3. 设备状态 3列 ===========
  @Builder
  buildDeviceStatus(detail: WorkstationFullDetail) {
    Column() {
      Text('设备状态').fontSize('16fp').fontColor('#1A2B3C').fontWeight(FontWeight.Medium)
        .width('100%').margin({ bottom: '10vp' })

      Row() {
        // 设备状态
        Column() {
          Row() {
            Row().width('8vp').height('8vp').borderRadius('4vp')
              .backgroundColor(this.viewModel.getDeviceStatusDotColor()).margin({ right: '6vp' })
            Text(detail.deviceStatus)
              .fontSize('16fp').fontColor(this.viewModel.getStatusColor(detail.deviceStatus)).fontWeight(FontWeight.Bold)
          }
          .width('100%').margin({ bottom: '6vp' })
          Text(detail.deviceStatusDesc).fontSize('11fp').fontColor('#6B7B8C')
        }
        .layoutWeight(1).padding('12vp').borderRadius('10vp').backgroundColor('#F8F9FB')
        .alignItems(HorizontalAlign.Start)

        // 工作状态
        Column() {
          Row() {
            Row().width('8vp').height('8vp').borderRadius('4vp')
              .backgroundColor(this.viewModel.getStatusColor(detail.workStatus)).margin({ right: '6vp' })
            Text(detail.workStatus)
              .fontSize('16fp').fontColor(this.viewModel.getStatusColor(detail.workStatus)).fontWeight(FontWeight.Bold)
          }
          .width('100%').margin({ bottom: '6vp' })
          Text(detail.workActionDesc).fontSize('11fp').fontColor('#6B7B8C')
        }
        .layoutWeight(1).padding('12vp').borderRadius('10vp').backgroundColor('#F8F9FB')
        .alignItems(HorizontalAlign.Start).margin({ left: '8vp' })

        // 传送带
        Column() {
          Row() {
            Row().width('8vp').height('8vp').borderRadius('4vp')
              .backgroundColor(this.viewModel.getStatusColor(detail.conveyorDirection)).margin({ right: '6vp' })
            Text(detail.conveyorDirection)
              .fontSize('16fp').fontColor(this.viewModel.getStatusColor(detail.conveyorDirection)).fontWeight(FontWeight.Bold)
          }
          .width('100%').margin({ bottom: '6vp' })
          Text(detail.conveyorDesc).fontSize('11fp').fontColor('#6B7B8C')
        }
        .layoutWeight(1).padding('12vp').borderRadius('10vp').backgroundColor('#F8F9FB')
        .alignItems(HorizontalAlign.Start).margin({ left: '8vp' })
      }
      .width('100%')
    }
    .width('100%').padding('14vp').borderRadius('12vp').backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp' })
    .shadow({ radius: 4, color: '#0F000000', offsetY: 1 })
  }

  // =========== 4. 已加工件数 ===========
  @Builder
  buildProcessedCount(detail: WorkstationFullDetail) {
    Column() {
      Text('已加工件数').fontSize('16fp').fontColor('#1A2B3C').fontWeight(FontWeight.Medium)
        .width('100%').margin({ bottom: '10vp' })
      Row() {
        Column() {
          Text(this.viewModel.runState === 'reset' ? '--' : detail.processedCount.toString())
            .fontSize(this.viewModel.runState === 'reset' ? '36fp' : '42fp')
            .fontColor(this.viewModel.runState === 'reset' ? '#999999' : '#007DFF').fontWeight(FontWeight.Bold)
          Text(this.viewModel.runState === 'reset' ? '复位后需重新计数' : '当前批次累计加工')
            .fontSize('12fp').fontColor('#6B7B8C').margin({ top: '6vp' })
          Text('加工节拍: ' + detail.processingTime)
            .fontSize('11fp').fontColor('#999999').margin({ top: '4vp' })
        }
        .layoutWeight(1).alignItems(HorizontalAlign.Center).padding('20vp')
        .borderRadius('12vp')
        .backgroundColor(this.viewModel.runState === 'reset' ? '#F5F5F5' : '#E3F2FD')
        .border({ width: '1vp', color: this.viewModel.runState === 'reset' ? '#CCCCCC' : '#007DFF' })
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '8vp' })
  }

  // =========== 5. 产出统计 ===========
  @Builder
  buildOutputStats(detail: WorkstationFullDetail) {
    Column() {
      Text('产出统计').fontSize('16fp').fontColor('#1A2B3C').fontWeight(FontWeight.Medium)
        .width('100%').margin({ bottom: '10vp' })
      Row() {
        this.buildOutputCol('原料',
          this.viewModel.runState === 'reset' ? '--' : detail.rawMaterial.toString(),
          this.viewModel.runState === 'reset' ? '#999999' : '#007DFF',
          this.viewModel.runState === 'reset' ? '#F5F5F5' : '#E3F2FD')
        this.buildOutputCol('成品',
          this.viewModel.runState === 'reset' ? '--' : detail.goodCount.toString(),
          this.viewModel.runState === 'reset' ? '#999999' : '#4CAF50',
          this.viewModel.runState === 'reset' ? '#F5F5F5' : '#E8F5E9')
        this.buildOutputCol('NG',
          this.viewModel.runState === 'reset' ? '--' : detail.ngCount.toString(),
          this.viewModel.runState === 'reset' ? '#999999' : '#F44336',
          this.viewModel.runState === 'reset' ? '#F5F5F5' : '#FFEBEE')
      }
      .width('100%')
    }
    .width('100%').padding('14vp').borderRadius('12vp').backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp' })
    .shadow({ radius: 4, color: '#0F000000', offsetY: 1 })
  }

  @Builder
  buildOutputCol(label: string, val: string, color: string, bg: string) {
    Column() {
      Text(label).fontSize('12fp').fontColor('#6B7B8C')
      Text(val).fontSize('28fp').fontColor(color).fontWeight(FontWeight.Bold).margin({ top: '6vp' })
    }
    .layoutWeight(1).height('90vp')
    .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
    .borderRadius('10vp').backgroundColor(bg)
    .margin({ left: label === '原料' ? '0vp' : '8vp' })
  }

  // =========== 6. 操作按钮 ===========
  @Builder
  buildActionButtons() {
    Row() {
      // 启动
      Button() {
        Text('启动').fontSize('14fp').fontColor(this.viewModel.getBtnTextColor('start')).fontWeight(FontWeight.Medium)
      }
      .layoutWeight(1).height('44vp').borderRadius('8vp')
      .backgroundColor(this.viewModel.getBtnColor('start'))
      .margin({ right: '8vp' })
      .enabled(this.viewModel.isBtnEnabled('start'))
      .onClick(() => { this.viewModel.showActionConfirm('start', '启动'); })

      // 停止
      Button() {
        Text('停止').fontSize('14fp').fontColor(this.viewModel.getBtnTextColor('stop')).fontWeight(FontWeight.Medium)
      }
      .layoutWeight(1).height('44vp').borderRadius('8vp')
      .backgroundColor(this.viewModel.getBtnColor('stop'))
      .margin({ right: '8vp' })
      .enabled(this.viewModel.isBtnEnabled('stop'))
      .onClick(() => { this.viewModel.showActionConfirm('stop', '停止'); })

      // 复位
      Button() {
        Text('复位').fontSize('14fp').fontColor(this.viewModel.getBtnTextColor('reset')).fontWeight(FontWeight.Medium)
      }
      .layoutWeight(1).height('44vp').borderRadius('8vp')
      .backgroundColor(this.viewModel.getBtnColor('reset'))
      .margin({ right: '8vp' })
      .enabled(this.viewModel.isBtnEnabled('reset'))
      .onClick(() => { this.viewModel.showActionConfirm('reset', '复位'); })

      // 异常上报
      Button() {
        Text('异常上报').fontSize('14fp').fontColor(this.viewModel.getBtnTextColor('exception')).fontWeight(FontWeight.Medium)
      }
      .layoutWeight(1).height('44vp').borderRadius('8vp')
      .backgroundColor(this.viewModel.getBtnColor('exception'))
      .enabled(this.viewModel.isBtnEnabled('exception'))
      .onClick(() => { this.viewModel.showExceptionReport(); })
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '12vp' })
  }

  // =========== 确认弹窗 ===========
  @Builder
  buildConfirmDialog() {
    Column() {
      Column() {
        Text('确认操作').fontSize('18fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold)
          .margin({ bottom: '12vp' })
        Text('确认是否更换工作状态？').fontSize('14fp').fontColor('#6B7B8C')
          .margin({ bottom: '6vp' })
        Text(this.viewModel.detail
          ? this.viewModel.detail.code + ' ' + this.viewModel.detail.name + ' → ' + this.viewModel.confirmActionLabel
          : '')
          .fontSize('15fp').fontColor('#1A2B3C').fontWeight(FontWeight.Medium).margin({ bottom: '20vp' })
        Row() {
          Button() {
            Text('取消').fontSize('15fp').fontColor('#666666').fontWeight(FontWeight.Medium)
          }
          .layoutWeight(1).height('44vp').borderRadius('8vp').backgroundColor('#F0F0F0')
          .margin({ right: '10vp' })
          .onClick(() => { this.viewModel.cancelAction(); })

          Button() {
            Text('确认').fontSize('15fp').fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
          }
          .layoutWeight(1).height('44vp').borderRadius('8vp').backgroundColor('#007DFF')
          .onClick(() => { this.viewModel.confirmActionChange(); })
        }
        .width('100%')
      }
      .width('80%').padding('24vp').borderRadius('16vp').backgroundColor('#FFFFFF')
      .shadow({ radius: 20, color: '#30000000' })
    }
    .width('100%').height('100%')
    .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
    .backgroundColor('#60000000')
    .onClick(() => { this.viewModel.cancelAction(); })
  }

  // =========== 异常上报弹窗 ===========
  @Builder
  buildExceptionDialog() {
    Column() {
      // 点击背景不关闭——背景不收点击事件
    }
    .width('100%').height('100%')
    .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
    .backgroundColor('#60000000')

    // 弹窗内容（置于上方）
    Column() {
      Column() {
        Text('异常上报').fontSize('18fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold)
          .margin({ bottom: '16vp' })

        TextInput({ text: this.viewModel.exceptionText, placeholder: '请输入异常描述' })
          .fontSize('14fp').fontColor('#1A2B3C')
          .backgroundColor('#F5F7FA')
          .borderRadius('8vp')
          .height('100vp')
          .padding('12vp')
          .type(InputType.Normal)
          .maxLines(5)
          .onChange((value: string) => { this.viewModel.onExceptionTextChange(value); })

        Row() {
          Button() {
            Text('取消').fontSize('15fp').fontColor('#666666').fontWeight(FontWeight.Medium)
          }
          .layoutWeight(1).height('44vp').borderRadius('8vp').backgroundColor('#F0F0F0')
          .margin({ right: '10vp' })
          .onClick(() => { this.viewModel.cancelException(); })

          Button() {
            Text('提交异常').fontSize('15fp').fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
          }
          .layoutWeight(1).height('44vp').borderRadius('8vp').backgroundColor('#F44336')
          .onClick(() => { this.viewModel.submitException(); })
        }
        .width('100%').margin({ top: '16vp' })
      }
      .width('85%').padding('24vp').borderRadius('16vp')
      .backgroundColor('#FFFFFF').shadow({ radius: 20, color: '#30000000' })
    }
    .width('100%').height('100%')
    .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
    .hitTestBehavior(HitTestMode.Block)
  }
}
