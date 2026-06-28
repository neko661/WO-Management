import { AdminDataViewModel } from '../viewModel/AdminDataViewModel';
import { ProductionLineDetail, PersonnelGroup } from 'utils';
import { ThemeConstants } from 'uicomponents';
@ComponentV2
export struct InspectorDataView {
  @Param viewModel: AdminDataViewModel = new AdminDataViewModel();
  @Param cardPadding: number = 16;
  @Event onLineClick?: (lineId: number) => void;
  private navStack: NavPathStack | null = null;

  aboutToAppear(): void {
    this.viewModel.init();
    this.navStack = AppStorage.get('navPathStack') as NavPathStack;
  }

  build() {
    Column() {
      // 顶部标题区
      this.buildHeader()

      // Tab 切换
      this.buildTabs()

      // 内容区
      if (this.viewModel.currentTab === 0) {
        Scroll() {
          Column() {
            ForEach(this.viewModel.productionLines, (line: ProductionLineDetail) => {
              if (line.isRunning) {
                this.buildRunningLineCard(line)
              } else {
                this.buildIdleLineCard(line)
              }
            })
            Blank().height('20vp')
          }
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
        .backgroundColor('#E8EDF2')
      } else {
        this.buildPersonnelContent()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#E8EDF2')
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
        if (this.navStack) this.navStack.pop();
      })

      Column() {
        Text('基础数据查看')
          .fontSize('18fp')
          .fontColor('#1A2B3C')
          .fontWeight(FontWeight.Bold)
        Text('产线、工艺、人员统一查看')
          .fontSize('12fp')
          .fontColor('#6B7B8C')
          .margin({ top: '2vp' })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '16vp', bottom: '16vp' })
  }

