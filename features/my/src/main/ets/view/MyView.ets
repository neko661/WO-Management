import { MyViewModel } from '../viewModel/MyViewModel';

@ComponentV2
export struct MyView {
  @Param viewModel: MyViewModel = new MyViewModel();
  @Event onLogout?: () => void;
  @Event onNavigate?: (target: string) => void;

  aboutToAppear(): void {
    this.viewModel.init();
  }

  build() {
    Column() {
      this.TopBar();

      Scroll() {
        Column() {
          this.ProfileCard();
          this.RoleSpecificShortcuts();
          this.CommonShortcuts();
          this.AccountSection();
          this.ActionSection();

          Blank().height('80vp')
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor('#F8FAFC')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFC')
  }

  @Builder
  TopBar() {
    Row() {
      Column() {
        Text('我的')
          .fontSize('22fp')
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
        Text(this.viewModel.getRoleLabel() + ' · 个人资料与常用入口')
          .fontSize('13fp')
          .fontColor('#94A3B8')
          .margin({ top: '4vp' })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: '14vp' })
    }
    .width('100%')
    .padding({ left: '14vp', right: '14vp', top: '20vp', bottom: '12vp' })
  }

  @Builder
  ProfileCard() {
    Row() {
      Column() {
        Text((this.viewModel.profile.name || '?').substring(0, 1))
          .fontSize('24fp')
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width('64vp')
      .height('64vp')
      .backgroundColor(this.getRoleBgColor())
      .borderRadius('32vp')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Column() {
        Text(this.viewModel.profile.name || '用户')
          .fontSize('20fp')
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
        Text(`${this.viewModel.profile.employeeNo || '-'} · ${this.viewModel.getRoleLabel()}`)
          .fontSize('13fp')
          .fontColor('#64748B')
          .margin({ top: '6vp' })
        Text(this.getRoleDescription())
          .fontSize('12fp')
          .fontColor('#94A3B8')
          .margin({ top: '8vp' })
      }
      .layoutWeight(1)
      .margin({ left: '16vp' })
      .alignItems(HorizontalAlign.Start)

      Text('>')
        .fontSize('22fp')
        .fontColor('#CBD5E1')
    }
    .width('100%')
    .padding('20vp')
    .backgroundColor('#FFFFFF')
    .borderRadius('24vp')
    .shadow({ radius: 16, color: '#12000000', offsetY: 4 })
    .margin({ left: '12vp', right: '12vp', top: '8vp' })
  }

  getRoleBgColor(): string {
    const role: string = this.viewModel.profile.role;
    if (role === 'admin') return '#111827';
    if (role === 'leader') return '#0F766E';
    if (role === 'operator') return '#059669';
    if (role === 'inspector') return '#DC2626';
    return '#111827';
  }

  getRoleDescription(): string {
    const role: string = this.viewModel.profile.role;
    if (role === 'admin') return '负责系统管理、工单统筹与异常处理';
    if (role === 'leader') return '负责班组管理、产线监控与工单调度';
    if (role === 'operator') return '负责工单执行、生产操作与报工';
    if (role === 'inspector') return '负责质量检验、抽检与异常处理';
    return '个人资料与常用入口';
  }

  @Builder
  RoleSpecificShortcuts() {
    Column() {
      Text('角色功能')
        .fontSize('18fp')
        .fontWeight(FontWeight.Bold)
        .fontColor('#111827')
        .width('100%')
        .textAlign(TextAlign.Start)

      if (this.viewModel.profile.role === 'admin') {
        this.AdminShortcuts();
      } else if (this.viewModel.profile.role === 'leader') {
        this.LeaderShortcuts();
      } else if (this.viewModel.profile.role === 'operator') {
        this.OperatorShortcuts();
      } else if (this.viewModel.profile.role === 'inspector') {
        this.InspectorShortcuts();
      }
    }
    .width('100%')
    .padding({ left: '12vp', right: '12vp', top: '20vp' })
  }

  @Builder
  AdminShortcuts() {
    Column() {
      Row() {
        this.ActionCard('创建工单', 'WO', '#EEF2FF', '#4F46E5', 'workorder')
        this.ActionCard('基础数据', 'DB', '#FEF3C7', '#D97706', 'data')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: '14vp' })

      Row() {
        this.ActionCard('用户管理', 'US', '#ECFDF5', '#059669', 'usermanage')
        this.ActionCard('系统设置', 'SET', '#F1F5F9', '#64748B', 'data')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: '12vp' })
    }
    .width('100%')
  }

  @Builder
  LeaderShortcuts() {
    Column() {
      Row() {
        this.ActionCard('工单调度', 'WO', '#EEF2FF', '#4F46E5', 'workorder')
        this.ActionCard('班组管理', 'TM', '#ECFDF5', '#0F766E', 'data')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: '14vp' })

      Row() {
        this.ActionCard('产线监控', 'LC', '#FEF3C7', '#D97706', 'data')
        this.ActionCard('异常处理', 'EX', '#FEE2E2', '#DC2626', 'quality')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: '12vp' })
    }
    .width('100%')
  }

  @Builder
  OperatorShortcuts() {
    Column() {
      Row() {
        this.ActionCard('我的工单', 'WO', '#ECFDF5', '#059669', 'workorder')
        this.ActionCard('工序任务', 'PT', '#EEF2FF', '#4F46E5', 'production')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: '14vp' })

      Row() {
        this.ActionCard('生产数据', 'DT', '#FEF3C7', '#D97706', 'data')
        this.ActionCard('报工记录', 'RG', '#DBEAFE', '#0284C7', 'workorder')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: '12vp' })
    }
    .width('100%')
  }

  @Builder
  InspectorShortcuts() {
    Column() {
      Row() {
        this.ActionCard('质检工单', 'QA', '#FEE2E2', '#DC2626', 'workorder')
        this.ActionCard('抽检记录', 'RC', '#DBEAFE', '#0284C7', 'inspection')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: '14vp' })

      Row() {
        this.ActionCard('质量看板', 'QB', '#ECFDF5', '#059669', 'quality')
        this.ActionCard('异常处理', 'EX', '#FEF3C7', '#D97706', 'quality')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: '12vp' })
    }
    .width('100%')
  }

  @Builder
  ActionCard(label: string, iconText: string, bgColor: string, color: string, navigateTo: string) {
    Column() {
      Column() {
        Text(iconText).fontSize('18fp').fontWeight(FontWeight.Bold).fontColor(color)
      }
      .width('52vp').height('52vp').backgroundColor(bgColor).borderRadius('18vp')
      .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)

      Text(label).fontSize('15fp').fontWeight(FontWeight.Medium).fontColor('#111827').margin({ top: '12vp' })
    }
    .width('48%').height('120vp').backgroundColor('#FFFFFF').borderRadius('24vp')
    .justifyContent(FlexAlign.Start).padding({ left: '12vp', right: '12vp', top: '20vp', bottom: '18vp' })
    .shadow({ radius: 16, color: '#12000000', offsetY: 4 })
    .onClick(() => {
      if (this.onNavigate) {
        this.onNavigate(navigateTo);
      }
    })
  }

  @Builder
  CommonShortcuts() {
    Column() {
      Text('常用功能')
        .fontSize('18fp')
        .fontWeight(FontWeight.Bold)
        .fontColor('#111827')
        .width('100%')
        .textAlign(TextAlign.Start)

      Column() {
        this.MenuItem('个人资料', 'PR', '#EEF2FF', '#4F46E5')
        this.MenuItem('修改密码', 'PW', '#FEF3C7', '#D97706')
        this.MenuItem('消息通知', 'MSG', '#ECFDF5', '#0F766E')
        this.MenuItem('帮助中心', 'HLP', '#F1F5F9', '#64748B')
      }
      .width('100%')
      .margin({ top: '14vp' })
    }
    .width('100%')
    .padding({ left: '12vp', right: '12vp', top: '20vp' })
  }

  @Builder
  MenuItem(label: string, iconText: string, bgColor: string, color: string) {
    Row() {
      Column() {
        Text(iconText).fontSize('16fp').fontWeight(FontWeight.Bold).fontColor(color)
      }
      .width('44vp').height('44vp').backgroundColor(bgColor).borderRadius('14vp')
      .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)

      Text(label).fontSize('16fp').fontWeight(FontWeight.Medium).fontColor('#111827').margin({ left: '14vp' })
      Blank()
      Text('>').fontSize('18fp').fontColor('#CBD5E1')
    }
    .width('100%')
    .height('72vp')
    .backgroundColor('#FFFFFF')
    .borderRadius('20vp')
    .shadow({ radius: 16, color: '#12000000', offsetY: 4 })
    .padding({ left: '16vp', right: '16vp' })
    .margin({ top: '10vp' })
    .onClick(() => {
    })
  }

  @Builder
  AccountSection() {
    Column() {
      Text('账号信息')
        .fontSize('18fp')
        .fontWeight(FontWeight.Bold)
        .fontColor('#111827')
        .width('100%')
        .textAlign(TextAlign.Start)

      this.InfoRow('当前角色', this.viewModel.getRoleLabel())
      this.InfoRow('账号', this.viewModel.profile.employeeNo || '-')
      this.InfoRow('姓名', this.viewModel.profile.name || '-')
      this.InfoRow('版本', this.viewModel.profile.appVersion)
    }
    .width('100%')
    .padding({ left: '12vp', right: '12vp', top: '20vp' })
  }

  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize('14fp')
        .fontColor('#64748B')
      Blank()
      Text(value)
        .fontSize('14fp')
        .fontWeight(FontWeight.Medium)
        .fontColor('#111827')
    }
    .width('100%')
    .padding('20vp')
    .backgroundColor('#FFFFFF')
    .borderRadius('20vp')
    .shadow({ radius: 16, color: '#12000000', offsetY: 4 })
    .margin({ top: '12vp' })
  }

  @Builder
  ActionSection() {
    Column() {
      Text('系统操作')
        .fontSize('18fp')
        .fontWeight(FontWeight.Bold)
        .fontColor('#111827')
        .width('100%')
        .textAlign(TextAlign.Start)

      Row() {
        Text('退出登录')
          .fontSize('16fp')
          .fontWeight(FontWeight.Medium)
          .fontColor('#DC2626')
        Blank()
        Text('>')
          .fontSize('20fp')
          .fontColor('#FCA5A5')
      }
      .width('100%')
      .padding('20vp')
      .backgroundColor('#FFFFFF')
      .borderRadius('20vp')
      .shadow({ radius: 16, color: '#12000000', offsetY: 4 })
      .margin({ top: '14vp' })
      .onClick(async () => {
        await this.viewModel.logout(() => {
          if (this.onLogout) {
            this.onLogout();
          }
        });
      })
    }
    .width('100%')
    .padding({ left: '12vp', right: '12vp', top: '20vp' })
  }
}
