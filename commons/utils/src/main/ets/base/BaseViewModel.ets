/**
 * ViewModel base class — unified loading state and error handling
 */
@ObservedV2
export class BaseViewModel {
  @Trace isLoading: boolean = false;
  @Trace errorMessage: string = "";

  setLoading(v: boolean): void { this.isLoading = v; }
  setError(msg: string): void { this.errorMessage = msg; }
  clearError(): void { this.errorMessage = ""; }

  async executeWithLoading<T>(fn: () => Promise<T>, errMsg?: string): Promise<T | undefined> {
    this.isLoading = true;
    this.errorMessage = "";
    try { return await fn(); }
    catch (err) { this.errorMessage = errMsg || "Operation failed"; return undefined; }
    finally { this.isLoading = false; }
  }
}
