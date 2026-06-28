import { ActionOption, AdminWorkOrderViewModel, StatusChangeResult } from '../viewModel/AdminWorkOrderViewModel';
import { CopyWorkOrderViewModel } from '../viewModel/CopyWorkOrderViewModel';
import { CopyWorkOrderView } from './CopyWorkOrderView';
import { WorkOrderDetailView } from './WorkOrderDetailView';
import { WorkOrderDetailViewModel } from '../viewModel/WorkOrderDetailViewModel';
import { LeaderCreateWorkOrderView } from './LeaderCreateWorkOrderView';
import { LeaderCreateWorkOrderViewModel } from '../viewModel/LeaderCreateWorkOrderViewModel';
import { WorkOrder } from 'utils';

@ComponentV2
export struct LeaderWorkOrderView {
  @Param viewModel: AdminWorkOrderViewModel = new AdminWorkOrderViewModel();
  @Param cardPadding: number = 16;
  private navStack: NavPathStack | null = null;
  @Local selectedOrder: WorkOrder | null = null;
  @Local showBottomSheet: boolean = false;
  @Local showCopyView: boolean = false;
  @Local copyViewModel: CopyWorkOrderViewModel = new CopyWorkOrderViewModel();
  @Local copySourceOrder: WorkOrder | null = null;
  @Local showDetailView: boolean = false;
  @Local detailViewModel: WorkOrderDetailViewModel = new WorkOrderDetailViewModel();
  @Local detailOrderId: number = 0;
  @Local selectedAction: string = '';
  @Local showSuccessDialog: boolean = false;
  @Local fromStatus: string = '';
  @Local toStatus: string = '';
  @Local showCreateView: boolean = false;
  @Local createViewModel: LeaderCreateWorkOrderViewModel = new LeaderCreateWorkOrderViewModel();

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
          this.viewModel.loadWorkOrders();
        },
        onStatusChanged: (orderId: number, action: string) => {
          this.viewModel.changeStatusLocal(orderId, action);
          this.viewModel.loadWorkOrders();
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
      LeaderCreateWorkOrderView({
        viewModel: this.createViewModel,
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
          Scroll() {
            Column() {
              this.buildSearchFilterCard()
              if (this.viewModel.hasAnyFilter()) {
                this.buildFilterChips()
              }
              Column() {
                ForEach(this.viewModel.getFilteredOrders(), (order: WorkOrder) => {
                  this.buildOrderCard(order)
                })
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
          .backgroundColor('#F0F4F8')
        }
        .width('100%')
        .height('100%')

        if (this.showBottomSheet && this.selectedOrder) {
          this.buildMask()
          this.buildBottomSheet()
        }

        if (this.showSuccessDialog) {
          this.buildSuccessDialog()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F0F4F8')
    }
  }

  @Builder
  buildMask() {
    Column() {
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#60000000')
    .onClick(() => {
      this.closeBottomSheet();
    })
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
      .backgroundColor('#F1F5F9')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .margin({ right: '12vp' })
      .onClick(() => {
        if (this.navStack) this.navStack.pop();
      })

      Column() {
        Text('工单管理')
          .fontSize('24fp')
          .fontColor('#0F172A')
          .fontWeight(FontWeight.Bold)
        Text('管理本班组所有工单')
          .fontSize('13fp')
          .fontColor('#64748B')
          .margin({ top: '2vp' })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Row() {
        Text('+')
          .fontSize('24fp')
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
      }
      .width('44vp')
      .height('44vp')
      .borderRadius('14vp')
      .linearGradient({
        direction: GradientDirection.Left,
        colors: [["#0EA5E9", 0.0], ["#0284C7", 1.0]]
      })
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .shadow({ radius: 8, color: "rgba(14, 165, 233, 0.3)", offsetY: 4 })
      .onClick(() => {
        this.showCreateView = true;
      })
    }
    .width('100%')
    .padding({ left: this.cardPadding, right: this.cardPadding, top: '16vp', bottom: '16vp' })
    .backgroundColor('#F0F4F8')
  }

  @Builder
  buildSearchFilterCard() {
    Column() {
      Row() {
        Row() {
          Text('🔍')
            .fontSize('16fp')
            .fontColor('#94A3B8')
            .margin({ right: '8vp' })
          TextInput({ text: this.viewModel.searchKeyword, placeholder: '搜索工单编号、产品名称' })
            .fontSize('14fp')
            .fontColor('#1E293B')
            .placeholderColor('#94A3B8')
            .backgroundColor(Color.Transparent)
            .layoutWeight(1)
            .height('100%')
            .onChange((v: string) => {
              this.viewModel.searchKeyword = v;
            })
            .onSubmit(() => {
              this.viewModel.loadWorkOrders();
            })
            
          if (this.viewModel.searchKeyword) {
            Text('搜索')
              .fontSize('14fp')
              .fontColor('#0EA5E9')
              .fontWeight(FontWeight.Medium)
              .padding({ left: '8vp', right: '8vp', top: '4vp', bottom: '4vp' })
              .onClick(() => { this.viewModel.loadWorkOrders(); })
          }
        }
        .layoutWeight(1)
        .height('44vp')
        .borderRadius('12vp')
        .backgroundColor('#F1F5F9')
        .padding({ left: '14vp', right: '14vp' })
        .alignItems(VerticalAlign.Center)

        Column() {
          Text('⇅')
            .fontSize('16fp')
            .fontColor('#0EA5E9')
            .margin({ bottom: '2vp' })
          Text('筛选')
            .fontSize('11fp')
            .fontColor('#0EA5E9')
            .fontWeight(FontWeight.Medium)
        }
        .height('44vp')
        .padding({ left: '14vp', right: '14vp' })
        .borderRadius('12vp')
        .backgroundColor('#E0F2FE')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .margin({ left: '10vp' })
        .onClick(() => {
          this.viewModel.toggleFilterPanel();
        })
      }
      .width('100%')

      if (this.viewModel.showFilterPanel) {
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
        .padding({ top: '16vp' })
      }
    }
    .width('100%')
    .padding('16vp')
    .borderRadius('20vp')
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 12, color: "rgba(15, 23, 42, 0.04)", offsetY: 2 })
    .margin({ left: this.cardPadding, right: this.cardPadding })
  }

  @Builder
  buildMiniChip(label: string, active: boolean, onClick: () => void) {
    Text(label)
      .fontSize('12fp')
      .fontColor(active ? '#FFFFFF' : '#1A2B3C')
      .padding({ left: '12vp', right: '12vp', top: '6vp', bottom: '6vp' })
      .borderRadius('14vp')
      .backgroundColor(active ? '#0EA5E9' : '#F1F5F9')
      .margin({ right: '8vp', bottom: '8vp' })
      .onClick(onClick)
  }

  @Builder
  buildFilterChips() {
    Scroll() {
      Row({ space: 8 }) {
        if (this.viewModel.typeFilter) {
          this.buildActiveChip('工单类型: ' + this.viewModel.typeFilter, '#ECFDF5', '#0F766E', () => { this.viewModel.typeFilter = ''; this.viewModel.loadWorkOrders(); })
        }
        if (this.viewModel.statusFilter) {
          this.buildActiveChip('状态: ' + this.viewModel.statusFilter, '#F1F5F9', '#475569', () => { this.viewModel.statusFilter = ''; this.viewModel.loadWorkOrders(); })
        }
        if (this.viewModel.lineFilter) {
          this.buildActiveChip('当前产线: ' + this.viewModel.lineFilter, '#F1F5F9', '#475569', () => { this.viewModel.lineFilter = ''; this.viewModel.loadWorkOrders(); })
        }
      }
      .padding({ left: this.cardPadding, right: this.cardPadding, top: '12vp' })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }

  @Builder
  buildActiveChip(label: string, bg: string, color: string, onClose: () => void) {
    Row() {
      Text(label)
        .fontSize('14fp')
        .fontColor(color)
      Text(' ×')
        .fontSize('14fp')
        .fontColor(color)
        .margin({ left: '4vp' })
        .onClick(onClose)
    }
    .padding({ left: '12vp', right: '12vp', top: '6vp', bottom: '6vp' })
    .borderRadius('16vp')
    .backgroundColor(bg)
    .margin({ right: '8vp' })
  }

  @Builder
  buildOrderCard(order: WorkOrder) {
    Column() {
      Row() {
        Text(order.code)
          .fontSize('18fp')
          .fontColor('#0EA5E9')
          .fontWeight(FontWeight.Bold)
        Blank()
        Column() {
          Text(order.type)
            .fontSize('12fp')
            .fontColor('#0EA5E9')
            .fontWeight(FontWeight.Medium)
            .padding({ left: '10vp', right: '10vp', top: '4vp', bottom: '4vp' })
            .borderRadius('8vp')
            .backgroundColor('#E0F2FE')
          Text(order.status)
            .fontSize('14fp')
            .fontColor(this.viewModel.getStatusColor(order.status))
            .fontWeight(FontWeight.Bold)
            .margin({ top: '6vp' })
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')

      Text('工单来源：' + order.source)
        .fontSize('13fp')
        .fontColor('#64748B')
        .width('100%')
        .margin({ top: '10vp' })

      Text(this.buildCodeLine(order))
        .fontSize('13fp')
        .fontColor('#64748B')
        .width('100%')
        .margin({ top: '4vp' })

      Text(order.productName)
        .fontSize('18fp')
        .fontColor('#0F172A')
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .margin({ top: '8vp' })

      Row() {
        if (order.status === '已报工' || order.status === '完工' || order.status === '已报废') {
          Text('状态变更')
            .fontSize('14fp')
            .fontColor('#CBD5E1')
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
            .height('44vp')
            .borderRadius('12vp')
            .backgroundColor('#F8FAFC')
            .border({ width: '1vp', color: '#E2E8F0' })
            .textAlign(TextAlign.Center)
        } else {
          Text('状态变更')
            .fontSize('14fp')
            .fontColor(order.highlighted ? '#B45309' : '#334155')
            .fontWeight(order.highlighted ? FontWeight.Bold : FontWeight.Medium)
            .layoutWeight(1)
            .height('44vp')
            .borderRadius('12vp')
            .backgroundColor(order.highlighted ? '#FFFBEB' : '#F8FAFC')
            .border({ width: order.highlighted ? '1.5vp' : '1vp', color: order.highlighted ? '#FDE68A' : '#E2E8F0' })
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.selectedOrder = order;
              this.selectedAction = '';
              const actions: ActionOption[] = this.viewModel.getAvailableActions(order.status);
              if (actions.length > 0) {
                this.selectedAction = actions[0].action;
              }
              this.showBottomSheet = true;
            })
        }
        Text('复制新增')
          .fontSize('14fp')
          .fontColor('#334155')
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .height('44vp')
          .borderRadius('12vp')
          .backgroundColor('#FFFFFF')
          .border({ width: '1vp', color: '#E2E8F0' })
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
      .margin({ top: '14vp' })
    }
    .width('100%')
    .padding('18vp')
    .borderRadius('18vp')
    .backgroundColor('#FFFFFF')
    .border(order.highlighted ? { width: '2vp', color: '#FCD34D' } : { width: '1vp', color: '#E2E8F0' })
    .shadow({ radius: 10, color: "rgba(15, 23, 42, 0.04)", offsetY: 2 })
    .margin({ left: this.cardPadding, right: this.cardPadding, bottom: '10vp' })
    .onClick(() => {
      const vm: WorkOrderDetailViewModel = new WorkOrderDetailViewModel();
      this.detailViewModel = vm;
      this.detailOrderId = order.id;
      this.showDetailView = true;
    })
  }

  buildCodeLine(order: WorkOrder): string {
    let line: string = '产品编码：' + order.productCode;
    if (order.operatorName) {
      line += ' / 操作员：' + order.operatorName;
    }
    return line;
  }

  closeBottomSheet(): void {
    this.showBottomSheet = false;
    this.selectedOrder = null;
    this.selectedAction = '';
  }

  @Builder
  buildBottomSheet() {
    Column() {
      Blank()
      Column() {
        Row() {
        }
        .width('48vp')
        .height('6vp')
        .borderRadius('3vp')
        .backgroundColor('#CBD5E1')
        .margin({ top: '12vp', bottom: '20vp' })

        Row() {
          Text('状态变更')
            .fontSize('24fp')
            .fontColor('#0F172A')
            .fontWeight(FontWeight.Bold)
          Blank()
          Text('当前工单状态：' + this.selectedOrder!.status)
            .fontSize('18fp')
            .fontColor('#64748B')
        }
        .width('100%')
        .margin({ bottom: '20vp' })

        this.buildActionChips()

        Row() {
          Button() {
            Text('取消')
              .fontSize('20fp')
              .fontColor('#334155')
              .fontWeight(FontWeight.Medium)
          }
          .layoutWeight(1)
          .height('52vp')
          .borderRadius('16vp')
          .backgroundColor('#FFFFFF')
          .border({ width: '1.5vp', color: '#E2E8F0' })
          .onClick(() => {
            this.closeBottomSheet();
          })

          Blank().width('12vp')

          Button() {
            Text('确定')
              .fontSize('20fp')
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
          }
          .layoutWeight(1)
          .height('52vp')
          .borderRadius('16vp')
          .backgroundColor('#0F172A')
          .onClick(() => {
            this.doConfirmChange();
          })
        }
        .width('100%')
        .margin({ top: '24vp', bottom: '24vp' })
      }
      .width('100%')
      .padding({ left: '20vp', right: '20vp' })
      .borderRadius({ topLeft: '28vp', topRight: '28vp' })
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.Center)
  }

  getCurrentActions(): ActionOption[] {
    if (!this.selectedOrder) return [];
    return this.viewModel.getAvailableActions(this.selectedOrder.status);
  }

  getActionTextColor(action: string): string {
    if (this.selectedAction === action) {
      return this.viewModel.isDangerAction(action) ? '#DC2626' : '#0D9488';
    }
    return '#475569';
  }

  getActionBgColor(action: string): string {
    if (this.selectedAction === action) {
      return this.viewModel.isDangerAction(action) ? '#FEF2F2' : '#ECFDF5';
    }
    return '#F1F5F9';
  }

  getStatusBgColor(status: string): string {
    if (status === '生产中') return '#ECFDF5';
    if (status === '已报工') return '#E8F5E9';
    if (status === '生产完成' || status === '完工') return '#E8F5E9';
    if (status === '已派工') return '#FFF3E0';
    if (status === '发放') return '#FFFBEB';
    if (status === '发放暂停') return '#FFFBEB';
    if (status === '待派工') return '#F1F5F9';
    if (status === '暂停中' || status === '生产中暂停') return '#FFF3E0';
    if (status === '已报废') return '#FFEBEE';
    return '#F1F5F9';
  }

  @Builder
  buildActionChips() {
    if (this.selectedOrder && this.getCurrentActions().length > 0) {
      Row() {
        ForEach(this.getCurrentActions(), (act: ActionOption) => {
          Text(act.label)
            .fontSize('20fp')
            .fontColor(this.getActionTextColor(act.action))
            .fontWeight(FontWeight.Bold)
            .padding({ left: '20vp', right: '20vp', top: '12vp', bottom: '12vp' })
            .borderRadius('20vp')
            .backgroundColor(this.getActionBgColor(act.action))
            .margin({ right: '12vp' })
            .onClick(() => {
              this.selectedAction = act.action;
            })
        }, (act: ActionOption) => act.action)
      }
      .width('100%')
    }
  }

  async doConfirmChange(): Promise<void> {
    if (!this.selectedOrder || this.selectedAction.length === 0) return;
    const orderId: number = this.selectedOrder.id;
    const result: StatusChangeResult | null = this.viewModel.changeStatusLocal(orderId, this.selectedAction);
    this.closeBottomSheet();
    if (result) {
      try {
        await this.viewModel.transitionWorkOrder(orderId, this.selectedAction);
      } catch (_) {
      }
      this.fromStatus = result.from;
      this.toStatus = result.to;
      this.showSuccessDialog = true;
    }
  }

  @Builder
  buildSuccessDialog() {
    Column() {
      Column() {
        Row() {
          Text('✓')
            .fontSize('40fp')
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
        }
        .width('80vp')
        .height('80vp')
        .borderRadius('40vp')
        .backgroundColor('#10B981')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)

        Text('状态已变更')
          .fontSize('26fp')
          .fontColor('#0F172A')
          .fontWeight(FontWeight.Bold)
          .margin({ top: '20vp' })

        Row() {
          Text(this.fromStatus)
            .fontSize('20fp')
            .fontColor(this.viewModel.getStatusColor(this.fromStatus))
            .fontWeight(FontWeight.Bold)
            .padding({ left: '16vp', right: '16vp', top: '8vp', bottom: '8vp' })
            .borderRadius('16vp')
            .backgroundColor(this.getStatusBgColor(this.fromStatus))
          Text('→')
            .fontSize('24fp')
            .fontColor('#94A3B8')
            .margin({ left: '12vp', right: '12vp' })
          Text(this.toStatus)
            .fontSize('20fp')
            .fontColor(this.viewModel.getStatusColor(this.toStatus))
            .fontWeight(FontWeight.Bold)
            .padding({ left: '16vp', right: '16vp', top: '8vp', bottom: '8vp' })
            .borderRadius('16vp')
            .backgroundColor(this.getStatusBgColor(this.toStatus))
        }
        .margin({ top: '16vp' })

        Text('点击任意位置关闭')
          .fontSize('18fp')
          .fontColor('#94A3B8')
          .margin({ top: '20vp' })
      }
      .padding('32vp')
      .borderRadius('28vp')
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 20, color: '#30000000' })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#60000000')
    .onClick(() => {
      this.showSuccessDialog = false;
      this.fromStatus = '';
      this.toStatus = '';
    })
  }
}
