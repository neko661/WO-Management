import { HttpClient } from "./HttpClient";
export class BaseService {
  protected http: HttpClient = HttpClient.getInstance();
}
