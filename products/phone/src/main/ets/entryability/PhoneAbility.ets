import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

const DOMAIN = 0x0000;

export let STATUS_BAR_HEIGHT: number = 0;

export default class PhoneAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    windowStage.getMainWindow((err: BusinessError, windowClass: window.Window) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to get main window. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      const avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      STATUS_BAR_HEIGHT = px2vp(avoidArea.topRect.height);
      AppStorage.setOrCreate('statusBarHeight', STATUS_BAR_HEIGHT);
      windowClass.setWindowLayoutFullScreen(true);
    });

    windowStage.loadContent('pages/AppNavigation', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void { hilog.info(DOMAIN, 'testTag', 'Ability onWindowStageDestroy'); }
  onForeground(): void { hilog.info(DOMAIN, 'testTag', 'Ability onForeground'); }
  onBackground(): void { hilog.info(DOMAIN, 'testTag', 'Ability onBackground'); }
}
