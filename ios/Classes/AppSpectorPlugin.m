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
    NSSet *monitorIDs = [NSSet setWithObjects:AS_LOG_MONITOR, AS_SCREENSHOT_MONITOR, AS_SQLITE_MONITOR, AS_LOCATION_MONITOR, AS_ENVIRONMENT_MONITOR, AS_NOTIFICATION_MONITOR, AS_ANALYTICS_MONITOR, nil];
    AppSpectorConfig *config = [AppSpectorConfig configWithAPIKey:apiKey monitorIDs:monitorIDs];

    [AppSpector runWithConfig:config];

    result(@"Ok");
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
