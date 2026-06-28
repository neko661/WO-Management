import { LoginViewModel, DemoAccount } from "../viewModel/LoginViewModel";
import { ThemeConstants } from "uicomponents";

@ComponentV2
export struct LoginView {
  @Param viewModel: LoginViewModel = new LoginViewModel();
  @Event onLoginSuccess?: () => void;
  @Local headerTopPadding: number = 56;

  aboutToAppear(): void {
    const h: number = AppStorage.get('statusBarHeight') as number;
    if (h > 0) this.headerTopPadding = h + 28;
  }

  build() {
    Stack() {
      Column() {
        Column() {
          Text("工业管理平台")
            .fontSize("30fp")
            .fontColor("#FFFFFF")
            .fontWeight(FontWeight.Bold)
            .letterSpacing(3)

          Text("Industrial Management Platform")
            .fontSize("12fp")
            .fontColor("rgba(255,255,255,0.6)")
            .letterSpacing(2)
            .margin({ top: "6vp" })

          Text("柔性组装MES系统")
            .fontSize("15fp")
            .fontColor("rgba(255,255,255,0.85)")
            .margin({ top: "16vp" })
        }
        .width("100%")
        .alignItems(HorizontalAlign.Center)
        .padding({ top: this.headerTopPadding, bottom: "40vp" })
        .linearGradient({
          direction: GradientDirection.Left,
          colors: [["#0EA5E9", 0.0], ["#0284C7", 1.0]]
        })
      }
      .width("100%")
      .height("45%")

      Scroll() {
        Column() {
          Column() {
            if (this.viewModel.step === 1) {
              this.buildRoleStep()
            } else {
              if (this.viewModel.showRegister) {
                this.buildRegisterStep()
              } else {
                this.buildLoginStep()
              }
            }
          }
          .width("100%")
          .backgroundColor("#F0F4F8")
          .borderRadius({ topLeft: "32vp", topRight: "32vp" })
          .padding({ top: "28vp" })
          .margin({ top: "38%" })

          Column() {
            Blank()
            Text("—— 智能制造 · 数字孪生 ——")
              .fontSize("11fp")
              .fontColor("#94A3B8")
              .letterSpacing(3)
              .margin({ bottom: "24vp" })
          }
          .width("100%")
          .height("20%")
          .backgroundColor("#F0F4F8")
        }
        .width("100%")
      }
      .width("100%")
      .height("100%")
      .scrollBar(BarState.Off)
    }
    .width("100%")
    .height("100%")
    .backgroundColor("#F0F4F8")
  }

  @Builder
  buildRoleStep() {
    Column() {
      Text("选择登录角色")
        .fontSize("20fp")
        .fontColor("#1E293B")
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: "6vp" })

      Text("Select your role to continue")
        .fontSize("13fp")
        .fontColor("#64748B")
        .margin({ bottom: "28vp" })

      Grid() {
        ForEach(this.viewModel.roles, (role: string) => {
          GridItem() {
            Column() {
              Column() {
                Text(this.viewModel.getRoleIcon(role))
                  .fontSize("26fp")
                  .fontColor("#FFFFFF")
                  .fontWeight(FontWeight.Bold)
              }
              .width("52vp")
              .height("52vp")
              .borderRadius("16vp")
              .linearGradient({
                direction: GradientDirection.Bottom,
                colors: [[this.viewModel.getRoleColor(role), 0.0], [this.viewModel.getRoleColorLight(role), 1.0]]
              })
              .margin({ bottom: "12vp" })

              Text(this.viewModel.getRoleLabel(role))
                .fontSize("16fp")
                .fontColor("#1E293B")
                .fontWeight(FontWeight.Medium)

              Text(this.viewModel.getRoleDesc(role))
                .fontSize("11fp")
                .fontColor("#64748B")
                .margin({ top: "4vp" })
                .maxLines(2)
                .textAlign(TextAlign.Center)
                .padding({ left: "4vp", right: "4vp" })
            }
            .width("100%")
            .height("100%")
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .padding("18vp")
            .borderRadius("20vp")
            .backgroundColor("#FFFFFF")
            .shadow({ radius: 12, color: "rgba(15, 23, 42, 0.06)", offsetY: 4 })
            .onClick(() => {
              const onOk: () => void = () => {
                if (this.onLoginSuccess) this.onLoginSuccess();
              };
              this.viewModel.selectRole(role, onOk);
            })
          }
        })
      }
      .width("86%")
      .columnsTemplate("1fr 1fr")
      .rowsTemplate("1fr 1fr")
      .columnsGap("14vp")
      .rowsGap("14vp")
      .height("360vp")

