import { ProductionLineDetailViewModel } from '../viewModel/ProductionLineDetailViewModel';
import { LineDetailFull, WorkstationDetail } from '../model/DataTypes';

@ComponentV2
export struct ProductionLineDetailView {
  @Param viewModel: ProductionLineDetailViewModel = new ProductionLineDetailViewModel();
  @Param lineId: number = 1;
  @Param cardPadding: number = 16;
  @Event onBack?: () => void;
  @Event onStationClick?: (stationId: number) => void;

  aboutToAppear(): void {
    this.viewModel.init(this.lineId);
  }

  build() {
    Stack() {
      Column() {
        this.buildHeader()

        Scroll() {
          Column() {
            if (this.viewModel.lineDetail) {
              this.buildLineStatusCard(this.viewModel.lineDetail)
              this.buildStatsRow(this.viewModel.lineDetail)
              this.buildWorkstationGrid()
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

      // 确认弹窗
      if (this.viewModel.showConfirmDialog) {
        this.buildConfirmDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  // ================================================================
  // 确认弹窗
  // ================================================================
  @Builder
  buildConfirmDialog() {
    Column() {
      Column() {
        Text('确认操作')
          .fontSize('18fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold)
          .margin({ bottom: '12vp' })

        Text('确认是否更换工作状态？')
          .fontSize('14fp').fontColor('#6B7B8C')
          .margin({ bottom: '6vp' })

        Text(this.viewModel.confirmStationName + ' → ' + this.viewModel.getConfirmActionLabel())
          .fontSize('15fp').fontColor('#1A2B3C').fontWeight(FontWeight.Medium)
          .margin({ bottom: '20vp' })

        Row() {
          Button() {
            Text('取消')
              .fontSize('15fp').fontColor('#666666').fontWeight(FontWeight.Medium)
          }
          .layoutWeight(1).height('44vp')
          .borderRadius('8vp').backgroundColor('#F0F0F0')
          .margin({ right: '10vp' })
          .onClick(() => { this.viewModel.cancelAction(); })

          Button() {
            Text('确认')
              .fontSize('15fp').fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
          }
          .layoutWeight(1).height('44vp')
          .borderRadius('8vp').backgroundColor('#007DFF')
          .onClick(() => { this.viewModel.confirmActionChange(); })
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
    .onClick(() => { this.viewModel.cancelAction(); })
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
      .onClick(() => { this.onBack?.(); })

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
          .height('180vp')
          .objectFit(ImageFit.Cover)

        Column() {
          Text('当前整线状态')
            .fontSize('18fp').fontColor('#FFFFFF').fontWeight(FontWeight.Bold)
          Text('生产中 · ' + detail.workorderCode + ' · 当前工艺：' + detail.currentProcess)
            .fontSize('11fp').fontColor('rgba(255,255,255,0.85)').margin({ top: '4vp' })
        }
        .padding({ left: '16vp', bottom: '16vp' })

        Row() {
          Text(detail.statusTag)
            .fontSize('11fp').fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
            .padding({ left: '10vp', right: '10vp', top: '4vp', bottom: '4vp' })
            .borderRadius('12vp').backgroundColor('#4CAF50')
        }
        .position({ x: '100%', y: '16vp' })
        .markAnchor({ x: '100%', y: 0 })
        .offset({ x: '-16vp' })
      }
      .width('100%')
    }
    .width('100%')
    .borderRadius('14vp').backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp' })
    .clip(true)
  }

  @Builder
  buildStatsRow(detail: LineDetailFull) {
    Row() {
      Column() {
        Text('当前操作员').fontSize('11fp').fontColor('#6B7B8C')
        Text(detail.operatorName)
          .fontSize('16fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold).margin({ top: '4vp' })
      }
      .layoutWeight(1).height('80vp')
      .borderRadius('12vp').backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)

      Column() {
        Text('工单状态').fontSize('11fp').fontColor('#6B7B8C')
        Text(detail.workorderStatus)
          .fontSize('14fp').fontColor('#4CAF50').fontWeight(FontWeight.Bold).margin({ top: '4vp' })
      }
      .layoutWeight(1).height('80vp')
      .borderRadius('12vp').backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
      .margin({ left: '8vp', right: '8vp' })

      Column() {
        Text('原料 / 成品 / NG').fontSize('10fp').fontColor('#6B7B8C')
        Text(detail.rawMaterial.toString() + ' / ' + detail.finishedProduct.toString() + ' / ' + detail.ngCount.toString())
          .fontSize('13fp').fontColor('#1A2B3C').fontWeight(FontWeight.Medium).margin({ top: '4vp' })
      }
      .layoutWeight(1).height('80vp')
      .borderRadius('12vp').backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '12vp' })
  }

  @Builder
  buildWorkstationGrid() {
    Column() {
      Row() {
        Row() {
          Blank().width('6vp').height('6vp').borderRadius('3vp').backgroundColor('#4CAF50')
          Text('运行状态')
            .fontSize('16fp').fontColor('#1A2B3C').fontWeight(FontWeight.Medium).margin({ left: '8vp' })
        }
        .layoutWeight(1)
        Text(this.viewModel.lineDetail ? this.viewModel.lineDetail.currentProcess : '')
          .fontSize('12fp').fontColor('#6B7B8C')
      }
      .width('100%').margin({ bottom: '12vp' })

      ForEach(this.viewModel.workstationStatusList, (station: WorkstationDetail) => {
        this.buildWorkstationCard(station)
      })
    }
    .width('100%')
    .padding('16vp').borderRadius('14vp').backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '12vp' })
  }

  @Builder
  buildWorkstationCard(station: WorkstationDetail) {
    Column() {
      // 顶部：工作站名 + 状态 + 箭头
      Row() {
        Column() {
          Text(station.code + ' ' + station.name)
            .fontSize('14fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold)
          Text('设备: ' + station.deviceStatus + ' · 工作: ' + station.workStatus)
            .fontSize('11fp').fontColor('#6B7B8C').margin({ top: '2vp' })
          Text('产品: ' + station.productCode + ' · 加工' + station.processingTime)
            .fontSize('11fp').fontColor('#6B7B8C').margin({ top: '2vp' })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Row() {
          Text(station.status)
            .fontSize('11fp').fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
            .padding({ left: '10vp', right: '10vp', top: '4vp', bottom: '4vp' })
            .borderRadius('10vp')
            .backgroundColor(this.viewModel.getStatusBgColor(station.status))
          Text('›')
            .fontSize('16fp').fontColor('#999999').margin({ left: '8vp' })
        }
        .onClick(() => {
          this.onStationClick?.(station.id);
        })
      }
      .width('100%')

      // 操作按钮行
      Row() {
        this.buildMiniActionBtn('启动', '#4CAF50', station)
        this.buildMiniActionBtn('停止', '#FF9800', station)
        this.buildMiniActionBtn('复位', '#F44336', station)
        this.buildMiniActionBtn('异常上报', '#BDBDBD', station)
      }
      .width('100%')
      .margin({ top: '10vp' })
    }
    .width('100%')
    .padding('14vp')
    .borderRadius('10vp')
    .backgroundColor(station.status === '运行中' ? '#F0FFF0' : station.status === '已停止' ? '#FFF3E0' : station.status === '已复位' ? '#FFEBEE' : station.status === '异常' ? '#F5F5F5' : '#F0FFF0')
    .margin({ bottom: '8vp' })
  }

  @Builder
  buildMiniActionBtn(label: string, color: string, station: WorkstationDetail) {
    Text(label)
      .fontSize('10fp')
      .fontColor(label === '异常上报' ? '#757575' : '#FFFFFF')
      .fontWeight(FontWeight.Medium)
      .layoutWeight(1)
      .height('28vp')
      .borderRadius('6vp')
      .backgroundColor(label === '异常上报' ? '#EEEEEE' : color)
      .textAlign(TextAlign.Center)
      .margin({ left: label === '启动' ? '0vp' : '6vp' })
      .onClick(() => {
        const action: string = label === '启动' ? 'start' : label === '停止' ? 'stop' : label === '复位' ? 'reset' : 'exception';
        this.viewModel.showActionConfirm(station.id, station.code + ' ' + station.name, action);
      })
  }
}
