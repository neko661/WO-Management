import { CustomTabBar } from 'uicomponents';
import {
  LeaderWorkbenchView, OperatorWorkbenchView,
  InspectorWorkbenchView, AdminWorkbenchView,
  InspectionRecordView, ReportedWorkOrderDetailView, QCInspectionView
} from 'workbench';
import { AdminDataView, LeaderDataView, OperatorDataView, InspectorDataView,
  ProductionLineDetailView, WorkstationDetailView } from 'data';
import { AdminWorkOrderView, LeaderWorkOrderView, OperatorWorkOrderView, InspectorWorkOrderView,
  WorkOrderDetailView, WorkOrderDetailViewModel, OperatorProcessTaskView, OperatorProcessTaskViewModel } from 'workorder';
import { QualityOverviewView } from 'quality';
import { MyView, UserManageView, UserAddView, UserEditView, UserManageViewModel } from 'my';
import { SessionManager } from 'datastore';

@ComponentV2
export struct HomeTabsView {
  @Param role: string = '';
  @Event onLogout?: () => void;
  @Local currentTab: number = 0;
  @Local barH: number = 28;

  // 质检看板页面状态
  @Local showQualityOverview: boolean = false;

  // 工单详情页状态
  @Local showOrderDetail: boolean = false;
  @Local detailViewModel: WorkOrderDetailViewModel = new WorkOrderDetailViewModel();
  @Local detailOrderId: number = 0;

  // 产线详情页状态
  @Local showLineDetail: boolean = false;
  @Local currentLineId: number = 0;

  // 工作站详情页状态
  @Local showStationDetail: boolean = false;
  @Local currentStationId: number = 0;

  // 抽检记录页状态
  @Local showInspectionRecord: boolean = false;

  // 已报工工单详情页状态
  @Local showReportedDetail: boolean = false;
  @Local reportedOrderId: number = 0;

  // 质检抽检页状态
  @Local showQCInspection: boolean = false;
  @Local inspectOrderCode: string = '';

  // 工序任务页状态
  @Local showProcessTask: boolean = false;
  @Local processTaskViewModel: OperatorProcessTaskViewModel = new OperatorProcessTaskViewModel();

  // 人员管理页状态
  @Local showUserManage: boolean = false;
  @Local showUserAdd: boolean = false;
  @Local showUserEdit: boolean = false;
  @Local userManageViewModel: UserManageViewModel = new UserManageViewModel();
  @Local editUserId: number = 0;
  @Local currentUserId: number = 0;

  aboutToAppear(): void {
    const h: number = AppStorage.get('statusBarHeight') as number;
    if (h > 0) this.barH = h;
    this.loadCurrentUserId();
  }

  private async loadCurrentUserId(): Promise<void> {
    const userIdStr: string = await SessionManager.getInstance().getUserId();
    this.currentUserId = parseInt(userIdStr) || 0;
  }

  handleNavigate(target: string): void {
    if (target === 'data') {
      this.currentTab = 1;
    } else if (target === 'workorder') {
      this.currentTab = 2;
    } else if (target === 'quality') {
      this.showQualityOverview = true;
    } else if (target === 'inspection') {
      this.showInspectionRecord = true;
    } else if (target === 'production') {
      this.handleGoToProduction();
    } else if (target === 'usermanage') {
      this.showUserManage = true;
    }
  }

  handleOrderClick(orderId: number): void {
    const vm: WorkOrderDetailViewModel = new WorkOrderDetailViewModel();
    this.detailViewModel = vm;
    this.detailOrderId = orderId;
    this.showOrderDetail = true;
  }

  handleGoToProduction(): void {
    const vm: OperatorProcessTaskViewModel = new OperatorProcessTaskViewModel();
    this.processTaskViewModel = vm;
    this.showProcessTask = true;
  }

  handleLineClick(lineId: number): void {
    this.currentLineId = lineId;
    this.showLineDetail = true;
  }

  handleStationClick(stationId: number): void {
    this.currentStationId = stationId;
    this.showStationDetail = true;
  }

  closeOverlays(): void {
    this.showQualityOverview = false;
    this.showOrderDetail = false;
    this.detailOrderId = 0;
    this.showLineDetail = false;
    this.currentLineId = 0;
    this.showStationDetail = false;
    this.currentStationId = 0;
    this.showInspectionRecord = false;
    this.showReportedDetail = false;
    this.reportedOrderId = 0;
    this.showQCInspection = false;
    this.showProcessTask = false;
    this.showUserManage = false;
    this.showUserAdd = false;
    this.showUserEdit = false;
    this.editUserId = 0;
  }

  handleUserManageBack(): void {
    this.showUserManage = false;
    this.showUserAdd = false;
    this.showUserEdit = false;
    this.editUserId = 0;
  }

  handleUserAdd(): void {
    this.showUserAdd = true;
  }

  handleUserEdit(userId: number): void {
    this.editUserId = userId;
    this.showUserEdit = true;
  }