      if (this.viewModel.isLoading && this.viewModel.selectedRole !== "admin") {
        Column() {
          LoadingProgress()
            .width("24vp")
            .height("24vp")
            .color("#0EA5E9")
          Text("正在进入...")
            .fontSize("13fp")
            .fontColor("#64748B")
            .margin({ top: "10vp" })
        }
        .margin({ top: "24vp" })
      }
    }
    .width("100%")
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildLoginStep() {
    Column() {
      Row() {
        Text("← 返回")
          .fontSize("14fp")
          .fontColor("#0EA5E9")
          .fontWeight(FontWeight.Medium)
          .onClick(() => { this.viewModel.goBack(); })
        Blank()
        Text(this.viewModel.getRoleLabel(this.viewModel.selectedRole) + "登录")
          .fontSize("15fp")
          .fontColor("#1E293B")
          .fontWeight(FontWeight.Medium)
      }
      .width("84%")
      .margin({ top: "8vp", bottom: "16vp" })

      Column() {
        Column() {
          Text(this.viewModel.getRoleIcon(this.viewModel.selectedRole))
            .fontSize("30fp")
            .fontColor("#FFFFFF")
            .fontWeight(FontWeight.Bold)
        }
        .width("64vp")
        .height("64vp")
        .borderRadius("20vp")
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [[this.viewModel.getRoleColor(this.viewModel.selectedRole), 0.0], [this.viewModel.getRoleColorLight(this.viewModel.selectedRole), 1.0]]
        })
        .margin({ top: "8vp", bottom: "12vp" })

        Text(this.viewModel.getRoleLabel(this.viewModel.selectedRole) + "登录")
          .fontSize("18fp")
          .fontColor("#1E293B")
          .fontWeight(FontWeight.Bold)

        Text("Welcome back, please continue")
          .fontSize("12fp")
          .fontColor("#64748B")
          .margin({ top: "4vp", bottom: "24vp" })

        if (this.viewModel.selectedRole === "leader" || this.viewModel.selectedRole === "operator" || this.viewModel.selectedRole === "inspector") {
          Text("选择账号快速登录")
            .fontSize("13fp")
            .fontColor("#64748B")
            .fontWeight(FontWeight.Medium)
            .width("100%")
            .margin({ bottom: "12vp" })

          Column() {
            if (this.viewModel.selectedRole === "leader") {
              ForEach(this.viewModel.demoLeaderAccounts, (account: DemoAccount) => {
                this.buildAccountItem(account, "班", "#10B981", "#D1FAE5")
              })
            } else if (this.viewModel.selectedRole === "operator") {
              ForEach(this.viewModel.demoOperatorAccounts, (account: DemoAccount) => {
                this.buildAccountItem(account, "操", "#F59E0B", "#FEF3C7")
              })
            } else if (this.viewModel.selectedRole === "inspector") {
              ForEach(this.viewModel.demoInspectorAccounts, (account: DemoAccount) => {
                this.buildAccountItem(account, "检", "#3B82F6", "#DBEAFE")
              })
            }
          }
          .width("100%")
          .margin({ bottom: "20vp" })

          Row() {
            Divider()
              .color("#E2E8F0")
              .strokeWidth(1)
              .layoutWeight(1)
            Text("或手动输入")
              .fontSize("12fp")
              .fontColor("#94A3B8")
              .margin({ left: "12vp", right: "12vp" })
            Divider()
              .color("#E2E8F0")
              .strokeWidth(1)
              .layoutWeight(1)
          }
          .width("100%")
          .margin({ bottom: "20vp" })
        }

        Column() {
          Text("账号")
            .fontSize("13fp")
            .fontColor("#64748B")
            .fontWeight(FontWeight.Medium)
            .width("100%")
            .margin({ bottom: "8vp" })
          TextInput({ text: this.viewModel.employeeNo, placeholder: "请输入账号" })
            .fontSize("15fp")
            .fontColor("#1E293B")
            .placeholderColor("#94A3B8")
            .backgroundColor("#F1F5F9")
            .borderRadius("12vp")
            .height("48vp")
            .width("100%")
            .padding({ left: "14vp", right: "14vp" })
            .onChange((v: string) => { this.viewModel.employeeNo = v; })
        }
        .width("100%")
        .margin({ bottom: "16vp" })

        Column() {
          Text("密码")
            .fontSize("13fp")
            .fontColor("#64748B")
            .fontWeight(FontWeight.Medium)
            .width("100%")
            .margin({ bottom: "8vp" })
          TextInput({ text: this.viewModel.password, placeholder: "请输入密码" })
            .fontSize("15fp")
            .fontColor("#1E293B")
            .placeholderColor("#94A3B8")
            .backgroundColor("#F1F5F9")
            .borderRadius("12vp")
            .height("48vp")
            .width("100%")
            .type(InputType.Password)
            .padding({ left: "14vp", right: "14vp" })
            .onChange((v: string) => { this.viewModel.password = v; })
        }
        .width("100%")

        if (this.viewModel.errorMessage) {
          Text(this.viewModel.errorMessage)
            .fontSize("13fp")
            .fontColor(ThemeConstants.ERROR_COLOR)
            .margin({ top: "14vp" })
            .width("100%")
            .textAlign(TextAlign.Center)
        }

        Button() {
          if (this.viewModel.isLoading) {
            LoadingProgress()
              .width("22vp")
              .height("22vp")
              .color("#FFFFFF")
          } else {
            Text("登 录")
              .fontSize("17fp")
              .fontColor("#FFFFFF")
              .fontWeight(FontWeight.Medium)
              .letterSpacing(6)
          }
        }
        .width("100%")
        .height("50vp")
        .linearGradient({
          direction: GradientDirection.Left,
          colors: [["#0EA5E9", 0.0], ["#0284C7", 1.0]]
        })
        .borderRadius("12vp")
        .enabled(!this.viewModel.isLoading)
        .margin({ top: "24vp" })
        .shadow({ radius: 12, color: "rgba(14, 165, 233, 0.3)", offsetY: 6 })
        .onClick(async () => {
          await this.viewModel.login(() => {
            if (this.onLoginSuccess) {
              this.onLoginSuccess();
            }
          });
        })

        Row() {
          Text("没有账号？")
            .fontSize("12fp")
            .fontColor("#94A3B8")
          Text("注册新账号")
            .fontSize("12fp")
            .fontColor("#0EA5E9")
            .fontWeight(FontWeight.Medium)
            .onClick(() => { this.viewModel.showRegisterForm(); })
        }
        .margin({ top: "16vp" })

        Text("演示密码：123456")
          .fontSize("11fp")
          .fontColor("#CBD5E1")
          .margin({ top: "12vp" })
      }
      .width("84%")
      .alignItems(HorizontalAlign.Center)
      .padding({ top: "12vp", bottom: "32vp", left: "22vp", right: "22vp" })
      .backgroundColor("#FFFFFF")
      .borderRadius("24vp")
      .shadow({ radius: 20, color: "rgba(15, 23, 42, 0.06)", offsetY: 8 })
    }
    .width("100%")
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildAccountItem(account: DemoAccount, icon: string, iconColor: string, iconBg: string) {
    Row() {
      Column() {
        Text(icon)
          .fontSize("16fp")
          .fontColor(iconColor)
          .fontWeight(FontWeight.Bold)
      }
      .width("40vp")
      .height("40vp")
      .borderRadius("12vp")
      .backgroundColor(iconBg)
      .justifyContent(FlexAlign.Center)

      Column() {
        Text(account.name)
          .fontSize("15fp")
          .fontColor("#1E293B")
          .fontWeight(FontWeight.Medium)
        Text("账号: " + account.employeeNo)
          .fontSize("12fp")
          .fontColor("#94A3B8")
          .margin({ top: "2vp" })
      }
      .margin({ left: "12vp" })
      .alignItems(HorizontalAlign.Start)

      Blank()

      Text("登录")
        .fontSize("13fp")
        .fontColor("#FFFFFF")
        .fontWeight(FontWeight.Medium)
        .padding({ left: "16vp", right: "16vp", top: "8vp", bottom: "8vp" })
        .borderRadius("10vp")
        .linearGradient({
          direction: GradientDirection.Left,
          colors: [["#0EA5E9", 0.0], ["#0284C7", 1.0]]
        })
        .enabled(!this.viewModel.isLoading)
        .onClick(async () => {
          await this.viewModel.quickLogin(account.employeeNo, () => {
            if (this.onLoginSuccess) {
              this.onLoginSuccess();
            }
          });
        })
    }
    .width("100%")
    .padding("14vp")
    .borderRadius("14vp")
    .backgroundColor("#F8FAFC")
    .margin({ bottom: "10vp" })
    .border({ width: 1, color: "#E2E8F0" })
  }

  @Builder
  buildRegisterStep() {
    Column() {
      Row() {
        Text("← 返回")
          .fontSize("14fp")
          .fontColor("#0EA5E9")
          .fontWeight(FontWeight.Medium)
          .onClick(() => { this.viewModel.goBack(); })
        Blank()
        Text("注册新账号")
          .fontSize("15fp")
          .fontColor("#1E293B")
          .fontWeight(FontWeight.Medium)
      }
      .width("84%")
      .margin({ top: "8vp", bottom: "16vp" })

      Column() {
        Text("注册账号")
          .fontSize("20fp")
          .fontColor("#1E293B")
          .fontWeight(FontWeight.Bold)
          .margin({ top: "8vp", bottom: "4vp" })

        Text("Create a new account")
          .fontSize("12fp")
          .fontColor("#64748B")
          .margin({ bottom: "24vp" })

        Text("选择角色")
          .fontSize("13fp")
          .fontColor("#64748B")
          .fontWeight(FontWeight.Medium)
          .width("100%")
          .margin({ bottom: "10vp" })

        Row() {
          ForEach(["admin", "leader", "operator", "inspector"], (r: string) => {
            Text(this.viewModel.getRoleLabel(r))
              .fontSize("13fp")
              .fontColor(this.viewModel.regRole === r ? "#FFFFFF" : "#64748B")
              .fontWeight(FontWeight.Medium)
              .padding({ left: "12vp", right: "12vp", top: "8vp", bottom: "8vp" })
              .borderRadius("10vp")
              .backgroundColor(this.viewModel.regRole === r ? "#0EA5E9" : "#F1F5F9")
              .margin({ right: "8vp" })
              .onClick(() => { this.viewModel.regRole = r; })
          })
        }
        .width("100%")
        .margin({ bottom: "20vp" })

        TextInput({ text: this.viewModel.regEmployeeNo, placeholder: "请输入账号" })
          .fontSize("15fp")
          .fontColor("#1E293B")
          .placeholderColor("#94A3B8")
          .backgroundColor("#F1F5F9")
          .borderRadius("12vp")
          .height("48vp")
          .width("100%")
          .padding({ left: "14vp", right: "14vp" })
          .onChange((v: string) => { this.viewModel.regEmployeeNo = v; })
          .margin({ bottom: "14vp" })

        TextInput({ text: this.viewModel.regName, placeholder: "请输入姓名" })
          .fontSize("15fp")
          .fontColor("#1E293B")
          .placeholderColor("#94A3B8")
          .backgroundColor("#F1F5F9")
          .borderRadius("12vp")
          .height("48vp")
          .width("100%")
          .padding({ left: "14vp", right: "14vp" })
          .onChange((v: string) => { this.viewModel.regName = v; })
          .margin({ bottom: "14vp" })

        TextInput({ text: this.viewModel.regPassword, placeholder: "请输入密码（至少4位）" })
          .fontSize("15fp")
          .fontColor("#1E293B")
          .placeholderColor("#94A3B8")
          .backgroundColor("#F1F5F9")
          .borderRadius("12vp")
          .height("48vp")
          .width("100%")
          .type(InputType.Password)
          .padding({ left: "14vp", right: "14vp" })
          .onChange((v: string) => { this.viewModel.regPassword = v; })

        if (this.viewModel.errorMessage) {
          Text(this.viewModel.errorMessage)
            .fontSize("13fp")
            .fontColor(ThemeConstants.ERROR_COLOR)
            .margin({ top: "14vp", bottom: "12vp" })
            .width("100%")
            .textAlign(TextAlign.Center)
        }

        Button() {
          if (this.viewModel.isLoading) {
            LoadingProgress().width("22vp").height("22vp").color("#FFFFFF")
          } else {
            Text("注 册").fontSize("17fp").fontColor("#FFFFFF").fontWeight(FontWeight.Medium).letterSpacing(6)
          }
        }
        .width("100%")
        .height("50vp")
        .linearGradient({
          direction: GradientDirection.Left,
          colors: [["#0EA5E9", 0.0], ["#0284C7", 1.0]]
        })
        .borderRadius("12vp")
        .enabled(!this.viewModel.isLoading)
        .margin({ top: "24vp" })
        .shadow({ radius: 12, color: "rgba(14, 165, 233, 0.3)", offsetY: 6 })
        .onClick(async () => {
          await this.viewModel.register(() => {
            if (this.onLoginSuccess) this.onLoginSuccess();
          });
        })
      }
      .width("84%")
      .alignItems(HorizontalAlign.Center)
      .padding({ top: "12vp", bottom: "32vp", left: "22vp", right: "22vp" })
      .backgroundColor("#FFFFFF")
      .borderRadius("24vp")
      .shadow({ radius: 20, color: "rgba(15, 23, 42, 0.06)", offsetY: 8 })
    }
    .width("100%")
    .alignItems(HorizontalAlign.Center)
  }
}
