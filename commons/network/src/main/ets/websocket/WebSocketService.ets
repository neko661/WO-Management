import { webSocket } from '@kit.NetworkKit';
import { TokenProvider } from '../auth/TokenProvider';
import { LogInterceptor } from '../interceptors/LogInterceptor';

/**
 * WebSocket message from server.
 */
export interface WsMessage {
  type: string;
  topic: string;
  data: object;
  timestamp: string;
}

/**
 * Subscription callback type.
 */
export type WsCallback = (msg: WsMessage) => void;

// Default WebSocket URL — can be changed via setUrl()
const DEFAULT_WS_URL: string = "ws://10.0.2.2:3001";

/**
 * WebSocketService — singleton managing a single WebSocket connection.
 *
 * Topic design (matching backend):
 *   /topic/lines/{lineId}     — line status updates
 *   /topic/workorders/{id}    — work order changes
 *   /user/queue/todos         — personal notifications
 */
export class WebSocketService {
  private static instance: WebSocketService;
  private ws: webSocket.WebSocket | null = null;
  private connected: boolean = false;
  private userId: string = '';
  private wsUrl: string = DEFAULT_WS_URL;
  private subscriptions: Map<string, WsCallback[]> = new Map();
  private reconnectTimer: number | null = null;
  private reconnectAttempts: number = 0;
  private maxReconnectAttempts: number = 5;
  private reconnectDelay: number = 3000;

  static getInstance(): WebSocketService {
    if (!WebSocketService.instance) {
      WebSocketService.instance = new WebSocketService();
    }
    return WebSocketService.instance;
  }

  /**
   * Set the WebSocket server URL.
   */
  setUrl(url: string): void {
    this.wsUrl = url;
  }

  /**
   * Connect to the WebSocket server.
   * @param userId - user's employeeNo for identification
   */
  async connect(userId?: string): Promise<boolean> {
    if (this.connected && this.ws) {
      LogInterceptor.log('[WS] Already connected');
      return true;
    }

    this.userId = userId || 'anonymous';

    return new Promise<boolean>((resolve: Function) => {
      try {
        const url: string = `${this.wsUrl}?userId=${this.userId}`;
        LogInterceptor.log(`[WS] Connecting to ${url}`);

        this.ws = webSocket.createWebSocket();

        this.ws.on('open', (err: object, value: object) => {
          if (err) {
            LogInterceptor.log(`[WS] Connect error`);
            this.connected = false;
            resolve(false);
            return;
          }
          this.connected = true;
          this.reconnectAttempts = 0;
          LogInterceptor.log('[WS] Connected successfully');

          // Re-subscribe all existing subscriptions
          const topics: string[] = [];
          const keys: string[] = Object.keys(this.subscriptions);
          for (let i: number = 0; i < keys.length; i++) {
            topics.push(keys[i]);
          }
          for (let i: number = 0; i < topics.length; i++) {
            this._sendSubscribe(topics[i]);
          }

          resolve(true);
        });

        this.ws.on('message', (err: object, value: string | ArrayBuffer) => {
          if (err) {
            LogInterceptor.log(`[WS] Message error`);
            return;
          }
          try {
            const msg: WsMessage = JSON.parse(value as string) as WsMessage;
            this._dispatch(msg);
          } catch (e) {
            LogInterceptor.log(`[WS] Failed to parse message`);
          }
        });

        this.ws.on('close', (err: object, value: object) => {
          this.connected = false;
          LogInterceptor.log(`[WS] Connection closed`);
          this._tryReconnect();
        });

        this.ws.on('error', (err: object) => {
          LogInterceptor.log(`[WS] Error occurred`);
          this.connected = false;
        });

        this.ws.connect(url, (err: object, value: boolean) => {
          if (err) {
            LogInterceptor.log(`[WS] Connect failed`);
            this.connected = false;
            resolve(false);
          }
        });
      } catch (e) {
        LogInterceptor.log(`[WS] Exception`);
        this.connected = false;
        resolve(false);
      }
    });
  }

  /**
   * Subscribe to a topic.
   */
  subscribe(topic: string, callback: WsCallback): void {
    let subs: WsCallback[] | undefined = this.subscriptions.get(topic);
    if (!subs) {
      subs = [];
      this.subscriptions.set(topic, subs);
    }
    subs.push(callback);

    if (this.connected && this.ws) {
      this._sendSubscribe(topic);
    }
  }

  /**
   * Unsubscribe from a topic.
   */
  unsubscribe(topic: string, callback?: WsCallback): void {
    if (callback) {
      const subs: WsCallback[] | undefined = this.subscriptions.get(topic);
      if (subs) {
        const filtered: WsCallback[] = [];
        for (let i: number = 0; i < subs.length; i++) {
          if (subs[i] !== callback) {
            filtered.push(subs[i]);
          }
        }
        if (filtered.length === 0) {
          this.subscriptions.delete(topic);
        } else {
          this.subscriptions.set(topic, filtered);
        }
      }
    } else {
      this.subscriptions.delete(topic);
    }

    if (this.connected && this.ws) {
      this._sendUnsubscribe(topic);
    }
  }

  /**
   * Disconnect WebSocket.
   */
  disconnect(): void {
    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer);
      this.reconnectTimer = null;
    }

    this.subscriptions.clear();

    if (this.ws) {
      try {
        this.ws.close();
      } catch (_) { /* ignore */ }
      this.ws = null;
    }
    this.connected = false;
    LogInterceptor.log('[WS] Disconnected');
  }

  isConnected(): boolean {
    return this.connected;
  }

  // ---- Private helpers ----

  private _sendSubscribe(topic: string): void {
    if (!this.ws || !this.connected) return;
    try {
      const msg: string = JSON.stringify({ type: 'subscribe', topic: topic });
      this.ws.send(msg, (err: object, value: boolean) => {
        if (err) LogInterceptor.log(`[WS] Subscribe failed for ${topic}`);
      });
    } catch (_) { /* ignore */ }
  }

  private _sendUnsubscribe(topic: string): void {
    if (!this.ws || !this.connected) return;
    try {
      const msg: string = JSON.stringify({ type: 'unsubscribe', topic: topic });
      this.ws.send(msg, (err: object, value: boolean) => {
        if (err) LogInterceptor.log(`[WS] Unsubscribe failed for ${topic}`);
      });
    } catch (_) { /* ignore */ }
  }

  private _dispatch(msg: WsMessage): void {
    const topic: string = msg.topic;
    // Notify specific topic subscribers
    const subs: WsCallback[] | undefined = this.subscriptions.get(topic);
    if (subs) {
      for (let i: number = 0; i < subs.length; i++) {
        try { subs[i](msg); } catch (_) { /* ignore */ }
      }
    }
    // Notify wildcard subscribers
    const wildcard: WsCallback[] | undefined = this.subscriptions.get('/topic/*');
    if (wildcard && topic !== '/topic/*') {
      for (let i: number = 0; i < wildcard.length; i++) {
        try { wildcard[i](msg); } catch (_) { /* ignore */ }
      }
    }
  }

  private _tryReconnect(): void {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      LogInterceptor.log('[WS] Max reconnect attempts reached');
      return;
    }
    this.reconnectAttempts++;
    LogInterceptor.log(`[WS] Reconnecting in ${this.reconnectDelay}ms (attempt ${this.reconnectAttempts})`);
    this.reconnectTimer = setTimeout(() => {
      this.connect(this.userId);
    }, this.reconnectDelay);
  }
}
