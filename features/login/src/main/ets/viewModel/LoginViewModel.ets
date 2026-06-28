import { HttpApiService, TokenProvider } from "utils";
import { SessionManager } from "datastore";

export interface DemoAccount {
  employeeNo: string;
  name: string;
  role: string;
}

@ObservedV2
export class LoginViewModel {
  @Trace employeeNo: string = "";
  @Trace password: string = "";
  @Trace selectedRole: string = "";
  @Trace isLoading: boolean = false;
  @Trace errorMessage: string = "";
  @Trace step: number = 1;
  @Trace showRegister: boolean = false;

  // Registration fields
  @Trace regEmployeeNo: string = "";
  @Trace regName: string = "";
  @Trace regPassword: string = "";
  @Trace regRole: string = "operator";

  private apiService: HttpApiService = HttpApiService.getInstance();
  private session: SessionManager = SessionManager.getInstance();

  readonly roles: string[] = ["leader", "operator", "inspector", "admin"];

  readonly demoLeaderAccounts: DemoAccount[] = [
    { employeeNo: "leader", name: "王志刚", role: "leader" },
    { employeeNo: "leader2", name: "张建国", role: "leader" }
  ];

  readonly demoOperatorAccounts: DemoAccount[] = [
    { employeeNo: "operator", name: "刘伟", role: "operator" },
    { employeeNo: "operator2", name: "李强", role: "operator" },
    { employeeNo: "operator3", name: "赵敏", role: "operator" }
  ];

  readonly demoInspectorAccounts: DemoAccount[] = [
    { employeeNo: "inspector", name: "陈静", role: "inspector" },
    { employeeNo: "inspector2", name: "王芳", role: "inspector" }
  ];

  getRoleLabel(role: string): string {
    if (role === "leader") return "班组长";
    if (role === "operator") return "操作员";
    if (role === "inspector") return "质检员";
    if (role === "admin") return "管理员";
    return role;
  }

  getRoleDesc(role: string): string {
    if (role === "leader") return "维护本班组工单，派工、确认工时、异常处理";
    if (role === "operator") return "执行工单生产，启动产线、报工、异常上报";
    if (role === "inspector") return "抽检已报工工单，录入质检结果";
    if (role === "admin") return "全权限：人员管理、基础数据维护、全局工单总览";
    return "";
  }

  getRoleIcon(role: string): string {
    if (role === "leader") return "班";
    if (role === "operator") return "操";
    if (role === "inspector") return "检";
    if (role === "admin") return "管";
    return "";
  }

  getRoleColor(role: string): string {
    if (role === "leader") return "#10B981";
    if (role === "operator") return "#F59E0B";
    if (role === "inspector") return "#3B82F6";
    if (role === "admin") return "#EF4444";
    return "";
  }

  getRoleColorLight(role: string): string {
    if (role === "leader") return "#34D399";
    if (role === "operator") return "#FBBF24";
    if (role === "inspector") return "#60A5FA";
    if (role === "admin") return "#F87171";
    return "";
  }

  getRoleBgColor(role: string): string {
    if (role === "leader") return "#E8F5E9";
    if (role === "operator") return "#FFF3E0";
    if (role === "inspector") return "#E3F2FD";
    if (role === "admin") return "#FFEBEE";
    return "";
  }

  needsAccountSelection(role: string): boolean {
    return role === "leader" || role === "operator" || role === "inspector" || role === "admin";
  }

  /**
   * Select a role. Leader/Operator/Inspector/Admin go to account selection/login step.
   */
  async selectRole(role: string, onSuccess: () => void): Promise<void> {
    this.selectedRole = role;
    this.errorMessage = "";
    this.employeeNo = "";
    this.password = "";

    // All roles go to login/account selection
    this.step = 2;
    this.showRegister = false;
  }

  async quickLogin(employeeNo: string, onSuccess: () => void): Promise<void> {
    this.isLoading = true;
    this.errorMessage = "";
    try {
      const response = await this.apiService.login(employeeNo, "123456", this.selectedRole);
      if (response.code === 0 && response.data) {
        await this.persistSession(response.data.token, response.data.user);
        onSuccess();
      } else {
        this.errorMessage = response.msg || "登录失败";
      }
    } catch (error) {
      const err: Error = error as Error;
      this.errorMessage = "网络错误: " + (err.message || "未知错误");
    } finally {
      this.isLoading = false;
    }
  }

  goBack(): void {
    if (this.showRegister) {
      this.showRegister = false;
      return;
    }
    this.step = 1;
    this.errorMessage = "";
  }

  // ========== Admin Login ==========

  async login(onSuccess: () => void): Promise<void> {
    if (!this.employeeNo) {
      this.errorMessage = "请输入账号";
      return;
    }
    if (!this.password) {
      this.errorMessage = "请输入密码";
      return;
    }

    this.isLoading = true;
    this.errorMessage = "";

    try {
      const response = await this.apiService.login(
        this.employeeNo,
        this.password,
        this.selectedRole
      );

      if (response.code === 0 && response.data) {
        await this.persistSession(response.data.token, response.data.user);
        onSuccess();
      } else {
        this.errorMessage = response.msg || "登录失败";
      }
    } catch (error) {
      const err: Error = error as Error;
      this.errorMessage = "网络错误: " + (err.message || "未知错误");
    } finally {
      this.isLoading = false;
    }
  }

  // ========== Admin Register ==========

  showRegisterForm(): void {
    this.showRegister = true;
    this.errorMessage = "";
    this.regEmployeeNo = "";
    this.regName = "";
    this.regPassword = "";
  }

  async register(onSuccess: () => void): Promise<void> {
    if (!this.regEmployeeNo) {
      this.errorMessage = "请输入账号";
      return;
    }
    if (!this.regName) {
      this.errorMessage = "请输入姓名";
      return;
    }
    if (!this.regPassword || this.regPassword.length < 4) {
      this.errorMessage = "密码至少4位";
      return;
    }

    this.isLoading = true;
    this.errorMessage = "";

    try {
      const res = await this.apiService.register(
        this.regEmployeeNo,
        this.regName,
        this.regPassword,
        this.regRole
      );

      if (res.code === 0) {
        // After register, auto-login
        const loginRes = await this.apiService.login(
          this.regEmployeeNo,
          this.regPassword,
          this.regRole
        );
        if (loginRes.code === 0 && loginRes.data) {
          await this.persistSession(loginRes.data.token, loginRes.data.user);
          onSuccess();
        } else {
          this.errorMessage = "注册成功，但自动登录失败，请手动登录";
          this.showRegister = false;
        }
      } else {
        this.errorMessage = res.msg || "注册失败";
      }
    } catch (error) {
      const err: Error = error as Error;
      this.errorMessage = "网络错误: " + (err.message || "未知错误");
    } finally {
      this.isLoading = false;
    }
  }

  // ========== Helpers ==========

  private async persistSession(token: string, user: object): Promise<void> {
    await this.session.setToken(token);
    TokenProvider.setToken(token);

    const u: Record<string, string | number> = user as Record<string, string | number>;
    await this.session.setRole(String(u["role"] || ""));
    await this.session.setUserName(String(u["name"] || ""));
    await this.session.setEmployeeNo(String(u["employeeNo"] || ""));
    await this.session.setUserId(String(u["id"] || ""));
  }
}