  build() {
    Column() {
      // 状态栏占位
      Blank().height(this.barH)

      // 质检抽检页
      if (this.showQCInspection) {
        QCInspectionView({
          orderCode: this.inspectOrderCode,
          onBack: () => { this.showQCInspection = false; }
        })
      } else if (this.showReportedDetail && this.reportedOrderId > 0) {
        ReportedWorkOrderDetailView({
          onBack: () => {
            this.showReportedDetail = false;
            this.reportedOrderId = 0;
          }
        })
      } else if (this.showInspectionRecord) {
        // 抽检记录页
        InspectionRecordView({
          onBack: () => { this.showInspectionRecord = false; },
          onOrderClick: (orderId: number) => {
            this.reportedOrderId = orderId;
            this.showReportedDetail = true;
          }
        })
      } else if (this.showOrderDetail && this.detailOrderId > 0) {
        // 工单详情页
        WorkOrderDetailView({
          viewModel: this.detailViewModel,
          orderId: this.detailOrderId,
          onBack: () => {
            this.showOrderDetail = false;
            this.detailOrderId = 0;
            if (this.role === 'operator') {
              this.processTaskViewModel.loadTasks();
            }
          }
        })
      } else if (this.showStationDetail && this.currentStationId > 0) {
        // 工作站详情页
        WorkstationDetailView({
          stationId: this.currentStationId,
          onBack: () => {
            this.showStationDetail = false;
            this.currentStationId = 0;
          }
        })
      } else if (this.showLineDetail && this.currentLineId > 0) {
        // 产线详情页
        ProductionLineDetailView({
          lineId: this.currentLineId,
          onBack: () => {
            this.showLineDetail = false;
            this.currentLineId = 0;
          },
          onStationClick: (stationId: number) => {
            this.handleStationClick(stationId);
          }
        })
      } else if (this.showQualityOverview) {
        // 质检看板
        QualityOverviewView({
          onBack: () => { this.showQualityOverview = false; }
        })
      } else if (this.showProcessTask) {
        // 工序任务页
        OperatorProcessTaskView({
          viewModel: this.processTaskViewModel,
          onBack: () => {
            this.showProcessTask = false;
          },
          onViewDetail: (orderId: number) => {
            this.handleOrderClick(orderId);
          }
        })
      } else if (this.showUserEdit && this.editUserId > 0) {
        // 编辑人员页
        UserEditView({
          viewModel: this.userManageViewModel,
          userId: this.editUserId,
          onBack: () => {
            this.showUserEdit = false;
            this.editUserId = 0;
          }
        })
      } else if (this.showUserAdd) {
        // 新增人员页
        UserAddView({
          viewModel: this.userManageViewModel,
          onBack: () => {
            this.showUserAdd = false;
          }
        })
      } else if (this.showUserManage) {
        // 人员管理列表页
        UserManageView({
          viewModel: this.userManageViewModel,
          currentUserId: this.currentUserId,
          currentRole: this.role,
          onBack: () => {
            this.showUserManage = false;
          },
          onAdd: () => {
            this.handleUserAdd();
          },
          onEdit: (userId: number) => {
            this.handleUserEdit(userId);
          }
        })
      } else {
        // 主 Tab 内容
        Column() {
          Column() {
            if (this.currentTab === 0) {
              if (this.role === 'leader') {
                LeaderWorkbenchView({
                  onNavigate: (target: string) => { this.handleNavigate(target); },
                  onOrderClick: (orderId: number) => { this.handleOrderClick(orderId); }
                })
              } else if (this.role === 'operator') {
                OperatorWorkbenchView({ onNavigate: (target: string) => { this.handleNavigate(target); } })
              } else if (this.role === 'inspector') {
                InspectorWorkbenchView({ onNavigate: (target: string) => { this.handleNavigate(target); } })
              } else {
                AdminWorkbenchView({ onNavigate: (target: string) => { this.handleNavigate(target); } })
              }
            } else if (this.currentTab === 1) {
              if (this.role === 'leader') {
                LeaderDataView({ onLineClick: (lineId: number) => { this.handleLineClick(lineId); } })
              } else if (this.role === 'operator') {
                OperatorDataView({ onLineClick: (lineId: number) => { this.handleLineClick(lineId); } })
              } else if (this.role === 'inspector') {
                InspectorDataView({ onLineClick: (lineId: number) => { this.handleLineClick(lineId); } })
              } else {
                AdminDataView({ onLineClick: (lineId: number) => { this.handleLineClick(lineId); } })
              }
            } else if (this.currentTab === 2) {
              if (this.role === 'leader') {
                LeaderWorkOrderView()
              } else if (this.role === 'operator') {
                OperatorWorkOrderView({
                  onViewDetail: (orderId: number) => { this.handleOrderClick(orderId); },
                  onGoToProduction: () => { this.handleGoToProduction(); }
                })
              } else if (this.role === 'inspector') {
                InspectorWorkOrderView({
                  onNavigate: (target: string) => { this.handleNavigate(target); },
                  onInspectClick: (orderCode: string) => { 
                    this.inspectOrderCode = orderCode;
                    this.showQCInspection = true; 
                  }
                })
              } else {
                AdminWorkOrderView()
              }
            } else {
              MyView({ 
                onLogout: this.onLogout,
                onNavigate: (target: string) => { this.handleNavigate(target); }
              })
            }
          }
          .layoutWeight(1)
          .width('100%')

          CustomTabBar({
            currentTab: this.currentTab,
            tabLabels: ['工作台', '数据', '工单', '我的'],
            tabIcons: [
              [$r('app.media.workbench_unselected'), $r('app.media.workbench_selected')],
              [$r('app.media.database_unselected'), $r('app.media.database_selected')],
              [$r('app.media.ticket_unselected'), $r('app.media.ticket_selected')],
              [$r('app.media.my_unselected'), $r('app.media.my_selected')]
            ],
            onTabChange: (tabIndex: number) => {
              this.currentTab = tabIndex;
              this.closeOverlays();
            }
          })
        }
        .layoutWeight(1)
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#E8EDF2')
  }
}
