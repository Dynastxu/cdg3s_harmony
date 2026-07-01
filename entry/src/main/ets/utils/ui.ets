import { emitter } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { DOMAIN } from '../common/constants/LogConstants';

export function setWindowSystemBarColor(color: string) {
  hilog.debug(DOMAIN.UTILS, 'WinSysBar', `Set win sys bar color to ${color}`)
  emitter.emit('changeStatusBar', {
    data: {
      contentColor: color
    }
  })
}

export function showToast(message: string, uiContest: UIContext) {
  try {
    uiContest.getPromptAction().showToast({ message })
  } catch (error) {
    hilog.error(DOMAIN.UTILS, 'Toast', error)
  }
}