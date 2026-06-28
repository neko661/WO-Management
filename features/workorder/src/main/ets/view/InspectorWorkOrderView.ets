import { InspectorWorkOrderViewModel } from '../viewModel/InspectorWorkOrderViewModel';
import { WorkOrder } from 'utils';

@ComponentV2
export struct InspectorWorkOrderView {
  @Param viewModel: InspectorWorkOrderViewModel = new InspectorWorkOrderViewModel();
  @Param cardPadding: number = 16;
  @Event onNavigate?: (target: string) => void;
  @Event onInspectClick?: (orderCode: string) => void;

  aboutToAppear(): void {
    this.viewModel.init();
  }

  build() {
    Column() {
      // 隐藏节点：读取 AppStorage 触发标记，确保抽检后页面刷新
      Text(((AppStorage.get('inspect_trigger') as number) || 0).toString())
        .fontSize('0fp').width('0vp').height('0vp').fontColor('transparent')
      // 顶部标题区
      Row() {
        Column() {
          Text('工单').fontSize('20fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold)
          Text('生产中和已完成的工单').fontSize('12fp').fontColor('#6B7B8C').margin({ top: '2vp' })
        }
        .alignItems(HorizontalAlign.Start).layoutWeight(1)
      }
      .width('100%')
      .padding({ left: this.cardPadding, right: this.cardPadding, top: '16vp', bottom: '12vp' })

      Scroll() {
        Column() {
          // 工单卡片列表
          ForEach(this.viewModel.getFilteredOrders(), (order: WorkOrder) => {
            this.buildOrderCard(order)
          })

          if (this.viewModel.getFilteredOrders().length === 0) {
            Text('暂无量产工单').fontSize('15fp').fontColor('#999999').width('100%').padding({ top: '60vp' })
          }

          Blank().height('20vp')
        }
        .width('100%')
      }
      .layoutWeight(1).scrollBar(BarState.Off).align(Alignment.TopStart).backgroundColor('#E8EDF2')

      // 底部快捷操作卡片
      this.buildBottomQuickCard()
    }
    .width('100%').height('100%').backgroundColor('#E8EDF2')
  }

  @Builder
  buildOrderCard(order: WorkOrder) {
    Column() {
      // 第一行：工单号 + 类型标签
      Row() {
        Text(order.code)
          .fontSize('17fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold)
        Blank()
        Text(order.type)
          .fontSize('11fp').fontColor('#007DFF')
          .padding({ left: '10vp', right: '10vp', top: '3vp', bottom: '3vp' })
          .borderRadius('8vp').backgroundColor('#E3F2FD')
      }
      .width('100%')

      // 工单来源
      Text('工单来源：' + order.source)
        .fontSize('12fp').fontColor('#6B7B8C').width('100%').margin({ top: '8vp' })

      // 产品编码 + 操作员
      Text('产品编码：' + order.productCode + (order.operatorName ? ' / 操作员：' + order.operatorName : ''))
        .fontSize('12fp').fontColor('#6B7B8C').width('100%').margin({ top: '4vp' })

      // 产品名 + 状态标签
      Row() {
        Text(order.productName)
          .fontSize('14fp').fontColor('#1A2B3C').fontWeight(FontWeight.Medium).layoutWeight(1)
        this.buildStatusBadge(order.status)
      }
      .width('100%').margin({ top: '8vp' })

      // 抽检按钮
      Button() {
        Text('抽检').fontSize('13fp').fontColor('#007DFF').fontWeight(FontWeight.Medium)
      }
      .width('100%').height('36vp').borderRadius('6vp')
      .backgroundColor('#E3F2FD')
      .margin({ top: '10vp' })
      .onClick(() => { this.onInspectClick?.(order.code); })
    }
    .width('100%').padding('14vp').borderRadius('12vp').backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, bottom: '10vp' })
    .shadow({ radius: 3, color: '#0F000000', offsetY: 1 })
  }

  @Builder
  buildStatusBadge(status: string) {
    Text(status)
      .fontSize('12fp').fontWeight(FontWeight.Medium)
      .padding({ left: '12vp', right: '12vp', top: '4vp', bottom: '4vp' })
      .borderRadius('8vp')
      .fontColor(this.getStatusTextColor(status))
      .backgroundColor(this.getStatusBgColor(status))
  }

  getStatusTextColor(status: string): string {
    if (status === '生产中') return '#FFFFFF';
    if (status === '待报工') return '#FFFFFF';
    if (status === '已报工') return '#FFFFFF';
    return '#333333';
  }

  getStatusBgColor(status: string): string {
    if (status === '生产中') return '#2196F3';
    if (status === '待报工') return '#FF9800';
    if (status === '已报工') return '#4CAF50';
    return '#999999';
  }

  // 底部快捷操作卡片
  @Builder
  buildBottomQuickCard() {
    Row() {
      Column() {
        Text('无线充电器组装')
          .fontSize('16fp').fontColor('#1A2B3C').fontWeight(FontWeight.Bold)
      }
      .layoutWeight(1).alignItems(HorizontalAlign.Start)

      Button() {
        Text('去抽检').fontSize('14fp').fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
      }
      .height('40vp').padding({ left: '24vp', right: '24vp' })
      .borderRadius('8vp').backgroundColor('#007DFF')
      .onClick(() => { this.onNavigate?.('inspection'); })
    }
    .width('100%').padding('14vp')
    .borderRadius('12vp').backgroundColor('#FFFFFF')
    .margin({ left: this.cardPadding, right: this.cardPadding, bottom: '8vp' })
    .shadow({ radius: 4, color: '#0F000000', offsetY: -2 })
    .alignItems(VerticalAlign.Center)
  }
}
