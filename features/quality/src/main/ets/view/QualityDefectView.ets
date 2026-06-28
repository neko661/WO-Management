import { QualityOverviewViewModel } from '../viewModel/QualityOverviewViewModel';
import { DefectCategory, LineQuality } from '../model/QualityTypes';

@ComponentV2
export struct QualityDefectView {
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
          Text('缺陷统计')
            .fontSize('18fp')
            .fontColor('#1A2B3C')
            .fontWeight(FontWeight.Bold)
          Text('按类别与产线查看缺陷数据')
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
          // 缺陷总览统计
          this.buildDefectSummary()

          // 缺陷类别占比 - 环形图方式展示
          this.buildDefectPieSection()

          // 缺陷明细列表
          this.buildDefectDetailList()

          // 各产线缺陷排行
          this.buildLineDefectRanking()

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
  buildDefectSummary() {
    Row() {
      Column() {
        Text(this.viewModel.overview.monthlyDefect.toString())
          .fontSize('36fp')
          .fontColor('#F44336')
          .fontWeight(FontWeight.Bold)
        Text('本月缺陷总数')
          .fontSize('12fp')
          .fontColor('#6B7B8C')
          .margin({ top: '4vp' })
      }
      .layoutWeight(1)
      .height('90vp')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .borderRadius('12vp')
      .backgroundColor('#FFFFFF')
      .margin({ right: '8vp' })
      .shadow({ radius: 4, color: '#0F000000', offsetY: 1 })

      Column() {
        Text(this.viewModel.overview.defectRate.toString() + '%')
          .fontSize('36fp')
          .fontColor('#FF9800')
          .fontWeight(FontWeight.Bold)
        Text('不良率')
          .fontSize('12fp')
          .fontColor('#6B7B8C')
          .margin({ top: '4vp' })
      }
      .layoutWeight(1)
      .height('90vp')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .borderRadius('12vp')
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 4, color: '#0F000000', offsetY: 1 })
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '8vp', bottom: '8vp' })
  }

  @Builder
  buildDefectPieSection() {
    Column() {
      Text('缺陷类别占比')
        .fontSize('16fp')
        .fontColor('#1A2B3C')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: '12vp' })

      // 用条形图 + 色块模拟环形图效果
      Column() {
        ForEach(this.viewModel.defectCategories, (cat: DefectCategory) => {
          Row() {
            // 色块标记
            Row()
              .width('16vp')
              .height('16vp')
              .borderRadius('4vp')
              .backgroundColor(cat.color)
              .margin({ right: '12vp' })

            Column() {
              Text(cat.name)
                .fontSize('14fp')
                .fontColor('#1A2B3C')
                .fontWeight(FontWeight.Medium)
              Row() {
                Text('数量: ' + cat.count.toString())
                  .fontSize('12fp')
                  .fontColor('#6B7B8C')
                Text('  占比: ' + cat.percentage.toString() + '%')
                  .fontSize('12fp')
                  .fontColor('#6B7B8C')
              }
              .width('100%')
              .margin({ top: '2vp' })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Column() {
              Text(cat.trend === 'up' ? '↑ 上升' : cat.trend === 'down' ? '↓ 下降' : '→ 平稳')
                .fontSize('11fp')
                .fontColor(cat.trend === 'up' ? '#F44336' : cat.trend === 'down' ? '#4CAF50' : '#999999')
                .fontWeight(FontWeight.Medium)
            }
            .alignItems(HorizontalAlign.End)
          }
          .width('100%')
          .padding('12vp')
          .borderRadius('10vp')
          .backgroundColor('#F8F9FB')
          .margin({ bottom: '10vp' })
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
  buildDefectDetailList() {
    Column() {
      Text('缺陷明细排行')
        .fontSize('16fp')
        .fontColor('#1A2B3C')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: '10vp' })

      ForEach(this.viewModel.defectCategories, (cat: DefectCategory, index: number) => {
        Row() {
          // 排名序号
          Text((index + 1).toString())
            .fontSize('18fp')
            .fontColor(index < 3 ? '#007DFF' : '#B0BCC8')
            .fontWeight(FontWeight.Bold)
            .width('28vp')
            .textAlign(TextAlign.Center)
            .margin({ right: '8vp' })

          Column() {
            Text(cat.name)
              .fontSize('14fp')
              .fontColor('#1A2B3C')
              .fontWeight(FontWeight.Medium)
            // 进度条
            Row() {
              Row()
                .width(cat.percentage.toString() + '%')
                .height('6vp')
                .borderRadius('3vp')
                .backgroundColor(cat.color)
              Blank()
            }
            .width('100%')
            .height('6vp')
            .borderRadius('3vp')
            .backgroundColor('#F0F2F5')
            .margin({ top: '6vp' })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Column() {
            Text(cat.count.toString())
              .fontSize('18fp')
              .fontColor(cat.color)
              .fontWeight(FontWeight.Bold)
            Text(cat.percentage.toString() + '%')
              .fontSize('11fp')
              .fontColor('#6B7B8C')
          }
          .alignItems(HorizontalAlign.End)
          .margin({ left: '12vp' })
        }
        .width('100%')
        .padding('12vp')
        .borderRadius('10vp')
        .backgroundColor('#F8F9FB')
        .margin({ bottom: '8vp' })
      })
    }
    .width('100%')
    .padding('14vp')
    .borderRadius('12vp')
    .backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp', bottom: '8vp' })
    .shadow({ radius: 4, color: '#0F000000', offsetY: 1 })
  }

  @Builder
  buildLineDefectRanking() {
    Column() {
      Text('各产线缺陷对比')
        .fontSize('16fp')
        .fontColor('#1A2B3C')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: '10vp' })

      ForEach(this.viewModel.lineQualityList, (line: LineQuality) => {
        Row() {
          Column() {
            Text(line.lineName)
              .fontSize('14fp')
              .fontColor('#1A2B3C')
              .fontWeight(FontWeight.Medium)
            Text('主要缺陷: ' + line.topDefect)
              .fontSize('11fp')
              .fontColor('#999999')
              .margin({ top: '2vp' })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Column() {
            Text(line.defectCount.toString())
              .fontSize('20fp')
              .fontColor(line.defectCount > 100 ? '#F44336' : '#FF9800')
              .fontWeight(FontWeight.Bold)
            Text('缺陷数')
              .fontSize('10fp')
              .fontColor('#999999')
          }
          .alignItems(HorizontalAlign.End)
        }
        .width('100%')
        .padding('12vp')
        .borderRadius('8vp')
        .backgroundColor('#F8F9FB')
        .margin({ bottom: '8vp' })
      })
    }
    .width('100%')
    .padding('14vp')
    .borderRadius('12vp')
    .backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp', bottom: '8vp' })
    .shadow({ radius: 4, color: '#0F000000', offsetY: 1 })
  }
}
