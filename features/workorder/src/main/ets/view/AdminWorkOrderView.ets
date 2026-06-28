import { AdminWorkOrderViewModel } from '../viewModel/AdminWorkOrderViewModel';
import { CopyWorkOrderViewModel } from '../viewModel/CopyWorkOrderViewModel';
import { CopyWorkOrderView } from './CopyWorkOrderView';
import { CreateWorkOrderView } from './CreateWorkOrderView';
import { WorkOrderDetailView } from './WorkOrderDetailView';
import { WorkOrderDetailViewModel } from '../viewModel/WorkOrderDetailViewModel';
import { WorkOrder } from 'utils';

@ComponentV2
export struct AdminWorkOrderView {
  @Param viewModel: AdminWorkOrderViewModel = new AdminWorkOrderViewModel();
  @Param cardPadding: number = 16;
  private navStack: NavPathStack | null = null;
  @Local selectedOrder: WorkOrder | null = null;
  @Local showDialog: boolean = false;
  @Local showCopyView: boolean = false;
  @Local showCreateView: boolean = false;
  @Local copyViewModel: CopyWorkOrderViewModel = new CopyWorkOrderViewModel();
  @Local copySourceOrder: WorkOrder | null = null;
  @Local showDetailView: boolean = false;
  @Local detailViewModel: WorkOrderDetailViewModel = new WorkOrderDetailViewModel();
  @Local detailOrderId: number = 0;
  @Local toastMessage: string = '';
  @Local showToast: boolean = false;
  @Local selectedAction: string = '';

  aboutToAppear(): void {
    this.viewModel.init();
    this.navStack = AppStorage.get('navPathStack') as NavPathStack;
  }

