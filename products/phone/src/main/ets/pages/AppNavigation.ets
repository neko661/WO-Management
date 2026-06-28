import { SessionManager } from 'datastore';
import { LoginViewModel, LoginView } from 'login';
import { HomeTabsView } from './HomeTabsView';
import { TokenProvider } from 'network';

@Entry
@ComponentV2
struct AppNavigation {
  @Local loginViewModel: LoginViewModel = new LoginViewModel();
  @Local isLoggedIn: boolean = false;
  @Local userRole: string = '';
  @Local navPathStack: NavPathStack = new NavPathStack();
  private session: SessionManager = SessionManager.getInstance();

  async aboutToAppear(): Promise<void> {
    await this.session.init(getContext());
    AppStorage.setOrCreate('navPathStack', this.navPathStack);
    const token: string = await this.session.getToken();
    if (token) {
      TokenProvider.setToken(token);
      this.userRole = await this.session.getRole();
      this.isLoggedIn = true;
    }
  }

  build() {
    Navigation(this.navPathStack) {
      if (this.isLoggedIn) {
        HomeTabsView({
          role: this.userRole,
          onLogout: async () => {
            TokenProvider.clearToken();
            await this.session.clear();
            this.isLoggedIn = false;
          }
        })
      } else {
        LoginView({
          viewModel: this.loginViewModel,
          onLoginSuccess: async () => {
            this.userRole = await this.session.getRole();
            this.isLoggedIn = true;
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .hideToolBar(true)
    .mode(NavigationMode.Stack)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
}
