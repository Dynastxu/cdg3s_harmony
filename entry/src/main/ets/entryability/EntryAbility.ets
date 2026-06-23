import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
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
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');

      try {
        let windowClass = windowStage.getMainWindowSync();

        // 注册事件监听，用于接收页面传来的状态栏颜色需求
        emitter.on('changeStatusBar', (data: emitter.EventData) => {
          if (windowClass && data?.data && typeof data.data === 'object') {
            let color = data.data['contentColor'] as string;
            windowClass.setWindowSystemBarProperties({
              statusBarColor: '#00FFFFFF',
              statusBarContentColor: color
            }).catch(() => {
              hilog.error(DOMAIN, 'window', 'Error when setWindowSystemBarProperties')
            });
          }
        });

        // 设置沉浸模式
        windowClass.setWindowLayoutFullScreen(true).catch(() => {
          hilog.error(DOMAIN, 'window', 'Error when setWindowLayoutFullScreen')
        });
      } catch (error) {
        hilog.error(DOMAIN, 'window', 'Error when getMainWindowSync')
      }
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}