  build() {
    if (this.showDetailView && this.detailOrderId > 0) {
      WorkOrderDetailView({
        viewModel: this.detailViewModel,
        orderId: this.detailOrderId,
        onBack: () => {
          this.showDetailView = false;
          this.detailOrderId = 0;
          // 详情页可能修改了状态，返回时刷新列表
          this.viewModel.loadWorkOrders();
        },
        onModify: () => {
          // 预留修改接口
        }
      })
    } else if (this.showCopyView && this.copySourceOrder) {
      CopyWorkOrderView({
        viewModel: this.copyViewModel,
        sourceOrder: this.copySourceOrder,
        onBack: () => {
          this.showCopyView = false;
          this.copySourceOrder = null;
        },
        onSaved: () => {
          this.showCopyView = false;
          this.copySourceOrder = null;
          this.viewModel.loadWorkOrders();
        }
      })
    } else if (this.showCreateView) {
      CreateWorkOrderView({
        onBack: () => {
          this.showCreateView = false;
        },
        onSaved: () => {
          this.showCreateView = false;
          this.viewModel.loadWorkOrders();
        }
      })
    } else {
    Stack() {
      Column() {
        this.buildHeader()
        this.buildRoleTabs()
        Scroll() {
          Column() {
            this.buildSearchFilterCard()
            if (this.viewModel.hasAnyFilter()) {
              this.buildFilterChips()
            }
            Column() {
              ForEach(this.viewModel.getFilteredOrders(), (order: WorkOrder) => {
                this.buildOrderCard(order)
              }, (order: WorkOrder) => order.id.toString() + '_' + order.status)
            }
            .width('100%')
            .margin({ top: '12vp' })
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

      // 状态变更弹窗
      if (this.showDialog && this.selectedOrder) {
        this.buildStatusDialog()
      }
      // Toast 提示
      if (this.showToast) {
        this.buildToast()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#E8EDF2')
    } // end else
  }

  @Builder
  buildToast() {
    Column() {
      Text(this.toastMessage)
        .fontSize('14fp').fontColor('#FFFFFF')
        .padding({ left: '20vp', right: '20vp', top: '10vp', bottom: '10vp' })
        .borderRadius('20vp')
        .backgroundColor('#CC000000')
    }
    .width('100%')
    .position({ x: 0, y: '70%' })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildStatusDialog() {
    Column() {
      Column() {
        Text('状态变更 — ' + this.selectedOrder!.code)
          .fontSize('17fp')
          .fontColor('#1A2B3C')
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: '8vp' })

        Text('当前状态：' + this.selectedOrder!.status)
          .fontSize('14fp')
          .fontColor(this.viewModel.getStatusColor(this.selectedOrder!.status))
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: '16vp' })

        // Selectable options
        if (this.selectedOrder!.status === '待派工') {
          this.buildOptionItem('dispatch', '派工', '#007DFF')
          this.buildOptionItem('scrap', '报废', '#F44336')
        } else if (this.selectedOrder!.status === '已派工') {
          this.buildOptionItem('start', '启动生产', '#007DFF')
          this.buildOptionItem('cancel_dispatch', '取消派工', '#FF9800')
        } else if (this.selectedOrder!.status === '生产中') {
          this.buildOptionItem('complete', '生产完成', '#4CAF50')
          this.buildOptionItem('pause', '暂停', '#FF9800')
        } else if (this.selectedOrder!.status === '暂停中' || this.selectedOrder!.status === '生产中暂停') {
          this.buildOptionItem('resume', '恢复生产', '#4CAF50')
          this.buildOptionItem('scrap', '报废', '#F44336')
        } else if (this.selectedOrder!.status === '生产完成') {
          this.buildOptionItem('confirm', '报工确认', '#4CAF50')
          this.buildOptionItem('back_to_prod', '返回生产', '#FF9800')
        } else if (this.selectedOrder!.status === '发放') {
          this.buildOptionItem('issue_to_dispatch', '转为待派工', '#007DFF')
          this.buildOptionItem('pause_issue', '暂停发放', '#FF9800')
          this.buildOptionItem('scrap', '报废', '#F44336')
        } else if (this.selectedOrder!.status === '发放暂停') {
          this.buildOptionItem('resume_issue', '恢复发放', '#4CAF50')
          this.buildOptionItem('scrap', '报废', '#F44336')
        } else {
          Text('当前状态无可执行操作')
            .fontSize('14fp').fontColor('#999999').margin({ bottom: '12vp' })
        }

        // Confirm button
        Button() {
          Text('确认').fontSize('16fp').fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .height('44vp')
        .borderRadius('8vp')
        .backgroundColor(this.selectedAction ? '#007DFF' : '#CCCCCC')
        .enabled(this.selectedAction.length > 0)
        .margin({ top: '12vp' })
        .onClick(() => {
          if (this.selectedAction.length > 0) {
            this.doTransition(this.selectedAction);
            this.selectedAction = '';
          }
        })

        Button() {
          Text('取消').fontSize('14fp').fontColor('#666666')
        }
        .width('100%')
        .height('40vp')
        .borderRadius('8vp')
        .backgroundColor('#F0F0F0')
        .margin({ top: '8vp' })
        .onClick(() => {
          this.showDialog = false;
          this.selectedOrder = null;
          this.selectedAction = '';
        })
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
    .onClick(() => {
      this.showDialog = false;
      this.selectedOrder = null;
      this.selectedAction = '';
    })
  }

  @Builder
  buildOptionItem(action: string, label: string, color: string) {
    Row() {
      Column() {
        if (this.selectedAction === action) {
          Text('●').fontSize('16fp').fontColor(color)
        } else {
          Text('○').fontSize('16fp').fontColor('#CCCCCC')
        }
      }
      .width('24vp').alignItems(HorizontalAlign.Center).margin({ right: '10vp' })

      Text(label)
        .fontSize('15fp')
        .fontColor(this.selectedAction === action ? color : '#333333')
        .fontWeight(this.selectedAction === action ? FontWeight.Bold : FontWeight.Normal)
        .layoutWeight(1)
    }
    .width('100%')
    .height('44vp')
    .padding({ left: '12vp', right: '12vp' })
    .borderRadius('8vp')
    .backgroundColor(this.selectedAction === action ? color + '15' : '#F5F6F8')
    .border({ width: '1vp', color: this.selectedAction === action ? color : '#E8EAED' })
    .margin({ bottom: '8vp' })
    .onClick(() => {
      this.selectedAction = action;
    })
  }

  async doTransition(action: string): Promise<void> {
    if (!this.selectedOrder) return;
    this.showDialog = false;
    const orderId: number = this.selectedOrder.id;
    this.selectedOrder = null;
    try {
      await this.viewModel.transitionWorkOrder(orderId, action);
      this.toastMessage = '状态变更成功';
      this.showToast = true;
      setTimeout(() => { this.showToast = false; }, 1500);
    } catch (e) {
      this.toastMessage = e instanceof Error ? e.message : '状态变更失败';
      this.showToast = true;
      setTimeout(() => { this.showToast = false; }, 1500);
    }
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
        Text('工单总览')
          .fontSize('18fp')
          .fontColor('#1A2B3C')
          .fontWeight(FontWeight.Bold)
        Text('查看全产线所有工单数据')
          .fontSize('12fp')
          .fontColor('#6B7B8C')
          .margin({ top: '2vp' })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Column() {
        Text('+')
          .fontSize('24fp')
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
      }
      .width('40vp')
      .height('40vp')
      .borderRadius('10vp')
      .backgroundColor('#4CAF8E')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        this.showCreateView = true;
      })
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '16vp', bottom: '12vp' })
  }

  @Builder
  buildRoleTabs() {
    Row() {
      this.buildRoleTabItem('全部', 0)
      this.buildRoleTabItem('班组长', 1)
      this.buildRoleTabItem('操作员', 2)
      this.buildRoleTabItem('质检员', 3)
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, bottom: '12vp' })
  }

