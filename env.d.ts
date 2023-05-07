/// <reference types="vite/client" />
declare global {
    interface Window {
      WeixinJSBridge: any;
    }
}

declare const WeixinJSBridge: any