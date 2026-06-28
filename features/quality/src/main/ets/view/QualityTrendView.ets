import { QualityOverviewViewModel } from '../viewModel/QualityOverviewViewModel';
import { QualityTrendPoint } from '../model/QualityTypes';

@ComponentV2
export struct QualityTrendView {
  @Param viewModel: QualityOverviewViewModel = new QualityOverviewViewModel();
  @Param cardPadding: number = 16;
  @Event onBack?: () => void;

  aboutToAppear(): void {
    this.viewModel.init();
  }

  build() {
    Column() {
      // 顶部标题栏
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
          Text('质量趋势')
            .fontSize('18fp')
            .fontColor('#1A2B3C')
            .fontWeight(FontWeight.Bold)
          Text('近期质量指标变化趋势')
            .fontSize('12fp')
            .fontColor('#6B7B8C')
            .margin({ top: '2vp' })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: this.cardPadding, right: this.cardPadding, top: '16vp', bottom: '12vp' })

      Scroll() {
        Column() {
          // 趋势概览统计
          this.buildTrendSummary()

          // 合格率趋势图（柱状图模拟）
          this.buildPassRateTrend()

          // 缺陷数量趋势
          this.buildDefectTrend()

          // 检验数量趋势
          this.buildInspectionTrend()

          // 月度对比
          this.buildMonthlyComparison()

          Blank().height('20vp')
        }
        .width('100%')
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

  @Builder
  buildTrendSummary() {
    Row() {
      Column() {
        Text(this.viewModel.overview.yearToDatePassRate.toString() + '%')
          .fontSize('28fp')
          .fontColor('#4CAF50')
          .fontWeight(FontWeight.Bold)
        Text('年累计合格率')
          .fontSize('11fp')
          .fontColor('#6B7B8C')
          .margin({ top: '4vp' })
      }
      .layoutWeight(1)
      .height('80vp')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .borderRadius('12vp')
      .backgroundColor('#FFFFFF')

      Column() {
        Text(this.viewModel.overview.lastMonthPassRate.toString() + '%')
          .fontSize('28fp')
          .fontColor('#007DFF')
          .fontWeight(FontWeight.Bold)
        Text('上月合格率')
          .fontSize('11fp')
          .fontColor('#6B7B8C')
          .margin({ top: '4vp' })
      }
      .layoutWeight(1)
      .height('80vp')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .borderRadius('12vp')
      .backgroundColor('#FFFFFF')
      .margin({ left: '8vp' })

      Column() {
        Text(this.viewModel.overview.defectRate.toString() + '%')
          .fontSize('28fp')
          .fontColor('#F44336')
          .fontWeight(FontWeight.Bold)
        Text('本月不良率')
          .fontSize('11fp')
          .fontColor('#6B7B8C')
          .margin({ top: '4vp' })
      }
      .layoutWeight(1)
      .height('80vp')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .borderRadius('12vp')
      .backgroundColor('#FFFFFF')
      .margin({ left: '8vp' })
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '8vp', bottom: '8vp' })
  }

  @Builder
  buildPassRateTrend() {
    Column() {
      Text('合格率趋势（近7天）')
        .fontSize('16fp')
        .fontColor('#1A2B3C')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: '12vp' })

