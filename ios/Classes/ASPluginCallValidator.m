//
//  ASPluginCallValidator.m
//  appspector
//
//  Created by Deszip on 10/04/2019.
//

#import "ASPluginCallValidator.h"

@interface ASPluginCallValidator ()

@property (strong, nonatomic) NSArray <ASPluginMethodName *> *controlMethodNames;
@property (strong, nonatomic) NSArray <ASPluginMethodName *> *eventMethodNames;
@property (strong, nonatomic) NSDictionary <ASPluginMethodName *, NSArray <ASPluginMethodArgumentName *> *> *methodParameters;

@end

@implementation ASPluginCallValidator

- (instancetype)init {
    if (self = [super init]) {
        _controlMethodNames = @[kRunMethodName];
        _eventMethodNames = @[kRequestMethodName, kResponseMethodName];
        _methodParameters = @{ kRequestMethodName   : @[ @"uid",
                                                         @"url",
                                                         @"method",
                                                         @"body",
                                                         @"headers" ],
                               kResponseMethodName  : @[ @"uid",
                                                         @"code",
                                                         @"body",
                                                         @"headers",
                                                         @"tookMs" ],
                               kRunMethodName       : @[@"apiKey"] };
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

- (BOOL)argumentsValid:(ASPluginMethodArgumentsList *)arguments call:(ASPluginMethodName *)methodName errorMessage:(__autoreleasing NSString **)errorMessage {
    __block BOOL isValid = YES;
    
    [self.methodParameters[methodName] enumerateObjectsUsingBlock:^(ASPluginMethodArgumentName *argName, NSUInteger idx, BOOL *stop) {
        if (![arguments.allKeys containsObject:argName]) {
            isValid = NO;
            *errorMessage = [self errorMessageForMissingArgument:argName inCall:methodName];
        }
    }];
    
    return isValid;
}

#pragma mark - Private API -

- (NSString *)errorMessageForMissingArgument:(ASPluginMethodArgumentName *)argName inCall:(ASPluginMethodName *)methodName {
    return [NSString stringWithFormat:@"%@ call: '%@' argument is missing", methodName, argName];
}

@end