  @Builder
  buildRoleTabItem(label: string, index: number) {
    Text(label)
      .fontSize('13fp')
      .fontColor(this.viewModel.currentRoleTab === index ? '#FFFFFF' : '#1A2B3C')
      .fontWeight(FontWeight.Medium)
      .layoutWeight(1)
      .height('36vp')
      .borderRadius('8vp')
      .backgroundColor(this.viewModel.currentRoleTab === index ? '#1F2D3D' : 'transparent')
      .textAlign(TextAlign.Center)
      .onClick(() => {
        this.viewModel.switchRoleTab(index);
      })
  }

  @Builder
  buildSearchFilterCard() {
    Row() {
      // 二维码扫描按钮
      Column() {
        Text('▦')
          .fontSize('18fp')
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
      }
      .width('40vp')
      .height('40vp')
      .borderRadius('8vp')
      .backgroundColor('#1F2D3D')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .margin({ right: '10vp' })

      // 搜索框
      Row() {
        Text('🔍')
          .fontSize('14fp')
          .fontColor('#9AA5B1')
          .margin({ right: '6vp' })
        TextInput({ text: this.viewModel.searchKeyword, placeholder: '输入单号/产品/产线...' })
          .fontSize('13fp')
          .fontColor('#1A2B3C')
          .backgroundColor('transparent')
          .layoutWeight(1)
          .height('40vp')
          .onChange((v: string) => { this.viewModel.searchKeyword = v; })
          .onSubmit(() => { this.viewModel.loadWorkOrders(); })
          
        if (this.viewModel.searchKeyword) {
          Text('搜索')
            .fontSize('13fp')
            .fontColor('#007DFF')
            .fontWeight(FontWeight.Medium)
            .padding({ left: '8vp', right: '8vp', top: '4vp', bottom: '4vp' })
            .onClick(() => { this.viewModel.loadWorkOrders(); })
        }
      }
      .layoutWeight(1)
      .height('40vp')
      .borderRadius('8vp')
      .backgroundColor('#E8EDF2')
      .padding({ left: '10vp', right: '10vp' })
      .alignItems(VerticalAlign.Center)
      .margin({ right: '10vp' })

      // 筛选按钮
      Row() {
        Text('⇅')
          .fontSize('16fp')
          .fontColor('#1A2B3C')
          .margin({ right: '4vp' })
        Text('筛选')
          .fontSize('13fp')
          .fontColor('#1A2B3C')
          .fontWeight(FontWeight.Medium)
      }
      .height('40vp')
      .padding({ left: '10vp', right: '10vp' })
      .borderRadius('8vp')
      .backgroundColor('#FFFFFF')
      .border({ width: '1px', color: '#E0E5EB' })
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.viewModel.toggleFilterPanel();
      })
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding })

    // 筛选面板（弹出）
    if (this.viewModel.showFilterPanel) {
      Column() {
        this.buildFilterPanelContent()
      }
      .width('100%')
      .padding({ left: this.cardPadding, right: this.cardPadding, top: '12vp' })
    }
  }

  @Builder
  buildFilterPanelContent() {
    Column() {
      Text('工单类型')
        .fontSize('12fp')
        .fontColor('#6B7B8C')
        .width('100%')
        .margin({ bottom: '6vp' })
      Row() {
        this.buildMiniChip('全部', this.viewModel.typeFilter === '', () => { this.viewModel.typeFilter = ''; this.viewModel.loadWorkOrders(); })
        this.buildMiniChip('量产', this.viewModel.typeFilter === '量产', () => { this.viewModel.typeFilter = '量产'; this.viewModel.loadWorkOrders(); })
        this.buildMiniChip('试产', this.viewModel.typeFilter === '试产', () => { this.viewModel.typeFilter = '试产'; this.viewModel.loadWorkOrders(); })
      }
      .width('100%')

      Text('状态')
        .fontSize('12fp')
        .fontColor('#6B7B8C')
        .width('100%')
        .margin({ top: '12vp', bottom: '6vp' })
      Flex({ wrap: FlexWrap.Wrap }) {
        this.buildMiniChip('全部', this.viewModel.statusFilter === '', () => { this.viewModel.statusFilter = ''; this.viewModel.loadWorkOrders(); })
        this.buildMiniChip('待派工', this.viewModel.statusFilter === '待派工', () => { this.viewModel.statusFilter = '待派工'; this.viewModel.loadWorkOrders(); })
        this.buildMiniChip('已派工', this.viewModel.statusFilter === '已派工', () => { this.viewModel.statusFilter = '已派工'; this.viewModel.loadWorkOrders(); })
        this.buildMiniChip('生产中', this.viewModel.statusFilter === '生产中', () => { this.viewModel.statusFilter = '生产中'; this.viewModel.loadWorkOrders(); })
        this.buildMiniChip('暂停中', this.viewModel.statusFilter === '暂停中', () => { this.viewModel.statusFilter = '暂停中'; this.viewModel.loadWorkOrders(); })
        this.buildMiniChip('生产完成', this.viewModel.statusFilter === '生产完成', () => { this.viewModel.statusFilter = '生产完成'; this.viewModel.loadWorkOrders(); })
      }
      .width('100%')

      Text('当前产线')
        .fontSize('12fp')
        .fontColor('#6B7B8C')
        .width('100%')
        .margin({ top: '12vp', bottom: '6vp' })
      Row() {
        this.buildMiniChip('全部', this.viewModel.lineFilter === '', () => { this.viewModel.lineFilter = ''; this.viewModel.loadWorkOrders(); })
        this.buildMiniChip('柔性组装线', this.viewModel.lineFilter === '柔性组装线', () => { this.viewModel.lineFilter = '柔性组装线'; this.viewModel.loadWorkOrders(); })
      }
      .width('100%')
    }
    .width('100%')
    .padding('12vp')
    .borderRadius('10vp')
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 4, color: '#1F000000', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildMiniChip(label: string, active: boolean, onClick: () => void) {
    Text(label)
      .fontSize('12fp')
      .fontColor(active ? '#FFFFFF' : '#1A2B3C')
      .padding({ left: '12vp', right: '12vp', top: '6vp', bottom: '6vp' })
      .borderRadius('14vp')
      .backgroundColor(active ? '#007DFF' : '#F3F5F8')
      .margin({ right: '8vp', bottom: '8vp' })
      .onClick(onClick)
  }

  @Builder
  buildFilterChips() {
    Scroll() {
      Row({ space: 8 }) {
        if (this.viewModel.typeFilter) {
          this.buildActiveChip('工单类型', this.viewModel.typeFilter, () => { this.viewModel.typeFilter = ''; this.viewModel.loadWorkOrders(); })
        }
        if (this.viewModel.statusFilter) {
          this.buildActiveChip('状态', this.viewModel.statusFilter, () => { this.viewModel.statusFilter = ''; this.viewModel.loadWorkOrders(); })
        }
        if (this.viewModel.lineFilter) {
          this.buildActiveChip('当前产线', this.viewModel.lineFilter, () => { this.viewModel.lineFilter = ''; this.viewModel.loadWorkOrders(); })
        }
      }
      .padding({ left: this.cardPadding, right: this.cardPadding, top: '8vp', bottom: '8vp' })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }

  @Builder
  buildActiveChip(label: string, value: string, onClose: () => void) {
    Row() {
      Text(`${label}: ${value}`)
        .fontSize('12fp')
        .fontColor('#1A2B3C')
      Text(' ×')
        .fontSize('14fp')
        .fontColor('#9AA5B1')
        .margin({ left: '4vp' })
        .onClick(onClose)
    }
    .padding({ left: '10vp', right: '10vp', top: '6vp', bottom: '6vp' })
    .backgroundColor('#FFFFFF')
    .borderRadius('12vp')
    .border({ width: '1px', color: '#E0E5EB' })
  }

  @Builder
  buildOrderCard(order: WorkOrder) {
    Column() {
      // 顶部：工单号 + 量产标签 + 状态
      Row() {
        Text(order.code)
          .fontSize('13fp')
          .fontColor(order.highlighted ? '#1A2B3C' : '#1A2B3C')
          .fontWeight(FontWeight.Bold)
        Blank()
        Column() {
          Text(order.type)
            .fontSize('10fp')
            .fontColor('#007DFF')
            .padding({ left: '8vp', right: '8vp', top: '2vp', bottom: '2vp' })
            .borderRadius('10vp')
            .backgroundColor('#E3F2FD')
          Text(order.status)
            .fontSize('11fp')
            .fontColor(this.viewModel.getStatusColor(order.status))
            .fontWeight(FontWeight.Medium)
            .margin({ top: '4vp' })
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')

      // 工单来源
      Text('工单来源：' + order.source)
        .fontSize('11fp')
        .fontColor('#6B7B8C')
        .width('100%')
        .margin({ top: '8vp' })

      // 产品编码 + 操作员
      Text(this.buildCodeLine(order))
        .fontSize('11fp')
        .fontColor('#6B7B8C')
        .width('100%')
        .margin({ top: '2vp' })

      // 产品名
      Text(order.productName)
        .fontSize('15fp')
        .fontColor('#1A2B3C')
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .margin({ top: '4vp' })

      // 底部按钮
      Row() {
        if (order.status === '已报工' || order.status === '已报废') {
          Text('状态变更')
            .fontSize('13fp')
            .fontColor('#CCCCCC')
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
            .height('36vp')
            .borderRadius('6vp')
            .backgroundColor('#F5F5F5')
            .border({ width: '1vp', color: '#E0E5EB' })
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.toastMessage = '状态已无法进行变更';
              this.showToast = true;
              setTimeout(() => { this.showToast = false; }, 2000);
            })
        } else {
          Text('状态变更')
            .fontSize('13fp')
            .fontColor('#E58A00')
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
            .height('36vp')
            .borderRadius('6vp')
            .backgroundColor(order.highlighted ? '#FFF3D6' : '#FFFFFF')
            .border({ width: '1vp', color: order.highlighted ? '#F0B400' : '#E0E5EB' })
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.selectedOrder = order;
              this.showDialog = true;
            })
        }
        Text('复制新增')
          .fontSize('13fp')
          .fontColor('#1A2B3C')
          .layoutWeight(1)
          .height('36vp')
          .borderRadius('6vp')
          .backgroundColor('#FFFFFF')
          .border({ width: '1vp', color: '#E0E5EB' })
          .textAlign(TextAlign.Center)
          .margin({ left: '10vp' })
          .onClick(() => {
            this.copySourceOrder = order;
            const vm: CopyWorkOrderViewModel = new CopyWorkOrderViewModel();
            vm.init(order);
            this.copyViewModel = vm;
            this.showCopyView = true;
          })
      }
      .width('100%')
      .margin({ top: '12vp' })
    }
    .width('100%')
    .padding('14vp')
    .borderRadius('12vp')
    .backgroundColor('#FFFFFF')
    .border(order.highlighted ? { width: '1.5vp', color: '#F0B400' } : { width: '0' })
    .margin({ left: this.cardPadding, right: this.cardPadding, bottom: '10vp' })
    .onClick(() => {
      const vm: WorkOrderDetailViewModel = new WorkOrderDetailViewModel();
      this.detailViewModel = vm;
      this.detailOrderId = order.id;
      this.showDetailView = true;
    })
  }

  buildCodeLine(order: WorkOrder): string {
    let line = '产品编码：' + order.productCode;
    if (order.operatorName) {
      line += ' / 操作员：' + order.operatorName;
    }
    return line;
  }

}
