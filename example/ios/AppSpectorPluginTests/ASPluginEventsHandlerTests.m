//
//  ASPluginEventsHandlerTests.m
//  AppSpectorPluginTests
//
//  Created by Deszip on 24.12.2019.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>

//#import <AppSpectorSDK/AppSpector.h>
#import "ASPluginEventsHandler.h"
//#import <appspector/ASPluginEventsHandler.h>

@interface ASPluginEventsHandlerTests : XCTestCase

@property (strong, nonatomic) id callValidatorMock;
@property (strong, nonatomic) ASPluginEventsHandler *handler;

@end

@implementation ASPluginEventsHandlerTests

- (void)setUp {
    self.callValidatorMock = OCMClassMock([ASPluginCallValidator class]);
    self.handler = [[ASPluginEventsHandler alloc] initWithCallValidator:self.callValidatorMock];
}

- (void)tearDown {
    self.callValidatorMock = nil;
    self.handler = nil;
}

- (void)testHandlerReturnsErrorForInvalidCall {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    OCMStub([self.callValidatorMock eventMethodSupported:[OCMArg any]]).andReturn(YES);
    OCMStub([self.callValidatorMock argumentsValid:[OCMArg any] call:[OCMArg any] errorMessage:[OCMArg checkWithBlock:^BOOL(id errMsgRef) {
        errMsgRef = @""
        return YES;
    }]]);
    
    FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"run" arguments:@{}];
    [self.handler handleMethodCall:call result:^(id result) {
        expect([result isKindOfClass:[NSString class]]).to.beTruthy();
        [e fulfill];
    }];
    
    [self waitForExpectations:@[e] timeout:0.1];
}

@end
