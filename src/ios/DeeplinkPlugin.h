#import <Cordova/CDVPlugin.h>

@interface DeeplinkPlugin : CDVPlugin

- (void)getLastDeepLink:(CDVInvokedUrlCommand *)command;
- (void)onDeepLink:(CDVInvokedUrlCommand *)command;
- (void)launchApp:(CDVInvokedUrlCommand *)command;

@end
