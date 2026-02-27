#import "DeeplinkPlugin.h"

@interface DeeplinkPlugin ()

@property (nonatomic, strong) NSString *lastDeepLinkUrl;
@property (nonatomic, strong) NSString *deepLinkCallbackId;

@end

@implementation DeeplinkPlugin

- (void)pluginInitialize {
    self.lastDeepLinkUrl = nil;
    self.deepLinkCallbackId = nil;

    // Listen for Cordova's open URL notification (custom URL schemes)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleOpenURL:)
                                                 name:CDVPluginHandleOpenURLNotification
                                               object:nil];

    // Listen for Universal Links (continue user activity)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleContinueUserActivity:)
                                                 name:@"CDVPluginHandleOpenURLWithAppSourceAndAnnotationNotification"
                                               object:nil];

    // Check if app was launched with a URL
    NSDictionary *launchOptions = self.commandDelegate.settings;
    NSURL *launchUrl = [launchOptions objectForKey:@"url"];
    if (launchUrl) {
        self.lastDeepLinkUrl = [launchUrl absoluteString];
    }
}

- (void)handleOpenURL:(NSNotification *)notification {
    NSURL *url = notification.object;
    if (url && [url isKindOfClass:[NSURL class]]) {
        self.lastDeepLinkUrl = [url absoluteString];
        [self sendDeepLinkEvent:self.lastDeepLinkUrl];
    }
}

- (void)handleContinueUserActivity:(NSNotification *)notification {
    NSURL *url = notification.object;
    if (url && [url isKindOfClass:[NSURL class]]) {
        self.lastDeepLinkUrl = [url absoluteString];
        [self sendDeepLinkEvent:self.lastDeepLinkUrl];
    }
}

- (void)getLastDeepLink:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult;

    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    if (self.lastDeepLinkUrl) {
        [result setObject:self.lastDeepLinkUrl forKey:@"url"];
    } else {
        [result setObject:[NSNull null] forKey:@"url"];
    }

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)onDeepLink:(CDVInvokedUrlCommand *)command {
    self.deepLinkCallbackId = command.callbackId;

    // If we already have a pending deep link, send it immediately
    if (self.lastDeepLinkUrl) {
        [self sendDeepLinkEvent:self.lastDeepLinkUrl];
    }

    // Keep the callback alive for future events
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)sendDeepLinkEvent:(NSString *)url {
    if (!self.deepLinkCallbackId) return;

    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result setObject:url forKey:@"url"];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.deepLinkCallbackId];
}

- (void)launchApp:(CDVInvokedUrlCommand *)command {
    NSString *urlString = [command argumentAtIndex:0];
    if (!urlString) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"URL is required"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }

    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid URL"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            CDVPluginResult *result;
            if (success) {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            } else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"APP_NOT_FOUND"];
            }
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
