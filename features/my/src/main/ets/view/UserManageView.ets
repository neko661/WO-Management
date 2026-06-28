import { UserManageViewModel } from '../viewModel/UserManageViewModel';
import { UserInfo } from 'utils';
import { SessionManager } from 'datastore';

class RoleOption {
  value: string = '';
  label: string = '';
}

@ComponentV2
export struct UserManageView {
  @Param viewModel: UserManageViewModel = new UserManageViewModel();
  @Param currentUserId: number = 0;
  @Param currentRole: string = '';
  @Event onBack?: () => void;
  @Event onAdd?: () => void;
  @Event onEdit?: (userId: number) => void;

  @Local selectedRole: string = '';
  @Local keyword: string = '';

  aboutToAppear(): void {
    this.viewModel.loadUsers();
  }

  private roles(): Array<RoleOption> {
    return [
      { value: '', label: '全部' },
      { value: 'admin', label: '管理员' },
      { value: 'leader', label: '班组长' },
      { value: 'operator', label: '操作员' },
      { value: 'inspector', label: '质检员' }
    ];
  }

  private filteredUsers(): UserInfo[] {
    let list = this.viewModel.users;
    if (this.selectedRole) {
      list = list.filter((u: UserInfo): boolean => u.role === this.selectedRole);
    }
    const k = this.keyword.trim().toLowerCase();
    if (k) {
      list = list.filter((u: UserInfo): boolean => {
        const name = (u.name || '').toLowerCase();
        const employeeNo = (u.employeeNo || '').toLowerCase();
        return name.includes(k) || employeeNo.includes(k);
      });
    }
    return list;
  }

  private currentViewRoleLabel(): string {
    if (this.currentRole === 'admin') return '管理员';
    if (this.currentRole === 'leader') return '班组长';
    if (this.currentRole === 'operator') return '操作员';
    if (this.currentRole === 'inspector') return '质检员';
    return '游客';
  }

  private roleDescription(): string {
    if (this.currentRole === 'admin') return '管理员视角:可查看全产线所有人员信息';
    if (this.currentRole === 'leader') return '班组长视角:查看本班组相关人员';
    if (this.currentRole === 'operator') return '操作员视角:查看与自身相关的人员信息';
    if (this.currentRole === 'inspector') return '质检员视角:查看质检相关人员信息';
    return '演示功能:切换角色查看不同权限';
  }

  private teamDescription(user: UserInfo): string {
    if (user.role === 'admin') return '全产线管理权限';
    if (user.role === 'leader') return '柔性组装线班组';
    if (user.role === 'operator') return '柔性组装线班组';
    if (user.role === 'inspector') return '质量检验组';
    return '默认组织';
  }

