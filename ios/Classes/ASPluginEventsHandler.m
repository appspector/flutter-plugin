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
        NSString *validationErrorMessage = nil;
        if (![self.callValidator argumentsValid:call.arguments
                                           call:call.method
                                   errorMessage:&validationErrorMessage]) {
            result(validationErrorMessage);
            return;
        }
        
        // Handle call
        if ([call.method isEqualToString:kRequestMethodName]) {
            [self handleRequestCall:call.arguments result:result];
        }
        
        if ([call.method isEqualToString:kResponseMethodName]) {
            [self handleResponseCall:call.arguments result:result];
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - Call handlers -

- (void)handleRequestCall:(ASPluginMethodArgumentsList *)arguments result:(FlutterResult)result {
    // Build event payload
    NSDictionary *payload = @{ @"uuid"          : arguments[@"uid"],
                               @"url"           : arguments[@"url"],
                               @"method"        : arguments[@"method"],
                               @"body"          : [(FlutterStandardTypedData *)arguments[@"body"] data],
                               @"hasLargeBody"  : @(NO),
                               @"headers"       : arguments[@"headers"] };

    NSLog(@"HTTP request payload: %@", payload);
    
    // Send event
    //ASExternalEvent *event = [[ASExternalEvent alloc] initWithMonitorID:AS_HTTP_MONITOR eventID:@"http-request" payload:payload];
    //[AppSpector sendEvent:event];
    
    result(@"Ok");
}

- (void)handleResponseCall:(ASPluginMethodArgumentsList *)arguments result:(FlutterResult)result {
    // Build event payload
    NSDictionary *payload = @{ @"uuid"              : arguments[@"uid"],
                               @"statusCode"        : arguments[@"code"],
                               @"body"              : [(FlutterStandardTypedData *)arguments[@"body"] data],
                               @"hasLargeBody"      : @(NO),
                               @"headers"           : arguments[@"headers"],
                               @"responseDuration"  : arguments[@"tookMs"],
                               @"error"             : @"" };
    
    NSLog(@"HTTP request payload: %@", payload);
    
    // Send event
//    ASExternalEvent *event = [[ASExternalEvent alloc] initWithMonitorID:AS_HTTP_MONITOR eventID:@"http-response" payload:payload];
//    [AppSpector sendEvent:event];
    
    result(@"Ok");
}

@end