      // 柱状图模拟
      Row() {
        ForEach(this.viewModel.trendData, (point: QualityTrendPoint) => {
          Column() {
            Text(point.passRate.toString() + '%')
              .fontSize('10fp')
              .fontColor('#4CAF50')
              .fontWeight(FontWeight.Medium)

            Column()
              .width('28vp')
              .height((point.passRate * 2).toString() + 'vp')
              .borderRadius('4vp')
              .backgroundColor(point.passRate >= 96 ? '#4CAF50' : point.passRate >= 95 ? '#FF9800' : '#F44336')
              .margin({ top: '4vp' })

            Text(point.date)
              .fontSize('10fp')
              .fontColor('#6B7B8C')
              .margin({ top: '6vp' })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        })
      }
      .width('100%')
      .height('180vp')
      .alignItems(VerticalAlign.Bottom)

      // 平均线
      Row() {
        Text('——— 均值线 ' + this.viewModel.overview.passRate.toString() + '%')
          .fontSize('11fp')
          .fontColor('#FF9800')
      }
      .width('100%')
      .margin({ top: '8vp' })
    }
    .width('100%')
    .padding('14vp')
    .borderRadius('12vp')
    .backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp', bottom: '8vp' })
    .shadow({ radius: 4, color: '#0F000000', offsetY: 1 })
  }

  @Builder
  buildDefectTrend() {
    Column() {
      Text('缺陷数量趋势（近7天）')
        .fontSize('16fp')
        .fontColor('#1A2B3C')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: '12vp' })

      Column() {
        ForEach(this.viewModel.trendData, (point: QualityTrendPoint) => {
          Row() {
            Text(point.date)
              .fontSize('12fp')
              .fontColor('#6B7B8C')
              .width('50vp')

            Row() {
              Row()
                .width((point.defectCount * 3).toString() + '%')
                .height('22vp')
                .borderRadius('4vp')
                .backgroundColor(point.defectCount >= 18 ? '#F44336' : point.defectCount >= 15 ? '#FF9800' : '#4CAF50')
              Blank()
            }
            .layoutWeight(1)
            .height('22vp')
            .borderRadius('4vp')
            .backgroundColor('#F0F2F5')

            Text(point.defectCount.toString())
              .fontSize('14fp')
              .fontColor('#1A2B3C')
              .fontWeight(FontWeight.Bold)
              .width('30vp')
              .textAlign(TextAlign.End)
              .margin({ left: '8vp' })
          }
          .width('100%')
          .margin({ bottom: '8vp' })
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding('14vp')
    .borderRadius('12vp')
    .backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp', bottom: '8vp' })
    .shadow({ radius: 4, color: '#0F000000', offsetY: 1 })
  }

  @Builder
  buildInspectionTrend() {
    Column() {
      Text('检验数量趋势（近7天）')
        .fontSize('16fp')
        .fontColor('#1A2B3C')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: '12vp' })

      // 折线图模拟 - 用连接柱状表示
      Column() {
        ForEach(this.viewModel.trendData, (point: QualityTrendPoint) => {
          Row() {
            Text(point.date)
              .fontSize('12fp')
              .fontColor('#6B7B8C')
              .width('50vp')

            Row() {
              Row()
                .width((point.inspectedCount / 5).toString() + '%')
                .height('22vp')
                .borderRadius('4vp')
                .backgroundColor('#2196F3')
              Blank()
            }
            .layoutWeight(1)
            .height('22vp')
            .borderRadius('4vp')
            .backgroundColor('#F0F2F5')

            Text(point.inspectedCount.toString())
              .fontSize('14fp')
              .fontColor('#1A2B3C')
              .fontWeight(FontWeight.Bold)
              .width('40vp')
              .textAlign(TextAlign.End)
              .margin({ left: '8vp' })
          }
          .width('100%')
          .margin({ bottom: '8vp' })
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding('14vp')
    .borderRadius('12vp')
    .backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp', bottom: '8vp' })
    .shadow({ radius: 4, color: '#0F000000', offsetY: 1 })
  }

  @Builder
  buildMonthlyComparison() {
    Column() {
      Text('月度对比')
        .fontSize('16fp')
        .fontColor('#1A2B3C')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: '10vp' })

      Row() {
        Column() {
          Text('本月合格率')
            .fontSize('12fp')
            .fontColor('#6B7B8C')
          Text(this.viewModel.overview.passRate.toString() + '%')
            .fontSize('24fp')
            .fontColor('#4CAF50')
            .fontWeight(FontWeight.Bold)
            .margin({ top: '6vp' })
          Text('↑ 较上月 +0.3%')
            .fontSize('11fp')
            .fontColor('#4CAF50')
            .margin({ top: '4vp' })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .padding('16vp')
        .borderRadius('10vp')
        .backgroundColor('#E8F5E9')

        Column() {
          Text('本月不良数')
            .fontSize('12fp')
            .fontColor('#6B7B8C')
          Text(this.viewModel.overview.monthlyDefect.toString())
            .fontSize('24fp')
            .fontColor('#F44336')
            .fontWeight(FontWeight.Bold)
            .margin({ top: '6vp' })
          Text('↓ 较上月 -8')
            .fontSize('11fp')
            .fontColor('#4CAF50')
            .margin({ top: '4vp' })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .padding('16vp')
        .borderRadius('10vp')
        .backgroundColor('#FFEBEE')
        .margin({ left: '8vp' })
      }
      .width('100%')
    }
    .width('100%')
    .padding('14vp')
    .borderRadius('12vp')
    .backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp', bottom: '8vp' })
    .shadow({ radius: 4, color: '#0F000000', offsetY: 1 })
  }
}
