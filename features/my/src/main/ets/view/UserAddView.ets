import { UserManageViewModel } from '../viewModel/UserManageViewModel';
import { UserInfo, UserRole } from 'utils';

@ComponentV2
export struct UserAddView {
  @Param viewModel: UserManageViewModel = new UserManageViewModel();
  @Event onBack?: () => void;

  @Local name: string = '';
  @Local employeeNo: string = '';
  @Local role: UserRole = 'operator';

  aboutToAppear(): void {
    this.viewModel.loadUsers();
    this.employeeNo = this.viewModel.generateEmployeeNo();
  }

  private canSubmit(): boolean {
    return this.name.trim().length > 0 && this.employeeNo.trim().length > 0;
  }

  private async submit(): Promise<void> {
    const n = this.name.trim();
    const e = this.employeeNo.trim();
    if (!n) {
      this.getUIContext().getPromptAction().showToast({ message: '请输入姓名' });
      return;
    }
    if (!e) {
      this.getUIContext().getPromptAction().showToast({ message: '请输入账号' });
      return;
    }

    const exists = this.viewModel.users.some((item: UserInfo): boolean => item.employeeNo === e);
    if (exists) {
      this.getUIContext().getPromptAction().showToast({ message: '账号已存在' });
      return;
    }

    const user: UserInfo = {
      id: 0,
      name: n,
      employeeNo: e,
      role: this.role,
      status: '在岗',
      teamId: 1,
      workshopId: 1,
      avatarUrl: ''
    };

    const ok = await this.viewModel.createUser(user);
    if (ok) {
      this.getUIContext().getPromptAction().showToast({ message: '创建成功' });
      setTimeout(() => {
        if (this.onBack) this.onBack();
      }, 300);
      return;
    }
    this.getUIContext().getPromptAction().showToast({ message: this.viewModel.actionMessage || '创建失败' });
  }

  build() {
    Column() {
      Row() {
        Column() {
          Image($r('sys.media.ohos_ic_public_arrow_left'))
            .width('18vp')
            .height('18vp')
            .fillColor('#64748B')
        }
        .width('42vp')
        .height('42vp')
        .backgroundColor('#FFFFFF')
        .borderRadius('21vp')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .shadow({ radius: 8, color: '#12000000', offsetY: 2 })
        .onClick(() => {
          if (this.onBack) this.onBack();
        })

        Column() {
          Text('新增人员')
            .fontSize('22fp')
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827')
          Text('默认密码为 123456')
            .fontSize('13fp')
            .fontColor('#94A3B8')
            .margin({ top: '4vp' })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: '14vp' })
      }
      .width('100%')
      .padding({ left: '14vp', right: '14vp', top: '18vp', bottom: '10vp' })

      Scroll() {
        Column() {
          Text('姓名')
            .fontSize('14fp')
            .fontColor('#334155')
            .width('100%')
          TextInput({ placeholder: '请输入姓名', text: this.name })
            .width('100%')
            .height('44vp')
            .backgroundColor('#FFFFFF')
            .borderRadius('12vp')
            .padding({ left: '12vp', right: '12vp' })
            .margin({ top: '8vp' })
            .onChange((v: string) => {
              this.name = v;
            })

          Text('账号')
            .fontSize('14fp')
            .fontColor('#334155')
            .width('100%')
            .margin({ top: '16vp' })
          TextInput({ placeholder: '请输入账号', text: this.employeeNo })
            .width('100%')
            .height('44vp')
            .backgroundColor('#FFFFFF')
            .borderRadius('12vp')
            .padding({ left: '12vp', right: '12vp' })
            .margin({ top: '8vp' })
            .onChange((v: string) => {
              this.employeeNo = v;
            })

          Text('角色')
            .fontSize('14fp')
            .fontColor('#334155')
            .width('100%')
            .margin({ top: '16vp' })

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(['operator', 'leader', 'inspector', 'admin'] as UserRole[], (r: UserRole) => {
              Text(this.viewModel.getRoleLabel(r))
                .fontSize('13fp')
                .fontColor(this.role === r ? '#FFFFFF' : '#475569')
                .fontWeight(this.role === r ? FontWeight.Medium : FontWeight.Normal)
                .padding({ left: '14vp', right: '14vp', top: '8vp', bottom: '8vp' })
                .backgroundColor(this.role === r ? '#111827' : '#FFFFFF')
                .borderRadius('18vp')
                .border(this.role === r ? { width: 0 } : { width: '1vp', color: '#E2E8F0' })
                .margin({ right: '8vp', bottom: '8vp' })
                .onClick(() => {
                  this.role = r;
                })
            })
          }
          .width('100%')
          .margin({ top: '10vp' })

          Button('提交')
            .width('100%')
            .height('48vp')
            .fontSize('16fp')
            .fontColor('#FFFFFF')
            .backgroundColor(this.canSubmit() ? '#111827' : '#94A3B8')
            .borderRadius('14vp')
            .margin({ top: '22vp' })
            .onClick(() => {
              if (this.canSubmit()) this.submit();
            })
        }
        .width('100%')
        .padding('16vp')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor('#F8FAFC')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFC')
  }
}