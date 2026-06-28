/**
 * String constants for WO Management App
 */
export class StringConstants {
  static readonly APP_TITLE: string = "工业管理APP";
  static readonly LOGIN_TITLE: string = "工业管理平台";
  static readonly LOGIN_SUBTITLE: string = "柔性组装MES教学/仿真版";
  static readonly LOGIN_BTN: string = "进入系统";
  static readonly LOGIN_SELECT_ROLE: string = "请选择角色";

  // Roles
  static readonly ROLE_LEADER: string = "班组长";
  static readonly ROLE_OPERATOR: string = "操作员";
  static readonly ROLE_INSPECTOR: string = "质检员";
  static readonly ROLE_ADMIN: string = "管理员";

  // Navigation tabs
  static readonly TAB_WORKBENCH: string = "工作台";
  static readonly TAB_DATA: string = "数据";
  static readonly TAB_WORKORDER: string = "工单";
  static readonly TAB_MY: string = "我的";

  // Work order statuses
  static readonly STATUS_PENDING: string = "待派工";
  static readonly STATUS_ASSIGNED: string = "已派工";
  static readonly STATUS_PRODUCING: string = "生产中";
  static readonly STATUS_PAUSED: string = "暂停中";
  static readonly STATUS_COMPLETED: string = "生产完成";
  static readonly STATUS_REPORTED: string = "已报工";
  static readonly STATUS_FINISHED: string = "完工";
  static readonly STATUS_SCRAPPED: string = "报废";
}
