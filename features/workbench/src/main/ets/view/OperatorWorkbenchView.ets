import { OperatorWorkbenchViewModel } from '../viewModel/OperatorWorkbenchViewModel';
import { TodoItem, QuickEntry, MenuCard } from '../model/WorkbenchTypes';
import { ThemeConstants } from 'uicomponents';
import { WorkOrder } from 'utils';

@ComponentV2
export struct OperatorWorkbenchView {
  @Param viewModel: OperatorWorkbenchViewModel = new OperatorWorkbenchViewModel();
  @Param cardPadding: number = 16;
  @Event onNavigate?: (target: string) => void;

  aboutToAppear(): void {
    this.viewModel.init();
  }

  build() {
    Scroll() {
      Column() {
        // 读取异常触发标记以响应刷新
        Text(((AppStorage.get('operator_todo_trigger') as number) || 0).toString())
          .fontSize('0fp').width('0vp').height('0vp').fontColor('transparent')
        // 顶部欢迎区（管理员同款）
        this.buildHeader()

        // 常用功能（管理员同款）
        this.buildCommonFunctions()

        // 操作员视角
        this.buildOperatorView()

        // 功能菜单
        this.buildMenuCards()

        // 近期工单
        Text('近期工单')
          .fontSize('16fp')
          .fontColor('#1A2B3C')
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .padding({ left: this.cardPadding, right: this.cardPadding, top: '8vp', bottom: '8vp' })

        ForEach(this.viewModel.workOrders.slice(0, 5), (order: WorkOrder) => {
          this.buildOrderCard(order)
        })

        // 底部留白
        Blank().height('20vp')
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .align(Alignment.TopStart)
    .backgroundColor('#E8EDF2')
  }

  @Builder
  buildHeader() {
    Row() {
      Column() {
        Text(this.viewModel.appTitle)
          .fontSize('12fp')
          .fontColor('#7A8A99')
          .margin({ bottom: '6vp' })

        Row() {
          Text('Hello,')
            .fontSize('26fp')
            .fontColor('#1A2B3C')
            .fontWeight(FontWeight.Bold)
          Text(this.viewModel.userName || '刘伟')
            .fontSize('26fp')
            .fontColor('#1A2B3C')
            .fontWeight(FontWeight.Bold)
            .margin({ left: '6vp' })
        }
        .alignItems(VerticalAlign.Center)

        Row() {
          Text('当前角色：操作员')
            .fontSize('12fp')
            .fontColor('#FFFFFF')
            .padding({ left: '10vp', right: '10vp', top: '4vp', bottom: '4vp' })
            .borderRadius('12vp')
            .backgroundColor('#1F2D3D')
        }
        .width('100%')
        .margin({ top: '8vp' })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Column() {
        Image($r('app.media.bell'))
          .width('22vp')
          .height('22vp')
      }
      .width('44vp')
      .height('44vp')
      .borderRadius('22vp')
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '16vp', bottom: '8vp' })
  }

  @Builder
  buildCommonFunctions() {
    Column() {
      Text('常用功能')
        .fontSize('16fp')
        .fontColor('#1A2B3C')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: '10vp' })

      // 三个入口卡片
      Row() {
        ForEach(this.viewModel.quickEntries, (entry: QuickEntry) => {
          Column() {
            Column() {
              Image(entry.icon)
                .width('28vp')
                .height('28vp')
            }
            .width('56vp')
            .height('56vp')
            .borderRadius('16vp')
            .backgroundColor(entry.bgColor)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            Text(entry.label)
              .fontSize('13fp')
              .fontColor('#333333')
              .margin({ top: '8vp' })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            if (entry.id === 1) {
              this.onNavigate?.('data');
            } else if (entry.id === 2) {
              this.onNavigate?.('workorder');
            } else if (entry.id === 3) {
              this.onNavigate?.('quality');
            }
          })
        })
      }
      .width('100%')

      // 提示卡
      Row() {
        Blank()
          .width('100%')
          .height('2vp')
      }
      .height('6vp')

      Row() {
        Text('工单：查看所有工单')
          .fontSize('12fp')
          .fontColor('#6B7B8C')
      }
      .width('100%')
      .padding({ left: '12vp', right: '12vp', top: '10vp', bottom: '10vp' })
      .borderRadius('10vp')
      .backgroundColor('#E8EDF2')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '8vp', bottom: '8vp' })
  }

  @Builder
  buildOperatorView() {
    Column() {
      Row() {
        Text('操作员视角')
          .fontSize('16fp')
          .fontColor('#1A2B3C')
          .fontWeight(FontWeight.Medium)
        Blank()
        Text('生产执行 · 报工上报')
          .fontSize('11fp')
          .fontColor('#6B7B8C')
      }
      .width('100%')
      .margin({ bottom: '10vp' })

      Grid() {
        ForEach(this.viewModel.todos, (todo: TodoItem) => {
          GridItem() {
            this.buildStatCard(todo)
          }
        })
      }
      .width('100%')
      .columnsTemplate('1fr 1fr')
      .columnsGap('10vp')
      .rowsGap('10vp')
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '8vp', bottom: '8vp' })
  }

  @Builder
  buildStatCard(todo: TodoItem) {
    Column() {
      Text(todo.count.toString())
        .fontSize('32fp')
        .fontColor(todo.color)
        .fontWeight(FontWeight.Bold)
      Text(todo.title)
        .fontSize('12fp')
        .fontColor('#6B7B8C')
        .margin({ top: '6vp' })
    }
    .width('100%')
    .height('90vp')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .borderRadius('12vp')
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 4, color: '#0F000000', offsetY: 1 })
  }

  @Builder
  buildMenuCards() {
    Column() {
      ForEach(this.viewModel.menuCards, (menu: MenuCard) => {
        this.buildMenuItem(menu)
      })
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '8vp', bottom: '8vp' })
  }

  @Builder
  buildMenuItem(menu: MenuCard) {
    Row() {
      Column() {
        Image(menu.icon)
          .width('22vp')
          .height('22vp')
      }
      .width('44vp')
      .height('44vp')
      .borderRadius('10vp')
      .backgroundColor(menu.iconBg)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Column() {
        Text(menu.title)
          .fontSize('15fp')
          .fontColor('#1A2B3C')
          .fontWeight(FontWeight.Medium)
        Text(menu.description)
          .fontSize('12fp')
          .fontColor('#6B7B8C')
          .margin({ top: '4vp' })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: '12vp' })

      Text('›')
        .fontSize('24fp')
        .fontColor('#B0BCC8')
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .padding('14vp')
    .borderRadius('12vp')
    .backgroundColor('#FFFFFF')
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: '10vp' })
    .shadow({ radius: 4, color: '#0F000000', offsetY: 1 })
  }

  @Builder
  buildOrderCard(order: WorkOrder) {
    Column() {
      Row() {
        Text(order.code)
          .fontSize('14fp')
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
        Blank()
        this.buildStatusTag(order.status)
      }
      .width('100%')

      Row() {
        Text(order.productName)
          .fontSize('12fp')
          .fontColor('#666666')
        Blank()
        Text('计划: ' + order.planQty.toString())
          .fontSize('12fp')
          .fontColor('#999999')
      }
      .width('100%')
      .margin({ top: '4vp' })

      Row() {
        Text(order.lineName)
          .fontSize('11fp')
          .fontColor('#999999')
        if (order.operatorName) {
          Text(' · ' + order.operatorName)
            .fontSize('11fp')
            .fontColor('#999999')
        }
      }
      .width('100%')
      .margin({ top: '2vp' })
    }
    .width('100%')
    .padding('12vp')
    .borderRadius('8vp')
    .backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, bottom: '8vp' })
    .shadow({ radius: 2, color: '#08000000' })
  }

  @Builder
  buildStatusTag(status: string) {
    Text(status)
      .fontSize('10fp')
      .fontColor(this.getStatusColor(status))
      .padding({ left: '6vp', right: '6vp', top: '2vp', bottom: '2vp' })
      .borderRadius('4vp')
      .border({ width: '1px', color: this.getStatusColor(status) })
  }

  getStatusColor(status: string): string {
    if (status === '待派工') return '#FF9800';
    if (status === '已派工') return '#007DFF';
    if (status === '生产中') return '#4CAF50';
    if (status === '暂停中') return '#F44336';
    if (status === '生产完成') return '#9C27B0';
    if (status === '已报工') return '#00BCD4';
    if (status === '完工') return '#8BC34A';
    if (status === '报废') return '#795548';
    return '#999999';
  }
}
