import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';

const PREF_NAME = 'wo_management_preferences';

export class PreferencesUtils {
  private static instance: PreferencesUtils;
  private prefs: preferences.Preferences | null = null;

  static getInstance(): PreferencesUtils {
    if (!PreferencesUtils.instance) {
      PreferencesUtils.instance = new PreferencesUtils();
    }
    return PreferencesUtils.instance;
  }

  async init(ctx: Context): Promise<void> {
    try {
      this.prefs = await preferences.getPreferences(ctx, PREF_NAME);
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Preferences init failed: ${error.message}`);
    }
  }

  async put(key: string, value: string): Promise<void> {
    if (!this.prefs) return;
    try {
      await this.prefs.put(key, value);
      await this.prefs.flush();
    } catch (err) {
      console.error(`Put ${key} failed`);
    }
  }

  async get(key: string, defaultValue: string = ''): Promise<string> {
    if (!this.prefs) return defaultValue;
    try {
      return await this.prefs.get(key, defaultValue) as string;
    } catch (err) {
      return defaultValue;
    }
  }

  async delete(key: string): Promise<void> {
    if (!this.prefs) return;
    try {
      await this.prefs.delete(key);
      await this.prefs.flush();
    } catch (err) {
      console.error(`Delete ${key} failed`);
    }
  }
}
