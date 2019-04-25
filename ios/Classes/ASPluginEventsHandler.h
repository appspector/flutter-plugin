//
//  ASPluginEventsHandler.h
//  appspector
//
//  Created by Deszip on 10/04/2019.
//

#import <Foundation/Foundation.h>

#import <Flutter/Flutter.h>
#import "ASPluginCallValidator.h"

NS_ASSUME_NONNULL_BEGIN

@interface ASPluginEventsHandler : NSObject <FlutterPlugin>

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithCallValidator:(ASPluginCallValidator *)validator NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
