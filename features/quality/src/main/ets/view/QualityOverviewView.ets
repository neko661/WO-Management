import { QualityOverviewViewModel } from '../viewModel/QualityOverviewViewModel';
import {
  DefectCategory, LineQuality, QualityMenuItem,
  InspectionRecord, QualityTrendPoint
} from '../model/QualityTypes';

@ComponentV2
export struct QualityOverviewView {
  @Param viewModel: QualityOverviewViewModel = new QualityOverviewViewModel();
  @Param cardPadding: number = 16;
  @Event onBack?: () => void;
  @Local currentTab: number = 0;

  aboutToAppear(): void {
    this.viewModel.init();
  }

  build() {
    Column() {
      // 顶部标题栏
      this.buildHeader()

      // 快捷功能 Tab 栏——放在最上面
      this.buildQuickTabs()

      // 内容区——每个 Tab 独立 Scroll，确保内容完整渲染
      if (this.currentTab === 0) {
        Scroll() {
          Column() {
            this.buildOverviewTab()
            Blank().height('20vp')
          }
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
        .backgroundColor('#E8EDF2')
      } else if (this.currentTab === 1) {
        Scroll() {
          Column() {
            this.buildDefectTab()
            Blank().height('20vp')
          }
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
        .backgroundColor('#E8EDF2')
      } else if (this.currentTab === 2) {
        Scroll() {
          Column() {
            this.buildTrendTab()
            Blank().height('20vp')
          }
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
        .backgroundColor('#E8EDF2')
      } else {
        Scroll() {
          Column() {
            this.buildReportTab()
            Blank().height('20vp')
          }
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
        .backgroundColor('#E8EDF2')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#E8EDF2')
  }

  // ================================================================
  // 顶部标题
  // ================================================================
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
        Text('质检看板')
          .fontSize('18fp')
          .fontColor('#1A2B3C')
          .fontWeight(FontWeight.Bold)
        Text(this.getTabSubtitle())
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

  getTabSubtitle(): string {
    if (this.currentTab === 0) return '质量数据总览';
    if (this.currentTab === 1) return '缺陷分布与排行';
    if (this.currentTab === 2) return '质量指标变化趋势';
    return '质检记录与报告汇总';
  }

  // ================================================================
  // 快捷功能 Tab 栏
  // ================================================================
  @Builder
  buildQuickTabs() {
    Row() {
      ForEach(this.viewModel.menuItems, (item: QualityMenuItem, index: number) => {
        Column() {
          Column() {
            Image(item.icon)
              .width('22vp')
              .height('22vp')
          }
          .width('44vp')
          .height('44vp')
          .borderRadius('12vp')
          .backgroundColor(this.currentTab === index ? item.iconColor : item.iconBg)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            this.currentTab = index;
          })

          Text(item.title)
            .fontSize('11fp')
            .fontColor(this.currentTab === index ? '#1A2B3C' : '#6B7B8C')
            .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Normal)
            .margin({ top: '6vp' })

          // 选中指示条
          if (this.currentTab === index) {
            Row()
              .width('24vp')
              .height('3vp')
              .borderRadius('2vp')
              .backgroundColor(item.iconColor)
              .margin({ top: '4vp' })
          } else {
            Row()
              .width('24vp')
              .height('3vp')
              .borderRadius('2vp')
              .backgroundColor('transparent')
              .margin({ top: '4vp' })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      })
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '4vp', bottom: '8vp' })
  }

  // ================================================================
  // Tab 0: 质检概览
  // ================================================================
  @Builder
  buildOverviewTab() {
    Column() {
      // KPI 卡片
      this.buildKpiOverview()

      // 缺陷摘要
      this.buildDefectSummary()

      // 各产线质量状况
      this.buildLineQuality()
    }
    .width('100%')
  }

  @Builder
  buildKpiOverview() {
    Column() {
      Text('质检KPI概览')
        .fontSize('16fp')
        .fontColor('#1A2B3C')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: '10vp' })

      Grid() {
        GridItem() { this.buildKpiCard('累计检验数', this.viewModel.overview.totalInspected.toString(), '#007DFF') }
        GridItem() { this.buildKpiCard('合格率', this.viewModel.overview.passRate.toString() + '%', '#4CAF50') }
        GridItem() { this.buildKpiCard('不良率', this.viewModel.overview.defectRate.toString() + '%', '#F44336') }
        GridItem() { this.buildKpiCard('待检验数', this.viewModel.overview.pendingInspect.toString(), '#FF9800') }
        GridItem() { this.buildKpiCard('本月合格', this.viewModel.overview.monthlyQualified.toString(), '#2196F3') }
        GridItem() { this.buildKpiCard('本月不良', this.viewModel.overview.monthlyDefect.toString(), '#9C27B0') }
      }
      .width('100%')
      .columnsTemplate('1fr 1fr 1fr')
      .columnsGap('8vp')
      .rowsGap('8vp')
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '8vp', bottom: '8vp' })
  }

  @Builder
  buildKpiCard(label: string, value: string, color: string) {
    Column() {
      Text(value)
        .fontSize('22fp')
        .fontColor(color)
        .fontWeight(FontWeight.Bold)
      Text(label)
        .fontSize('11fp')
        .fontColor('#6B7B8C')
        .margin({ top: '4vp' })
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('80vp')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .borderRadius('10vp')
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 3, color: '#0F000000', offsetY: 1 })
  }

