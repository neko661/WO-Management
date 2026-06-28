export class Result<T> { code: number = 0; msg: string = ""; data?: T; static ok<T>(data: T): Result<T> { return {code:0, msg:"success", data}; } }