  private confirmDelete(user: UserInfo): void {
    AlertDialog.show({
      title: '删除人员',
      message: `确定删除 ${user.name} 吗?`,
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#DC2626',
        action: async () => {
          const ok = await this.viewModel.deleteUser(user.id || 0);
          if (ok) {
            this.getUIContext().getPromptAction().showToast({ message: '已删除' });
          } else {
            this.getUIContext().getPromptAction().showToast({ message: this.viewModel.actionMessage || '删除失败' });
          }
        }
      }
    });
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
          Text('人员管理')
            .fontSize('22fp')
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827')
          Text('增删改查全产线人员信息与角色')
            .fontSize('13fp')
            .fontColor('#94A3B8')
            .margin({ top: '4vp' })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: '14vp' })

        Button('新增')
          .height('36vp')
          .fontSize('14fp')
          .fontColor('#FFFFFF')
          .backgroundColor('#111827')
          .borderRadius('10vp')
          .onClick(() => {
            if (this.onAdd) this.onAdd();
          })
      }
      .width('100%')
      .padding({ left: '14vp', right: '14vp', top: '18vp', bottom: '10vp' })

      Column() {
        Text('当前查看角色')
          .fontSize('13fp')
          .fontColor('#64748B')
          .width('100%')
          .textAlign(TextAlign.Start)

        Text(this.currentViewRoleLabel())
          .fontSize('24fp')
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
          .width('100%')
          .textAlign(TextAlign.Start)
          .margin({ top: '8vp' })

        Text(this.roleDescription())
          .fontSize('13fp')
          .fontColor('#94A3B8')
          .width('100%')
          .textAlign(TextAlign.Start)
          .margin({ top: '8vp' })
      }
      .width('100%')
      .padding('20vp')
      .backgroundColor('#FFFFFF')
      .borderRadius('24vp')
      .shadow({ radius: 16, color: '#12000000', offsetY: 4 })
      .margin({ left: '12vp', right: '12vp', top: '6vp' })

      Row() {
        Text('人员列表')
          .fontSize('18fp')
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
        Blank()
        Text(`共 ${this.filteredUsers().length} 人`)
          .fontSize('13fp')
          .fontColor('#64748B')
      }
      .width('100%')
      .padding({ left: '16vp', right: '16vp', top: '20vp', bottom: '4vp' })

      Row() {
        TextInput({ placeholder: '搜索姓名/工号/账号', text: this.keyword })
          .layoutWeight(1)
          .height('40vp')
          .backgroundColor('#FFFFFF')
          .borderRadius('12vp')
          .padding({ left: '12vp', right: '12vp' })
          .onChange((v: string) => {
            this.keyword = v;
          })
      }
      .width('100%')
      .padding({ left: '14vp', right: '14vp', top: '6vp', bottom: '10vp' })

      Scroll() {
        Column() {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.roles(), (r: RoleOption) => {
              Text(r.label)
                .fontSize('13fp')
                .fontColor(this.selectedRole === r.value ? '#FFFFFF' : '#475569')
                .fontWeight(this.selectedRole === r.value ? FontWeight.Medium : FontWeight.Normal)
                .padding({ left: '14vp', right: '14vp', top: '8vp', bottom: '8vp' })
                .backgroundColor(this.selectedRole === r.value ? '#111827' : '#FFFFFF')
                .borderRadius('18vp')
                .border(this.selectedRole === r.value ? { width: 0 } : { width: '1vp', color: '#E2E8F0' })
                .margin({ right: '8vp', bottom: '8vp' })
                .onClick(() => {
                  this.selectedRole = r.value;
                })
            })
          }
          .width('100%')
          .padding({ left: '12vp', right: '12vp', top: '4vp' })

          if (this.viewModel.isLoading) {
            LoadingProgress().width('32vp').height('32vp').margin({ top: '40vp' })
          } else {
            ForEach(this.filteredUsers(), (u: UserInfo) => {
              Row() {
                Column() {
                  Text((u.name || '').substring(0, 1) || 'U')
                    .fontSize('18fp')
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                }
                .width('48vp')
                .height('48vp')
                .borderRadius('24vp')
                .backgroundColor('#111827')
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)

                Column() {
                  Text(u.name)
                    .fontSize('16fp')
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#111827')
                  Text(this.viewModel.getRoleLabel(u.role))
                    .fontSize('12fp')
                    .fontColor('#0F766E')
                    .margin({ top: '6vp' })
                  Text(`工号: ${u.employeeNo || ''} / ${this.teamDescription(u)}`)
                    .fontSize('12fp')
                    .fontColor('#64748B')
                    .margin({ top: '6vp' })
                  if (u.id === this.currentUserId) {
                    Text('当前登录用户')
                      .fontSize('11fp')
                      .fontColor('#2563EB')
                      .padding({ left: '8vp', right: '8vp', top: '4vp', bottom: '4vp' })
                      .backgroundColor('#DBEAFE')
                      .borderRadius('10vp')
                      .margin({ top: '8vp' })
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .margin({ left: '14vp' })

                Column() {
                  Text('编辑')
                    .fontSize('12fp')
                    .fontColor('#0F766E')
                    .padding({ left: '10vp', right: '10vp', top: '6vp', bottom: '6vp' })
                    .backgroundColor('#ECFDF5')
                    .borderRadius('10vp')
                    .onClick(() => {
                      if (this.onEdit) this.onEdit(u.id || 0);
                    })

                  Text('删除')
                    .fontSize('12fp')
                    .fontColor('#DC2626')
                    .padding({ left: '10vp', right: '10vp', top: '6vp', bottom: '6vp' })
                    .backgroundColor('#FEF2F2')
                    .borderRadius('10vp')
                    .margin({ top: '8vp' })
                    .onClick(() => {
                      this.confirmDelete(u);
                    })
                }
              }
              .width('100%')
              .padding('18vp')
              .backgroundColor('#FFFFFF')
              .borderRadius('20vp')
              .shadow({ radius: 16, color: '#12000000', offsetY: 4 })
              .margin({ left: '12vp', right: '12vp', top: '12vp' })
            })
          }

          Column() {
            Text('角色权限说明')
              .fontSize('16fp')
              .fontWeight(FontWeight.Bold)
              .fontColor('#111827')
              .width('100%')
              .textAlign(TextAlign.Start)
            Text('管理员:查看全产线所有人员,拥有最高权限')
              .fontSize('13fp')
              .fontColor('#64748B')
              .width('100%')
              .margin({ top: '10vp' })
          }
          .width('100%')
          .padding('20vp')
          .backgroundColor('#FFFFFF')
          .borderRadius('24vp')
          .shadow({ radius: 16, color: '#12000000', offsetY: 4 })
          .margin({ left: '12vp', right: '12vp', top: '16vp' })

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
}