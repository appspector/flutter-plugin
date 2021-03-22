//
//  AppSpectorPlugin.m
//  appspector
//
//  Created by Deszip on 10/04/2019.
//

#import "AppSpectorPlugin.h"
#import <AppSpectorSDK/AppSpector.h>

#import "ASPluginEventsHandler.h"

static NSString * const kControlChannelName = @"appspector_plugin";
static NSString * const kEventChannelName   = @"appspector_event_channel";

@interface AppSpectorPlugin ()

@property (strong, nonatomic) ASPluginCallValidator *callValidator;
@property (strong, nonatomic) ASPluginEventsHandler *eventsHandler;
@property (strong, nonatomic) FlutterMethodChannel *controlChannel;

@end

@implementation AppSpectorPlugin

+ (instancetype)rootPluginWithChannel:(FlutterMethodChannel *)controlChannel {
    static AppSpectorPlugin *rootPlugin = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rootPlugin = [[[self class] alloc] initWithCallValidator:[ASPluginCallValidator new]
                                                         channel:controlChannel];
    });
    return rootPlugin;
}

- (instancetype)initWithCallValidator:(ASPluginCallValidator *)validator
                              channel:(FlutterMethodChannel *)controlChannel {
    if (self = [super init]) {
        _callValidator = validator;
        _eventsHandler = [[ASPluginEventsHandler alloc] initWithCallValidator:validator];
        _controlChannel = controlChannel;
    }
    
    return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *controlChannel = [FlutterMethodChannel methodChannelWithName:kControlChannelName binaryMessenger:[registrar messenger]];
    FlutterMethodChannel *eventChannel = [FlutterMethodChannel methodChannelWithName:kEventChannelName binaryMessenger:[registrar messenger]];
    
    AppSpectorPlugin *plugin = [AppSpectorPlugin rootPluginWithChannel:controlChannel];
  
    [registrar addMethodCallDelegate:plugin channel:controlChannel];
    [registrar addMethodCallDelegate:plugin.eventsHandler channel:eventChannel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([self.callValidator controlMethodSupported:call.method]) {
        // Validate arguments
        NSError *validationError = nil;
        if (![self.callValidator argumentsValid:call.arguments
                                           call:call.method       
                                          error:&validationError]) {
            result(validationError.localizedDescription);
            return;
        }
        
        // Handle calls
        if ([call.method isEqualToString:kRunMethodName]) {
            [self handleRunCall:call.arguments result:result];
        }
        if ([call.method isEqualToString:kStopMethodName]) {
            [self handleStopCallWithResult:result];
        }
        if ([call.method isEqualToString:kStartMethodName]) {
            [self handleStartCallWithResult:result];
        }
        if ([call.method isEqualToString:kIsStartedMethodName]) {
            [self handleIsStartedCallWithResult:result];
        }
        if ([call.method isEqualToString:kSetMetadataMethodName]) {
            [self handleSetMetadataCall:call.arguments result:result];
        }
        if ([call.method isEqualToString:kRemoveMetadataMethodName]) {
            [self handleRemoveMetadataCall:call.arguments result:result];
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)handleRunCall:(ASPluginMethodArgumentsList *)arguments result:(FlutterResult)result {
    NSString *apiKey = arguments[@"apiKey"];
    NSSet<ASMonitorID> *monitorIds = [self validateAndMapRawMonitorIds:arguments[@"enabledMonitors"]];
  
    AppSpectorConfig *config = [AppSpectorConfig configWithAPIKey:apiKey monitorIDs:monitorIds];
  
    // Handle special case when private SDK options are transferred via metadata
    if ([arguments[@"metadata"][@"APPSPECTOR_CHECK_STORE_ENVIRONMENT"] isKindOfClass:[NSString class]]) {
        NSString *checkOption = arguments[@"metadata"][@"APPSPECTOR_CHECK_STORE_ENVIRONMENT"];
        [config setValue:[checkOption isEqualToString:@"true"] ? @(YES) : @(NO) forKey:@"disableProductionCheck"];
        
        // Drop flag to not include in metadata
        NSMutableDictionary *mutableArgs = [arguments mutableCopy];
        [[arguments mutableCopy] removeObjectForKey:@"APPSPECTOR_CHECK_STORE_ENVIRONMENT"];
        arguments = [mutableArgs copy];
    }
    
    config.metadata = [self validateAndMapRawMeatdata:arguments[@"metadata"]];
    
    __weak __auto_type weakSelf = self;
    config.startCallback = ^(NSURL * _Nonnull sessionURL) {
        [weakSelf.controlChannel invokeMethod:@"onSessionUrl" arguments:sessionURL.absoluteString];
    };
    
    [AppSpector runWithConfig:config];
  
    result(@"Ok");
}

- (void)handleStopCallWithResult:(FlutterResult)result {
    [AppSpector stop];
    result(@"Ok");
}

- (void)handleStartCallWithResult:(FlutterResult)result {
    [AppSpector start];
    result(@"Ok");
}

- (void)handleIsStartedCallWithResult:(FlutterResult)result {
    BOOL isStarted = [AppSpector isRunning];
    result(@(isStarted));
}

- (void)handleSetMetadataCall:(ASPluginMethodArgumentsList *)arguments result:(FlutterResult)result {
    NSString *key = arguments[@"key"];
    NSString *value = arguments[@"value"];

    if (key != nil && (id)key != NSNull.null && value != nil && (id)value != NSNull.null) {
        ASMetadata *metadata = @{key : value};
        [AppSpector updateMetadata:metadata];
    }

    result(@"Ok");
}

- (void)handleRemoveMetadataCall:(ASPluginMethodArgumentsList *)arguments result:(FlutterResult)result {
    ASMetadata *emptyMetadata = @{};
    [AppSpector updateMetadata:emptyMetadata];
    result(@"Ok");
}

- (ASMetadata *)validateAndMapRawMeatdata:(NSDictionary *)rawMetadata {
  if (rawMetadata == nil || (id)rawMetadata == NSNull.null) {
    return @{};
  }
  
  __block BOOL isValid = YES;
  [rawMetadata enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent
                                       usingBlock:^(id key, id object, BOOL *stop) {
    if (key == NSNull.null || object == NSNull.null) {
      isValid = NO;
    }
  }];
  
  if (isValid) {
    return rawMetadata;
  } else {
    NSString *metadataString = rawMetadata.description;
    NSString *message = @"It looks like AppSpector iOS plugin initialized with invalid metadata: \n %@ \n Please review AppSpectorPlugin initialization code. If the problem persists, please contact us at https://slack.appspector.com/";
    NSLog(message, metadataString);
    return @{};
  }
}

- (NSSet<ASMonitorID> *)validateAndMapRawMonitorIds:(NSArray<NSString *> *)rawMonitorIds {
  NSSet *allMonitors = [NSSet setWithObjects:
                        AS_SCREENSHOT_MONITOR,
                        AS_SQLITE_MONITOR,
                        AS_HTTP_MONITOR,
                        AS_COREDATA_MONITOR,
                        AS_PERFORMANCE_MONITOR,
                        AS_LOG_MONITOR,
                        AS_LOCATION_MONITOR,
                        AS_ENVIRONMENT_MONITOR ,
                        AS_DEFAULTS_MONITOR,
                        AS_NOTIFICATION_MONITOR,
                        AS_ANALYTICS_MONITOR,
                        AS_COMMANDS_MONITOR,
                        AS_FS_MONITOR,
                        nil];
  
  NSMutableSet *selectedMonotirIds = [NSMutableSet new];
  NSMutableSet *invalidMonitorIds = [NSMutableSet new];
  
  for (NSString *monitorId in rawMonitorIds) {
    if ([allMonitors containsObject:monitorId]) {
      [selectedMonotirIds addObject:monitorId];
    } else {
      [invalidMonitorIds addObject:monitorId];
    }
  }
  
  if (invalidMonitorIds.count > 0) {
    NSString *monitors = [[invalidMonitorIds allObjects] componentsJoinedByString:@"\n - "];
    NSString *message = @"It looks like AppSpector iOS plugin initialized with invalid monitors: \n - %@ \n Please review AppSpectorPlugin initialization code. If the problem persists, please contact us at https://slack.appspector.com/";
    NSLog(message, monitors);
  }
  
  return selectedMonotirIds;
}

@end
