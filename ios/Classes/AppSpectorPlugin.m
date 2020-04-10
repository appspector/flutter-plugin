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
static NSString * const kRequestChannelName = @"appspector_request_channel";

@interface AppSpectorPlugin ()

@property (strong, nonatomic) ASPluginCallValidator *callValidator;
@property (strong, nonatomic) ASPluginEventsHandler *eventsHandler;

@end

@implementation AppSpectorPlugin

+ (instancetype)rootPlugin {
    static AppSpectorPlugin *rootPlugin = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rootPlugin = [[[self class] alloc] initWithCallValidator:[ASPluginCallValidator new]];
    });
    return rootPlugin;
}

- (instancetype)initWithCallValidator:(ASPluginCallValidator *)validator {
    if (self = [super init]) {
        _callValidator = validator;
        _eventsHandler = [[ASPluginEventsHandler alloc] initWithCallValidator:validator];
    }
    
    return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *controlChannel = [FlutterMethodChannel methodChannelWithName:kControlChannelName binaryMessenger:[registrar messenger]];
    FlutterMethodChannel *eventChannel = [FlutterMethodChannel methodChannelWithName:kEventChannelName binaryMessenger:[registrar messenger]];
    
    [registrar addMethodCallDelegate:[AppSpectorPlugin rootPlugin] channel:controlChannel];
    [registrar addMethodCallDelegate:[[AppSpectorPlugin rootPlugin] eventsHandler] channel:eventChannel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([self.callValidator controlMethodSupported:call.method]) {
        // Validate arguments
        NSString *validationErrorMessage = nil;
        if (![self.callValidator argumentsValid:call.arguments
                                           call:call.method
                                   errorMessage:&validationErrorMessage]) {
            result(validationErrorMessage);
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
    NSSet<ASMonitorID> *monitorIds = [NSSet setWithArray:arguments[@"enabledMonitors"]];
    AppSpectorConfig *config = [AppSpectorConfig configWithAPIKey:apiKey monitorIDs:monitorIds];
    config.metadata = arguments[@"metadata"];
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
    ASMetadata *metadata = @{arguments[@"key"] : arguments[@"value"]};
    [AppSpector updateMetadata:metadata];
    result(@"Ok");
}

- (void)handleRemoveMetadataCall:(ASPluginMethodArgumentsList *)arguments result:(FlutterResult)result {
    ASMetadata *emptyMetadata = @{};
    [AppSpector updateMetadata:emptyMetadata];
    result(@"Ok");
}
@end
