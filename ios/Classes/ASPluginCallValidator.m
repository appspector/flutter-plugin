//
//  ASPluginCallValidator.m
//  appspector
//
//  Created by Deszip on 10/04/2019.
//

#import "ASPluginCallValidator.h"

ASPluginMethodName * const kRunMethodName           = @"run";
ASPluginMethodName * const kHTTPRequestMethodName   = @"http-request";
ASPluginMethodName * const kHTTPResponseMethodName  = @"http-response";
ASPluginMethodName * const kLogEventMethodName      = @"log-event";

ASPluginMethodArgumentName * const kAPIKeyArgument = @"apiKey";

ASPluginMethodArgumentName * const kUIDArgument = @"uid";
ASPluginMethodArgumentName * const kURLArgument = @"url";
ASPluginMethodArgumentName * const kMethodArgument = @"method";
ASPluginMethodArgumentName * const kBodyArgument = @"body";
ASPluginMethodArgumentName * const kHeadersArgument = @"headers";
ASPluginMethodArgumentName * const kCodeArgument = @"code";
ASPluginMethodArgumentName * const kTookMSArgument = @"tookMs";
ASPluginMethodArgumentName * const kLevelArgument = @"level";
ASPluginMethodArgumentName * const kTagArgument = @"tag";
ASPluginMethodArgumentName * const kMessageArgument = @"message";

@interface ASPluginCallValidator ()

@property (strong, nonatomic) NSArray <ASPluginMethodName *> *controlMethodNames;
@property (strong, nonatomic) NSArray <ASPluginMethodName *> *eventMethodNames;
@property (strong, nonatomic) NSDictionary <ASPluginMethodName *, NSArray <ASPluginMethodArgumentName *> *> *methodParameters;

@end

@implementation ASPluginCallValidator

- (instancetype)init {
    if (self = [super init]) {
        _controlMethodNames = @[kRunMethodName];
        _eventMethodNames = @[kHTTPRequestMethodName, kHTTPResponseMethodName, kLogEventMethodName];
        _methodParameters = @{ kHTTPRequestMethodName   : @[ kUIDArgument,
                                                             kURLArgument,
                                                             kMethodArgument,
                                                             kBodyArgument,
                                                             kHeadersArgument ],
                               kHTTPResponseMethodName  : @[ kUIDArgument,
                                                             kCodeArgument,
                                                             kBodyArgument,
                                                             kHeadersArgument,
                                                             kTookMSArgument ],
                               kLogEventMethodName : @[ kLevelArgument,
                                                        kTagArgument,
                                                        kMessageArgument],
                               kRunMethodName       : @[kAPIKeyArgument] };
    }
    
    return self;
}

#pragma mark - Validation API -

- (BOOL)controlMethodSupported:(ASPluginMethodName *)methodName {
    return [self.controlMethodNames containsObject:methodName];
}

- (BOOL)eventMethodSupported:(ASPluginMethodName *)methodName {
    return [self.eventMethodNames containsObject:methodName];
}

- (BOOL)argumentsValid:(ASPluginMethodArgumentsList *)arguments
                  call:(ASPluginMethodName *)methodName
                 error:(NSError **)error {
    __block BOOL isValid = YES;
    __block NSError *strongError = nil;
    [self.methodParameters[methodName] enumerateObjectsUsingBlock:^(ASPluginMethodArgumentName *argName, NSUInteger idx, BOOL *stop) {
        if (![arguments.allKeys containsObject:argName]) {
            isValid = NO;
            strongError = [self errorForMissingArgument:argName inCall:methodName];
            *stop = YES;
        }
    }];

    *error = strongError;

    return isValid;
}

#pragma mark - Private API -

- (NSError *)errorForMissingArgument:(ASPluginMethodArgumentName *)argName inCall:(ASPluginMethodName *)methodName {
    NSString *errorMessage = [NSString stringWithFormat:@"%@ call: '%@' argument is missing", methodName, argName];
    NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:@{ NSLocalizedDescriptionKey : errorMessage }];
    
    return error;
}

@end