  @Builder
  buildTabs() {
    Row() {
      this.buildTabItem('产线与工艺', 0)
      this.buildTabItem('人员', 1)
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, bottom: '12vp' })
  }

  @Builder
  buildTabItem(label: string, index: number) {
    Text(label)
      .fontSize('14fp')
      .fontColor(this.viewModel.currentTab === index ? '#FFFFFF' : '#1A2B3C')
      .fontWeight(FontWeight.Medium)
      .layoutWeight(1)
      .height('40vp')
      .borderRadius('8vp')
      .backgroundColor(this.viewModel.currentTab === index ? '#1F2D3D' : '#FFFFFF')
      .textAlign(TextAlign.Center)
      .margin({ right: index === 0 ? '8vp' : 0 })
      .onClick(() => {
        this.viewModel.switchTab(index);
      })
  }

  // 生产中产线卡片
  @Builder
  buildRunningLineCard(line: ProductionLineDetail) {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(this.getLineImage(line.id))
          .width('100%')
          .height('180vp')
          .objectFit(ImageFit.Cover)

        Row() {
          Text(line.name)
            .fontSize('18fp')
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
        }
        .padding({ left: '14vp', bottom: '8vp' })

        Row() {
          Text(line.statusTag)
            .fontSize('11fp')
            .fontColor(line.statusTagColor)
            .fontWeight(FontWeight.Medium)
            .padding({ left: '10vp', right: '10vp', top: '4vp', bottom: '4vp' })
            .borderRadius('12vp')
            .backgroundColor(line.statusTagBg)
        }
        .position({ x: '100%', y: '12vp' })
        .markAnchor({ x: '100%', y: 0 })
        .offset({ x: '-12vp' })
      }
      .width('100%')
      .height('180vp')

      // 工艺信息
      Column() {
        Text('当前工艺：' + line.currentProcess)
          .fontSize('12fp')
          .fontColor('#6B7B8C')
          .width('100%')
      }
      .width('100%')
      .padding({ left: '14vp', right: '14vp', top: '12vp' })

      // 底部信息行
      Row() {
        Text(line.workorderCode + ' / 原料 ' + line.rawMaterial + ' / 良品 ' + line.goodCount + ' / NG ' + line.ngCount)
          .fontSize('11fp')
          .fontColor('#6B7B8C')
          .layoutWeight(1)
        Text('查看整线信息')
          .fontSize('11fp')
          .fontColor('#007DFF')
      }
      .width('100%')
      .padding({ left: '14vp', right: '14vp', top: '10vp', bottom: '14vp' })
    }
    .width('100%')
    .borderRadius('14vp')
    .backgroundColor('#FFFFFF')
    .border({ width: '2vp', color: '#4CAF50' })
    .margin({ left: this.cardPadding, right: this.cardPadding, bottom: '12vp' })
    .clip(true)
    .onClick(() => {
      this.onLineClick?.(line.id);
    })
  }

  // 空闲产线卡片
  @Builder
  buildIdleLineCard(line: ProductionLineDetail) {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        Image(this.getLineImage(line.id))
          .width('100%')
          .height('130vp')
          .objectFit(ImageFit.Cover)

        Column() {
          Row() {
            Text(line.name)
              .fontSize('18fp')
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
            Blank()
            Text(line.statusTag)
              .fontSize('10fp')
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Medium)
              .padding({ left: '8vp', right: '8vp', top: '3vp', bottom: '3vp' })
              .borderRadius('10vp')
              .backgroundColor('rgba(255,255,255,0.25)')
          }
          .width('100%')

          Row() {
            Text('当前工艺：' + line.currentProcess)
              .fontSize('12fp')
              .fontColor('rgba(255,255,255,0.7)')
          }
          .width('100%')
          .margin({ top: '6vp' })
        }
        .width('100%')
        .padding('16vp')
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      Column() {
        Text('支持工艺：' + line.supportedProcesses.join('、'))
          .fontSize('12fp')
          .fontColor('#1A2B3C')
      }
      .width('100%')
      .padding('16vp')
      .alignItems(HorizontalAlign.Start)
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .borderRadius('14vp')
    .backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, bottom: '12vp' })
    .clip(true)
    .onClick(() => {
      this.onLineClick?.(line.id);
    })
  }

  // 产线图片映射
  getLineImage(lineId: number): Resource {
    if (lineId === 1) return $r('app.media.line_1');
    if (lineId === 2) return $r('app.media.line_2');
    if (lineId === 3) return $r('app.media.line_3');
    if (lineId === 4) return $r('app.media.line_4');
    return $r('app.media.line_1');
  }

  // 人员页面
  @Builder
  buildPersonnelContent() {
    Column() {
      // 人员标题卡
      Column() {
        Row() {
          Text('人员')
            .fontSize('15fp')
            .fontColor('#1A2B3C')
            .fontWeight(FontWeight.Bold)
          Blank()
          Text(this.viewModel.getGroupSummary())
            .fontSize('11fp')
            .fontColor('#6B7B8C')
        }
        .width('100%')

        Column() {
          ForEach(this.viewModel.personnelGroups, (group: PersonnelGroup) => {
            this.buildPersonnelItem(group)
          })
        }
        .width('100%')
        .margin({ top: '12vp' })
      }
      .width('100%')
      .padding('14vp')
      .borderRadius('12vp')
      .backgroundColor('#FFFFFF')
      .margin({ left: this.cardPadding, right: this.cardPadding, top: '8vp' })
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  buildPersonnelItem(group: PersonnelGroup) {
    Column() {
      Row() {
        Text(group.members.join(' · '))
          .fontSize('14fp')
          .fontColor('#1A2B3C')
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
        Text(group.members.length.toString() + group.role)
          .fontSize('13fp')
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)
          .padding({ left: '10vp', right: '10vp', top: '4vp', bottom: '4vp' })
          .borderRadius('10vp')
          .backgroundColor(this.getRoleTagColor(group.roleEn))
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Text('密码: 123456')
        .fontSize('11fp')
        .fontColor('#999999')
        .margin({ top: '4vp' })
        .width('100%')
    }
    .width('100%')
    .padding('12vp')
    .borderRadius('8vp')
    .backgroundColor('#F5F7FA')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: '8vp' })
  }

  getRoleTagColor(roleEn: string): string {
    if (roleEn === 'admin') return '#F44336';
    if (roleEn === 'leader') return '#4CAF50';
    if (roleEn === 'operator') return '#FF9800';
    if (roleEn === 'inspector') return '#2196F3';
    return '#999999';
  }
}