  @Builder
  buildDefectSummary() {
    Column() {
      Row() {
        Text('缺陷类别概览')
          .fontSize('16fp')
          .fontColor('#1A2B3C')
          .fontWeight(FontWeight.Medium)
        Blank()
        Text('本月累计')
          .fontSize('11fp')
          .fontColor('#6B7B8C')
      }
      .width('100%')
      .margin({ bottom: '10vp' })

      Column() {
        ForEach(this.viewModel.defectCategories.slice(0, 5), (cat: DefectCategory) => {
          this.buildDefectBar(cat)
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
  buildDefectBar(cat: DefectCategory) {
    Column() {
      Row() {
        Text(cat.name)
          .fontSize('13fp')
          .fontColor('#1A2B3C')
          .layoutWeight(1)
        Text(cat.count.toString())
          .fontSize('13fp')
          .fontColor(cat.color)
          .fontWeight(FontWeight.Bold)
        Text('  ' + cat.percentage.toString() + '%')
          .fontSize('12fp')
          .fontColor('#6B7B8C')
      }
      .width('100%')

      Row() {
        Row()
          .width(cat.percentage.toString() + '%')
          .height('8vp')
          .borderRadius('4vp')
          .backgroundColor(cat.color)
        Blank()
      }
      .width('100%')
      .height('8vp')
      .borderRadius('4vp')
      .backgroundColor('#F0F2F5')
      .margin({ top: '6vp' })
    }
    .width('100%')
    .margin({ bottom: '12vp' })
  }

  @Builder
  buildLineQuality() {
    Column() {
      Text('各产线质量状况')
        .fontSize('16fp')
        .fontColor('#1A2B3C')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: '10vp' })

      ForEach(this.viewModel.lineQualityList, (line: LineQuality) => {
        this.buildLineQualityCard(line)
      })
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '8vp', bottom: '8vp' })
  }

  @Builder
  buildLineQualityCard(line: LineQuality) {
    Row() {
      Column() {
        Row() {
          Text(line.lineName)
            .fontSize('14fp')
            .fontColor('#1A2B3C')
            .fontWeight(FontWeight.Medium)
          Blank()
          this.buildStatusBadge(line.status)
        }
        .width('100%')

        Row() {
          Text('合格率: ' + line.passRate.toString() + '%')
            .fontSize('12fp')
            .fontColor('#6B7B8C')
          Text(' | 检验: ' + line.inspectedCount.toString())
            .fontSize('12fp')
            .fontColor('#6B7B8C')
          Text(' | 缺陷: ' + line.defectCount.toString())
            .fontSize('12fp')
            .fontColor(line.defectCount > 100 ? '#F44336' : '#6B7B8C')
        }
        .width('100%')
        .margin({ top: '4vp' })

        Text('主要缺陷: ' + line.topDefect)
          .fontSize('11fp')
          .fontColor('#999999')
          .width('100%')
          .margin({ top: '2vp' })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding('12vp')
    .borderRadius('10vp')
    .backgroundColor('#FFFFFF')
    .border({ width: '1vp', color: line.status === 'critical' ? '#F44336' : line.status === 'warning' ? '#FF9800' : '#E0E5EB' })
    .margin({ bottom: '8vp' })
  }

  @Builder
  buildStatusBadge(status: string) {
    Text(status === 'good' ? '良好' : status === 'warning' ? '注意' : '警惕')
      .fontSize('10fp')
      .fontColor('#FFFFFF')
      .padding({ left: '8vp', right: '8vp', top: '3vp', bottom: '3vp' })
      .borderRadius('8vp')
      .backgroundColor(status === 'good' ? '#4CAF50' : status === 'warning' ? '#FF9800' : '#F44336')
  }

  // ================================================================
  // Tab 1: 缺陷统计
  // ================================================================
  @Builder
  buildDefectTab() {
    Column() {
      // 缺陷总数卡片
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

      // 缺陷类别占比
      this.buildDefectCategoryList()

      // 缺陷明细排行
      this.buildDefectRanking()

      // 各产线缺陷对比
      this.buildLineDefectCompare()
    }
    .width('100%')
  }

  @Builder
  buildDefectCategoryList() {
    Column() {
      Text('缺陷类别分布')
        .fontSize('16fp')
        .fontColor('#1A2B3C')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: '12vp' })

      Column() {
        ForEach(this.viewModel.defectCategories, (cat: DefectCategory) => {
          Row() {
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
  buildDefectRanking() {
    Column() {
      Text('缺陷明细排行')
        .fontSize('16fp')
        .fontColor('#1A2B3C')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: '10vp' })

      ForEach(this.viewModel.defectCategories, (cat: DefectCategory, index: number) => {
        Row() {
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
  buildLineDefectCompare() {
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

  // ================================================================
  // Tab 2: 质量趋势
  // ================================================================
  @Builder
  buildTrendTab() {
    Column() {
      // 趋势概览统计
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

      // 合格率趋势
      this.buildPassRateChart()

      // 缺陷数量趋势
      this.buildDefectTrendChart()

      // 检验数量趋势
      this.buildInspectionChart()

      // 月度对比
      this.buildMonthCompare()
    }
    .width('100%')
  }

  @Builder
  buildPassRateChart() {
    Column() {
      Text('合格率趋势（近7天）')
        .fontSize('16fp')
        .fontColor('#1A2B3C')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: '12vp' })

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
  buildDefectTrendChart() {
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
                .width((point.defectCount * 4).toString() + '%')
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
  buildInspectionChart() {
    Column() {
      Text('检验数量趋势（近7天）')
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
  buildMonthCompare() {
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

  // ================================================================
  // Tab 3: 质检报告
  // ================================================================
  @Local reportFilterResult: string = '';

  @Builder
  buildReportTab() {
    Column() {
      // 报告统计摘要
      Row() {
        Column() {
          Text((this.viewModel.recentRecords.filter((r: InspectionRecord) => r.result === 'pass').length + ((AppStorage.get('global_pass_count') as number) || 0)).toString())
            .fontSize('24fp')
            .fontColor('#4CAF50')
            .fontWeight(FontWeight.Bold)
          Text('合格')
            .fontSize('11fp')
            .fontColor('#6B7B8C')
            .margin({ top: '4vp' })
        }
        .layoutWeight(1)
        .height('70vp')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .padding('12vp')
        .borderRadius('10vp')
        .backgroundColor('#E8F5E9')

        Column() {
          Text((this.viewModel.recentRecords.filter((r: InspectionRecord) => r.result === 'conditional').length + ((AppStorage.get('global_cond_count') as number) || 0)).toString())
            .fontSize('24fp')
            .fontColor('#FF9800')
            .fontWeight(FontWeight.Bold)
          Text('条件放行')
            .fontSize('11fp')
            .fontColor('#6B7B8C')
            .margin({ top: '4vp' })
        }
        .layoutWeight(1)
        .height('70vp')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .padding('12vp')
        .borderRadius('10vp')
        .backgroundColor('#FFF3E0')
        .margin({ left: '8vp' })

        Column() {
          Text((this.viewModel.recentRecords.filter((r: InspectionRecord) => r.result === 'fail').length + ((AppStorage.get('global_fail_count') as number) || 0)).toString())
            .fontSize('24fp')
            .fontColor('#F44336')
            .fontWeight(FontWeight.Bold)
          Text('不合格')
            .fontSize('11fp')
            .fontColor('#6B7B8C')
            .margin({ top: '4vp' })
        }
        .layoutWeight(1)
        .height('70vp')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .padding('12vp')
        .borderRadius('10vp')
        .backgroundColor('#FFEBEE')
        .margin({ left: '8vp' })
      }
      .width('100%')
      .padding({ left: this.cardPadding, right: this.cardPadding, top: '8vp', bottom: '8vp' })

      // 结果筛选
      Row() {
        this.buildReportFilterChip('全部', this.reportFilterResult === '', () => { this.reportFilterResult = ''; })
        this.buildReportFilterChip('合格', this.reportFilterResult === 'pass', () => { this.reportFilterResult = 'pass'; })
        this.buildReportFilterChip('不合格', this.reportFilterResult === 'fail', () => { this.reportFilterResult = 'fail'; })
        this.buildReportFilterChip('条件放行', this.reportFilterResult === 'conditional', () => { this.reportFilterResult = 'conditional'; })
      }
      .width('100%')
      .padding({ left: this.cardPadding, right: this.cardPadding, bottom: '8vp' })

      // 质检记录列表
      Text('质检记录')
        .fontSize('16fp')
        .fontColor('#1A2B3C')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .padding({ left: this.cardPadding, right: this.cardPadding, top: '8vp', bottom: '8vp' })

      ForEach(this.viewModel.recentRecords, (record: InspectionRecord) => {
        if (this.reportFilterResult === '' || record.result === this.reportFilterResult) {
          this.buildReportCard(record)
        }
      })
    }
    .width('100%')
  }

  @Builder
  buildReportFilterChip(label: string, active: boolean, onClick: () => void) {
    Text(label)
      .fontSize('12fp')
      .fontColor(active ? '#FFFFFF' : '#1A2B3C')
      .padding({ left: '12vp', right: '12vp', top: '6vp', bottom: '6vp' })
      .borderRadius('14vp')
      .backgroundColor(active ? '#000000' : '#F3F5F8')
      .margin({ right: '8vp' })
      .onClick(onClick)
  }

  @Builder
  buildReportCard(record: InspectionRecord) {
    Column() {
      Row() {
        Text(record.workorderCode)
          .fontSize('15fp')
          .fontColor('#1A2B3C')
          .fontWeight(FontWeight.Bold)
        Blank()
        Column() {
          Text(record.result === 'pass' ? '合格' : record.result === 'fail' ? '不合格' : '条件放行')
            .fontSize('12fp')
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
            .padding({ left: '10vp', right: '10vp', top: '4vp', bottom: '4vp' })
            .borderRadius('8vp')
            .backgroundColor(record.result === 'pass' ? '#4CAF50' : record.result === 'fail' ? '#F44336' : '#FF9800')
        }
      }
      .width('100%')

      Row() {
        Text(record.productName)
          .fontSize('13fp')
          .fontColor('#666666')
        Text(' · ' + record.lineName)
          .fontSize('13fp')
          .fontColor('#999999')
      }
      .width('100%')
      .margin({ top: '8vp' })

      Divider()
        .width('100%')
        .height('1vp')
        .color('#F0F2F5')
        .margin({ top: '10vp', bottom: '10vp' })

      // 2x2 网格展示，从上往下排列
      Grid() {
        GridItem() {
          Column() {
            Text('检验数量')
              .fontSize('10fp').fontColor('#999999')
            Text(record.inspectedCount.toString())
              .fontSize('16fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold)
              .margin({ top: '4vp' })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }

        GridItem() {
          Column() {
            Text('缺陷数量')
              .fontSize('10fp').fontColor('#999999')
            Text(record.defectCount.toString())
              .fontSize('16fp').fontColor(record.defectCount > 0 ? '#F44336' : '#4CAF50').fontWeight(FontWeight.Bold)
              .margin({ top: '4vp' })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }

        GridItem() {
          Column() {
            Text('检验员')
              .fontSize('10fp').fontColor('#999999')
            Text(record.inspectorName)
              .fontSize('16fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold)
              .margin({ top: '4vp' })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }

        GridItem() {
          Column() {
            Text('日期')
              .fontSize('10fp').fontColor('#999999')
            Text(record.inspectDate)
              .fontSize('14fp').fontColor('#1A2B3C').fontWeight(FontWeight.Medium)
              .margin({ top: '4vp' })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
      }
      .width('100%')
      .columnsTemplate('1fr 1fr')
      .columnsGap('16vp')
      .rowsGap('10vp')
    }
    .width('100%')
    .padding('14vp')
    .borderRadius('12vp')
    .backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, bottom: '10vp' })
    .shadow({ radius: 4, color: '#0F000000', offsetY: 1 })
  }
}
