//
//  ASPluginEventsHandler.m
//  appspector
//
//  Created by Deszip on 10/04/2019.
//

#import "ASPluginEventsHandler.h"

#import <AppSpectorSDK/AppSpector.h>

@interface ASPluginEventsHandler ()

@property (strong, nonatomic) ASPluginCallValidator *callValidator;

@end

@implementation ASPluginEventsHandler

- (instancetype)initWithCallValidator:(ASPluginCallValidator *)validator {
    if (self = [super init]) {
        _callValidator = validator;
    }
    
    return self;
}

#pragma mark - FlutterPlugin -

+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar { }

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([self.callValidator eventMethodSupported:call.method]) {
        // Validate arguments
        NSError *validationError = nil;
        if (![self.callValidator argumentsValid:call.arguments
                                           call:call.method       
                                          error:&validationError]) {
            result(validationError.localizedDescription);
            return;
        }
        
        // Handle call
        // HTTP monitor
        if ([call.method isEqualToString:kHTTPRequestMethodName]) {
            [self handleHTTPRequestCall:call.arguments result:result];
        }
        
        if ([call.method isEqualToString:kHTTPResponseMethodName]) {
            [self handleHTTPResponseCall:call.arguments result:result];
        }
        
        // Logs monitor
        if ([call.method isEqualToString:kLogEventMethodName]) {
            [self handleLogEventCall:call.arguments result:result];
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - Call handlers -
#pragma mark - HTTP monitor

- (void)handleHTTPRequestCall:(ASPluginMethodArgumentsList *)arguments result:(FlutterResult)result {
    // Build event payload
//    NSData *body = [NSData data];
//    if ([arguments[@"body"] isKindOfClass:[FlutterStandardTypedData class]]) {
//        body = [(FlutterStandardTypedData *)arguments[@"body"] data];
//    }
    NSDictionary *payload = @{ @"uuid"          : arguments[@"uid"],
                               @"url"           : arguments[@"url"],
                               @"method"        : arguments[@"method"],
                               @"body"          : [self unwrapData:arguments[@"body"]],
                               @"hasLargeBody"  : @(NO),
                               @"headers"       : arguments[@"headers"] };
    
    // Send event
    ASExternalEvent *event = [[ASExternalEvent alloc] initWithMonitorID:AS_HTTP_MONITOR eventID:@"http-request" payload:payload];
    [AppSpector sendEvent:event];
    
    result(@"Ok");
}

- (void)handleHTTPResponseCall:(ASPluginMethodArgumentsList *)arguments result:(FlutterResult)result {
    // Build event payload
//    NSData *body = [NSData data];
//    if ([arguments[@"body"] isKindOfClass:[FlutterStandardTypedData class]]) {
//        body = [(FlutterStandardTypedData *)arguments[@"body"] data];
//    }
    NSDictionary *payload = @{ @"uuid"              : arguments[@"uid"],
                               @"statusCode"        : arguments[@"code"],
                               @"body"              : [self unwrapData:arguments[@"body"]],
                               @"hasLargeBody"      : @(NO),
                               @"headers"           : arguments[@"headers"],
                               @"responseDuration"  : arguments[@"tookMs"],
                               @"error"             : @"" };
    
    // Send event
    ASExternalEvent *event = [[ASExternalEvent alloc] initWithMonitorID:AS_HTTP_MONITOR eventID:@"http-response" payload:payload];
    [AppSpector sendEvent:event];
    
    result(@"Ok");
}

#pragma mark - Logs monitor

- (void)handleLogEventCall:(ASPluginMethodArgumentsList *)arguments result:(FlutterResult)result {
    // Build event payload
    NSDictionary *payload = @{ @"level"   : arguments[@"level"],
                               @"message" : arguments[@"message"] };
    
    // Send event
    ASExternalEvent *event = [[ASExternalEvent alloc] initWithMonitorID:AS_LOG_MONITOR eventID:@"log" payload:payload];
    [AppSpector sendEvent:event];
    
    result(@"Ok");
}

#pragma mark - Tools

- (NSData *)unwrapData:(id)flutterData {
    NSData *unwrappedData = [NSData data];
    if ([flutterData isKindOfClass:[FlutterStandardTypedData class]]) {
        unwrappedData = [(FlutterStandardTypedData *)flutterData data];
    }
    
    return unwrappedData;
}

@end
