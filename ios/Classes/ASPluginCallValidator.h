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

extern ASPluginMethodName * const kRunMethodName;
extern ASPluginMethodName * const kHTTPRequestMethodName;
extern ASPluginMethodName * const kHTTPResponseMethodName;
extern ASPluginMethodName * const kLogEventMethodName;

extern ASPluginMethodArgumentName * const kAPIKeyArgument;

extern ASPluginMethodArgumentName * const kUIDArgument;
extern ASPluginMethodArgumentName * const kURLArgument;
extern ASPluginMethodArgumentName * const kMethodArgument;
extern ASPluginMethodArgumentName * const kBodyArgument;
extern ASPluginMethodArgumentName * const kHeadersArgument;
extern ASPluginMethodArgumentName * const kCodeArgument;
extern ASPluginMethodArgumentName * const kTookMSArgument;
extern ASPluginMethodArgumentName * const kLevelArgument;
extern ASPluginMethodArgumentName * const kTagArgument;
extern ASPluginMethodArgumentName * const kMessageArgument;


@interface ASPluginCallValidator : NSObject

- (BOOL)controlMethodSupported:(ASPluginMethodName *)methodName;
- (BOOL)eventMethodSupported:(ASPluginMethodName *)methodName;

- (BOOL)argumentsValid:(ASPluginMethodArgumentsList *)arguments
                  call:(ASPluginMethodName *)methodName
                 error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
