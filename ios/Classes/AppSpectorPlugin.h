//
//  AppSpectorPlugin.h
//  appspector
//
//  Created by Deszip on 10/04/2019.
//

#import <Flutter/Flutter.h>

#import "ASPluginCallValidator.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppSpectorPlugin : NSObject <FlutterPlugin>

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithCallValidator:(ASPluginCallValidator *)validator
                              channel:(FlutterMethodChannel *)controlChannel NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
