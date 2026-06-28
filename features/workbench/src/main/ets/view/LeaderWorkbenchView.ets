import { LeaderWorkbenchViewModel } from '../viewModel/LeaderWorkbenchViewModel';
import { TodoItem, QuickEntry, MenuCard } from '../model/WorkbenchTypes';
import { WorkOrder } from 'utils';

@ComponentV2
export struct LeaderWorkbenchView {
  @Param viewModel: LeaderWorkbenchViewModel = new LeaderWorkbenchViewModel();
  @Param cardPadding: number = 16;
  @Event onNavigate?: (target: string) => void;
  @Event onOrderClick?: (orderId: number) => void;

  aboutToAppear(): void {
    this.viewModel.init();
  }

  build() {
    // 主工作台页面
    Scroll() {
      Column() {
        // ========== 上半部分：与管理后台一致 ==========
        // 顶部欢迎区
        this.buildHeader()

        // 常用功能（基础数据、工单、质检看板）
        this.buildCommonFunctions()

        // ========== 待办工单 ==========
        this.buildPendingOrders()

        // ========== 异常处理工单 ==========
        this.buildExceptionOrders()

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

  // ================================================================
  // 顶部欢迎区（管理员同款）
  // ================================================================
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
          Text(this.viewModel.userName || '王志刚')
            .fontSize('26fp')
            .fontColor('#1A2B3C')
            .fontWeight(FontWeight.Bold)
            .margin({ left: '6vp' })
        }
        .alignItems(VerticalAlign.Center)

        Row() {
          Text('当前角色：班组长')
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

  // ================================================================
  // 常用功能（管理员同款）
  // ================================================================
  @Builder
  buildCommonFunctions() {
    Column() {
      Text('常用功能')
        .fontSize('16fp')
        .fontColor('#1A2B3C')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: '10vp' })

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
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '8vp', bottom: '8vp' })
  }

  // ================================================================
  // 待办与进度
  // ================================================================
  @Builder
  buildTodoProgress() {
    Column() {
      Row() {
        Text('待办与进度')
          .fontSize('16fp')
          .fontColor('#1A2B3C')
          .fontWeight(FontWeight.Medium)
        Blank()
        Text('今日统计')
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

  // ================================================================
  // 待办工单
  // ================================================================
  @Builder
  buildPendingOrders() {
    Column() {
      Text('待办工单')
        .fontSize('16fp')
        .fontColor('#1A2B3C')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: '10vp' })

      if (this.viewModel.getPendingOrders().length === 0) {
        Row() {
          Text('暂无待办工单')
            .fontSize('13fp')
            .fontColor('#999999')
        }
        .width('100%')
        .height('60vp')
        .justifyContent(FlexAlign.Center)
        .borderRadius('10vp')
        .backgroundColor('#FFFFFF')
      }

      ForEach(this.viewModel.getPendingOrders(), (order: WorkOrder) => {
        this.buildWorkOrderCard(order)
      })
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '8vp', bottom: '8vp' })
  }

  // ================================================================
  // 异常处理工单
  // ================================================================
  @Builder
  buildExceptionOrders() {
    Column() {
      Text('异常处理工单')
        .fontSize('16fp')
        .fontColor('#1A2B3C')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: '10vp' })

      if (this.viewModel.getExceptionOrders().length === 0) {
        Row() {
          Text('暂无异常工单')
            .fontSize('13fp')
            .fontColor('#999999')
        }
        .width('100%')
        .height('60vp')
        .justifyContent(FlexAlign.Center)
        .borderRadius('10vp')
        .backgroundColor('#FFFFFF')
      }

      ForEach(this.viewModel.getExceptionOrders(), (order: WorkOrder) => {
        this.buildWorkOrderCard(order)
      })
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '8vp', bottom: '8vp' })
  }

  // ================================================================
  // 工单卡片（可点击进入详情）
  // ================================================================
  @Builder
  buildWorkOrderCard(order: WorkOrder) {
    Column() {
      Row() {
        Text(order.code)
          .fontSize('15fp')
          .fontColor('#1A2B3C')
          .fontWeight(FontWeight.Bold)
        Blank()
        this.buildStatusTag(order.status)
      }
      .width('100%')

      Row() {
        Text(order.productName)
          .fontSize('13fp')
          .fontColor('#666666')
        Blank()
        Text('计划: ' + order.planQty.toString())
          .fontSize('12fp')
          .fontColor('#999999')
      }
      .width('100%')
      .margin({ top: '6vp' })

      Row() {
        Text(order.type)
          .fontSize('11fp')
          .fontColor('#007DFF')
          .padding({ left: '6vp', right: '6vp', top: '2vp', bottom: '2vp' })
          .borderRadius('4vp')
          .backgroundColor('#E3F2FD')
        Text(' · ' + order.lineName)
          .fontSize('11fp')
          .fontColor('#999999')
        if (order.operatorName) {
          Text(' · ' + order.operatorName)
            .fontSize('11fp')
            .fontColor('#999999')
        }
      }
      .width('100%')
      .margin({ top: '6vp' })
    }
    .width('100%')
    .padding('14vp')
    .borderRadius('10vp')
    .backgroundColor(order.highlighted ? '#FFF8E1' : '#FFFFFF')
    .border(order.highlighted ? { width: '1.5vp', color: '#FF9800' } : { width: '1vp', color: '#E8EDF2' })
    .margin({ bottom: '8vp' })
    .shadow({ radius: 3, color: '#0F000000', offsetY: 1 })
    .onClick(() => {
      this.onOrderClick?.(order.id);
    })
  }

  @Builder
  buildStatusTag(status: string) {
    Text(status)
      .fontSize('11fp')
      .fontColor(this.getStatusColor(status))
      .fontWeight(FontWeight.Medium)
      .padding({ left: '8vp', right: '8vp', top: '3vp', bottom: '3vp' })
      .borderRadius('6vp')
      .border({ width: '1px', color: this.getStatusColor(status) })
  }

  // ================================================================
  // 功能菜单
  // ================================================================
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
