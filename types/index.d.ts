export interface IDeepLinkResult {
    url: string | null;
}

export default class DeeplinkPlugin {
    getLastDeepLink(): Promise<IDeepLinkResult>;
    onDeepLink(callback: (result: IDeepLinkResult) => void): void;
}
