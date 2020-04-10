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
extern ASPluginMethodName * const kStopMethodName;
extern ASPluginMethodName * const kStartMethodName;
extern ASPluginMethodName * const kIsStartedMethodName;
extern ASPluginMethodName * const kSetMetadataMethodName;
extern ASPluginMethodName * const kRemoveMetadataMethodName;
extern ASPluginMethodName * const kHTTPRequestMethodName;
extern ASPluginMethodName * const kHTTPResponseMethodName;
extern ASPluginMethodName * const kLogEventMethodName;

@interface ASPluginCallValidator : NSObject

- (BOOL)controlMethodSupported:(ASPluginMethodName *)methodName;
- (BOOL)eventMethodSupported:(ASPluginMethodName *)methodName;

- (BOOL)argumentsValid:(ASPluginMethodArgumentsList *)arguments
                  call:(ASPluginMethodName *)methodName
          errorMessage:(__autoreleasing NSString *_Nonnull*_Nullable)errorMessage;



@end

NS_ASSUME_NONNULL_END
