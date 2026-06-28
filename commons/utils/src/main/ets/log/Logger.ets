import { hilog } from "@kit.PerformanceAnalysisKit";
const DOMAIN = 0x0001;
export class Logger {
  static debug(msg: string): void { hilog.debug(DOMAIN, "WO_MGR", "%{public}s", msg); }
  static info(msg: string): void { hilog.info(DOMAIN, "WO_MGR", "%{public}s", msg); }
  static error(msg: string): void { hilog.error(DOMAIN, "WO_MGR", "%{public}s", msg); }
}
