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
        
        // Handle call
        if ([call.method isEqualToString:kRunMethodName]) {
            [self handleRunCall:call.arguments result:result];
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)handleRunCall:(ASPluginMethodArgumentsList *)arguments result:(FlutterResult)result {
    AppSpectorConfig *config = [AppSpectorConfig configWithAPIKey:arguments[@"apiKey"]];
    [AppSpector runWithConfig:config];
    result(@"Ok");
}

@end
