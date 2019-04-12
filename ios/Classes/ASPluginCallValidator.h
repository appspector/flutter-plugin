//
//  ASPluginCallValidator.h
//  appspector
//
//  Created by Deszip on 10/04/2019.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString ASPluginMethodName;
typedef NSString ASPluginMethodArgumentName;
typedef NSDictionary <ASPluginMethodArgumentName *, id> ASPluginMethodArgumentsList;

static ASPluginMethodName * const kRunMethodName        = @"run";
static ASPluginMethodName * const kRequestMethodName    = @"http-request";
static ASPluginMethodName * const kResponseMethodName   = @"http-response";

@interface ASPluginCallValidator : NSObject

- (BOOL)controlMethodSupported:(ASPluginMethodName *)methodName;
- (BOOL)eventMethodSupported:(ASPluginMethodName *)methodName;

- (BOOL)argumentsValid:(ASPluginMethodArgumentsList *)arguments
                  call:(ASPluginMethodName *)methodName
          errorMessage:(__autoreleasing NSString *_Nonnull*)errorMessage;



@end

NS_ASSUME_NONNULL_END
