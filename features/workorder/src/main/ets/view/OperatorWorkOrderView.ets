import { OperatorWorkOrderViewModel } from '../viewModel/OperatorWorkOrderViewModel';
import { WorkOrder } from 'utils';

@ComponentV2
export struct OperatorWorkOrderView {
  @Param viewModel: OperatorWorkOrderViewModel = new OperatorWorkOrderViewModel();
  @Param cardPadding: number = 20;
  @Event onBack?: () => void;
  @Event onGoToProduction?: () => void;
  @Event onViewDetail?: (orderId: number) => void;
  private navStack: NavPathStack | null = null;

  aboutToAppear(): void {
    this.navStack = AppStorage.get('navPathStack') as NavPathStack;
    this.viewModel.onNavigateToDetail = (orderId: number) => {
      if (this.onViewDetail) {
        this.onViewDetail(orderId);
      }
    };
    this.viewModel.init();
  }

  build() {
    Column() {
      this.buildHeader()
      Scroll() {
        Column() {
          this.buildUserInfoCard()
          this.buildOrderList()
          Blank().height('24vp')
        }
        .width('100%')
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F4F8')
  }

  @Builder
  buildHeader() {
    Row() {
      Row() {
        Text('‹')
          .fontSize('26fp')
          .fontColor('#64748B')
          .fontWeight(FontWeight.Normal)
      }
      .width('40vp')
      .height('40vp')
      .borderRadius('12vp')
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        if (this.onBack) {
          this.onBack();
        } else if (this.navStack) {
          this.navStack.pop();
        }
      })

      Column() {
        Text('我的工单')
          .fontSize('22fp')
          .fontColor('#0F172A')
          .fontWeight(FontWeight.Bold)
        Text('查看与我关联的工单')
          .fontSize('13fp')
          .fontColor('#64748B')
          .margin({ top: '2vp' })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: '12vp' })
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '16vp', bottom: '16vp' })
    .backgroundColor('#F0F4F8')
  }

  @Builder
  buildUserInfoCard() {
    Row() {
      Row() {
        Text('👤')
          .fontSize('24fp')
      }
      .width('52vp')
      .height('52vp')
      .borderRadius('16vp')
      .backgroundColor('#ECFDF5')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .margin({ right: '14vp' })

      Column() {
        Text((this.viewModel.currentUserName || '操作员') + ' · 操作员')
          .fontSize('18fp')
          .fontColor('#0F172A')
          .fontWeight(FontWeight.Bold)
        Text('显示派工给你的工单，以及其他人名下但你可查看的工单')
          .fontSize('13fp')
          .fontColor('#64748B')
          .margin({ top: '4vp' })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding('18vp')
    .borderRadius('20vp')
    .backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, bottom: '16vp' })
    .shadow({ radius: 8, color: "rgba(15, 23, 42, 0.04)", offsetY: 2 })
  }

  @Builder
  buildOrderList() {
    Column() {
      if (this.viewModel.filteredOrders.length === 0) {
        Column() {
          Text('暂无工单')
            .fontSize('15fp')
            .fontColor('#94A3B8')
            .margin({ top: '60vp' })
        }
        .width('100%')
      }
      ForEach(this.viewModel.filteredOrders, (order: WorkOrder) => {
        this.buildOrderCard(order)
      }, (order: WorkOrder) => order.id.toString())
    }
    .width('100%')
  }

  @Builder
  buildOrderCard(order: WorkOrder) {
    Column() {
      Row() {
        Text(order.code)
          .fontSize('16fp')
          .fontColor('#059669')
          .fontWeight(FontWeight.Medium)
        Blank()
        Text(order.type)
          .fontSize('12fp')
          .fontColor('#6366F1')
          .fontWeight(FontWeight.Medium)
          .padding({ left: '12vp', right: '12vp', top: '5vp', bottom: '5vp' })
          .borderRadius('10vp')
          .backgroundColor('#EEF2FF')
      }
      .width('100%')

      Text(order.productName + ' / ' + (order.lineName || '柔性组装线'))
        .fontSize('14fp')
        .fontColor('#64748B')
        .width('100%')
        .margin({ top: '8vp' })

      Row() {
        Text('派工给：' + this.viewModel.getOperatorLabel(order))
          .fontSize('12fp')
          .fontColor(this.viewModel.canOperateOrder(order) ? '#059669' : '#6B7280')
        Blank()
        if (!this.viewModel.canOperateOrder(order)) {
          Text('只读')
            .fontSize('11fp')
            .fontColor('#92400E')
            .padding({ left: '8vp', right: '8vp', top: '3vp', bottom: '3vp' })
            .borderRadius('10vp')
            .backgroundColor('#FEF3C7')
        }
      }
      .width('100%')
      .margin({ top: '8vp' })

      Row() {
        Text(this.getStatusDescription(order.status))
          .fontSize('18fp')
          .fontColor('#0F172A')
          .fontWeight(FontWeight.Bold)
        Blank()
        Text(order.status)
          .fontSize('14fp')
          .fontColor(this.getStatusColor(order.status))
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .margin({ top: '8vp' })

      if (!this.viewModel.canOperateOrder(order)) {
        Row() {
          Text(this.viewModel.getReadonlyHint(order))
            .fontSize('12fp')
            .fontColor('#6B7280')
        }
        .width('100%')
        .padding({ left: '12vp', right: '12vp', top: '10vp', bottom: '10vp' })
        .borderRadius('12vp')
        .backgroundColor('#F8FAFC')
        .margin({ top: '14vp' })
      } else if (order.status === '已派工') {
        Row() {
          Text('→ 去生产')
            .fontSize('16fp')
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .height('52vp')
        .borderRadius('16vp')
        .backgroundColor('#059669')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .margin({ top: '14vp' })
        .onClick(() => {
          this.viewModel.startProduction(order.id);
          if (this.onGoToProduction) {
            this.onGoToProduction();
          }
        })
      } else if (order.status === '生产完成') {
        Row() {
          Text('→ 去报工')
            .fontSize('16fp')
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .height('52vp')
        .borderRadius('16vp')
        .backgroundColor('#059669')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .margin({ top: '14vp' })
        .onClick(() => {
          this.viewModel.viewDetail(order.id);
        })
      }
    }
    .width('100%')
    .padding('18vp')
    .borderRadius('20vp')
    .backgroundColor(this.viewModel.canOperateOrder(order) ? '#FFFFFF' : '#F8FAFC')
    .border(this.getCardBorder(order))
    .margin({ left: this.cardPadding, right: this.cardPadding, bottom: '12vp' })
    .shadow({ radius: 8, color: "rgba(15, 23, 42, 0.04)", offsetY: 2 })
    .onClick(() => {
      this.viewModel.viewDetail(order.id);
    })
  }

  getCardBorder(order: WorkOrder): BorderOptions {
    if (!this.viewModel.canOperateOrder(order)) {
      return { width: '1vp', color: '#CBD5E1' };
    }
    if (order.status === '已派工') {
      return { width: '2vp', color: '#34D399' };
    }
    if (order.status === '生产完成') {
      return { width: '1vp', color: '#7DD3FC' };
    }
    return { width: '1vp', color: '#E2E8F0' };
  }

  getStatusDescription(status: string): string {
    if (status === '已派工') return '已派工 · 点击查看工单'
    if (status === '生产完成') return '生产完成 · 点击进入报工'
    if (status === '已报工') return '已完成报工'
    if (status === '完工') return '已完工'
    if (status === '生产中') return '生产中'
    if (status === '暂停中' || status === '生产中暂停') return '生产中暂停'
    return status
  }

  getStatusColor(status: string): string {
    if (status === '已派工') return '#059669'
    if (status === '生产完成') return '#0284C7'
    if (status === '已报工') return '#059669'
    if (status === '完工') return '#059669'
    if (status === '生产中') return '#0EA5E9'
    return '#64748B'
  }
}
