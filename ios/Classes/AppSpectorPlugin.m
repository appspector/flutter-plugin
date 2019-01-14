#import "AppSpectorPlugin.h"
#import <AppSpectorSDK/AppSpector.h>

@implementation AppSpectorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"appspector_plugin"
            binaryMessenger:[registrar messenger]];
  AppSpectorPlugin* instance = [[AppSpectorPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"run" isEqualToString:call.method]) {
    NSDictionary *args = (NSDictionary*)call.arguments;
    NSString *apiKey = (NSString*)args[@"apiKey"];

    AppSpectorConfig *config = [AppSpectorConfig configWithAPIKey:apiKey];

    [config setValue:@YES forKey:@"extendedDebug"];
    [config setValue:@YES forKey:@"verbose"];

    [AppSpector runWithConfig:config];

    result(@"Ok");
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
