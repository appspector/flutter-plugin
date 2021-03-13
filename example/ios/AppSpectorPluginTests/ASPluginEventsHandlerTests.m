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

#import "ASPluginEventsHandler.h"
#import <AppSpectorSDK/AppSpector.h>

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
    OCMStub([self.callValidatorMock eventMethodSupported:[OCMArg any]]).andReturn(NO);
    
    FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"foo" arguments:@{}];
    [self.handler handleMethodCall:call result:^(id result) {
        expect(result).toNot.beNil();
        [e fulfill];
    }];
    
    [self waitForExpectations:@[e] timeout:1.1];
}

- (void)testHandlerSendsLogEvent {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    OCMStub([self.callValidatorMock eventMethodSupported:[OCMArg any]]).andReturn(YES);
    OCMStub([self.callValidatorMock argumentsValid:[OCMArg any] call:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);
    
    NSDictionary *payload = @{ @"level" : @"warning",
                               @"message" : @"test" };
    
    id sdkMock = [OCMockObject mockForClass:[AppSpector class]];
    OCMExpect([sdkMock sendEvent:[OCMArg checkWithBlock:^BOOL(ASExternalEvent *event) {
        return [event.monitorID isEqualToString:AS_LOG_MONITOR] &&
                [event.eventID isEqualToString:@"log"] &&
                [event.payload isEqualToDictionary:payload];
    }]]);
    
    FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:kLogEventMethodName arguments:payload];
    [self.handler handleMethodCall:call result:^(id result) {
        expect(result).toNot.beNil();
        [e fulfill];
    }];
    
    OCMVerifyAll(sdkMock);
    
    [self waitForExpectations:@[e] timeout:1.1];
}

@end
