import { QualityOverviewViewModel } from '../viewModel/QualityOverviewViewModel';
import { InspectionRecord } from '../model/QualityTypes';

@ComponentV2
export struct QualityReportView {
  @Param viewModel: QualityOverviewViewModel = new QualityOverviewViewModel();
  @Param cardPadding: number = 16;
  @Event onBack?: () => void;
  @Local searchKeyword: string = '';
  @Local filterResult: string = '';

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
          Text('质检报告')
            .fontSize('18fp')
            .fontColor('#1A2B3C')
            .fontWeight(FontWeight.Bold)
          Text('质检记录与报告汇总')
            .fontSize('12fp')
            .fontColor('#6B7B8C')
            .margin({ top: '2vp' })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: this.cardPadding, right: this.cardPadding, top: '16vp', bottom: '12vp' })

      // 搜索栏
      Row() {
        Text('🔍')
          .fontSize('14fp')
          .fontColor('#9AA5B1')
          .margin({ right: '6vp' })
        TextInput({ text: this.searchKeyword, placeholder: '搜索工单号...' })
          .fontSize('13fp')
          .fontColor('#1A2B3C')
          .backgroundColor('transparent')
          .layoutWeight(1)
          .height('40vp')
          .onChange((v: string) => { this.searchKeyword = v; })
      }
      .width('100%')
      .height('44vp')
      .borderRadius('10vp')
      .backgroundColor('#F3F5F8')
      .padding({ left: '12vp', right: '12vp' })
      .margin({ left: this.cardPadding, right: this.cardPadding, bottom: '12vp' })

      // 筛选结果标签
      Row() {
        this.buildFilterChip('全部', this.filterResult === '', () => { this.filterResult = ''; })
        this.buildFilterChip('合格', this.filterResult === 'pass', () => { this.filterResult = 'pass'; })
        this.buildFilterChip('不合格', this.filterResult === 'fail', () => { this.filterResult = 'fail'; })
        this.buildFilterChip('条件放行', this.filterResult === 'conditional', () => { this.filterResult = 'conditional'; })
      }
      .width('100%')
      .padding({ left: this.cardPadding, right: this.cardPadding, bottom: '8vp' })

      Scroll() {
        Column() {
          // 报告统计摘要
          this.buildReportSummary()

          // 质检记录列表
          Text('质检记录')
            .fontSize('16fp')
            .fontColor('#1A2B3C')
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .padding({ left: this.cardPadding, right: this.cardPadding, top: '8vp', bottom: '8vp' })

          ForEach(this.viewModel.recentRecords, (record: InspectionRecord) => {
            this.buildInspectionReportCard(record)
          })

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
  buildFilterChip(label: string, active: boolean, onClick: () => void) {
    Text(label)
      .fontSize('12fp')
      .fontColor(active ? '#FFFFFF' : '#1A2B3C')
      .padding({ left: '12vp', right: '12vp', top: '6vp', bottom: '6vp' })
      .borderRadius('14vp')
      .backgroundColor(active ? '#1F2D3D' : '#F3F5F8')
      .margin({ right: '8vp' })
      .onClick(onClick)
  }

  @Builder
  buildReportSummary() {
    Row() {
      Column() {
        Text(this.viewModel.recentRecords.filter((r: InspectionRecord) => r.result === 'pass').length.toString())
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
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .borderRadius('10vp')
      .backgroundColor('#E8F5E9')

      Column() {
        Text(this.viewModel.recentRecords.filter((r: InspectionRecord) => r.result === 'conditional').length.toString())
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
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .borderRadius('10vp')
      .backgroundColor('#FFF3E0')
      .margin({ left: '8vp' })

      Column() {
        Text(this.viewModel.recentRecords.filter((r: InspectionRecord) => r.result === 'fail').length.toString())
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
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .borderRadius('10vp')
      .backgroundColor('#FFEBEE')
      .margin({ left: '8vp' })
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '8vp', bottom: '8vp' })
  }

  @Builder
  buildInspectionReportCard(record: InspectionRecord) {
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

      Row() {
        Column() {
          Text('检验数量')
            .fontSize('10fp')
            .fontColor('#999999')
          Text(record.inspectedCount.toString())
            .fontSize('16fp')
            .fontColor('#1A2B3C')
            .fontWeight(FontWeight.Bold)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('缺陷数量')
            .fontSize('10fp')
            .fontColor('#999999')
          Text(record.defectCount.toString())
            .fontSize('16fp')
            .fontColor(record.defectCount > 0 ? '#F44336' : '#4CAF50')
            .fontWeight(FontWeight.Bold)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('检验员')
            .fontSize('10fp')
            .fontColor('#999999')
          Text(record.inspectorName)
            .fontSize('16fp')
            .fontColor('#1A2B3C')
            .fontWeight(FontWeight.Bold)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('日期')
            .fontSize('10fp')
            .fontColor('#999999')
          Text(record.inspectDate)
            .fontSize('12fp')
            .fontColor('#1A2B3C')
            .fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
    }
    .width('100%')
    .padding('14vp')
    .borderRadius('12vp')
    .backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, bottom: '10vp' })
    .shadow({ radius: 4, color: '#0F000000', offsetY: 1 })
  }
}
