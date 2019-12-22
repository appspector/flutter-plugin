//
//  AppSpectorPluginTests.m
//  AppSpectorPluginTests
//
//  Created by Deszip on 12/04/2019.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>

#import <AppSpectorSDK/AppSpector.h>
#import "AppSpectorPlugin.h"

@interface AppSpectorPluginTests : XCTestCase

@property (strong, nonatomic) id validatorMock;
@property (strong, nonatomic) AppSpectorPlugin *plugin;

@end

@implementation AppSpectorPluginTests

- (void)setUp {
    self.validatorMock = OCMClassMock([ASPluginCallValidator class]);
    self.plugin = [[AppSpectorPlugin alloc] initWithCallValidator:self.validatorMock];
}

- (void)tearDown {
    self.validatorMock = nil;
    self.plugin = nil;
}

- (void)testHandlerSupportsRunCall {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    
    FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"run" arguments:@{ @"apiKey" : @"DEADBEEF" }];
    OCMStub([self.validatorMock controlMethodSupported:[OCMArg any]]).andReturn(YES);
    OCMStub([self.validatorMock argumentsValid:call.arguments call:call.method error:[OCMArg anyObjectRef]]).andReturn(YES);

    id sdkMock = OCMClassMock([AppSpector class]);
    OCMExpect(ClassMethod([sdkMock runWithConfig:[OCMArg any]]));
    
    [self.plugin handleMethodCall:call result:^(id result) {
        expect(result).equal(@"Ok");
        OCMVerifyAll(sdkMock);
        [e fulfill];
    }];
    
    [self waitForExpectations:@[e] timeout:0.1];
}

- (void)testHandlerValidatesCallArguments {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    
    FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"run" arguments:@{ @"invalidArg" : @"DEADBEEF" }];
    
    OCMStub([self.validatorMock controlMethodSupported:[OCMArg any]]).andReturn(YES);
    OCMExpect([self.validatorMock argumentsValid:call.arguments call:call.method error:[OCMArg anyObjectRef]]).andReturn(YES);
    
    [self.plugin handleMethodCall:call result:^(id result) {
        OCMVerifyAll(self.validatorMock);
        [e fulfill];
    }];
    
    [self waitForExpectations:@[e] timeout:0.1];
}

- (void)testHandlerDoesntPerformCallWithInvalidArgs {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    
    FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"run" arguments:@{ @"invalidArg" : @"DEADBEEF" }];
    OCMStub([self.validatorMock controlMethodSupported:[OCMArg any]]).andReturn(YES);
    OCMStub([self.validatorMock argumentsValid:call.arguments call:call.method error:[OCMArg anyObjectRef]]).andReturn(NO);
    
    id sdkMock = OCMClassMock([AppSpector class]);
    OCMReject(ClassMethod([sdkMock runWithConfig:[OCMArg any]]));
    
    [self.plugin handleMethodCall:call result:^(id result) {
        OCMVerifyAll(sdkMock);
        [e fulfill];
    }];
    
    [self waitForExpectations:@[e] timeout:0.1];
}

- (void)testHandlerRejectsUnknownCalls {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    
    OCMExpect([self.validatorMock controlMethodSupported:[OCMArg any]]);
    
    FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"foo" arguments:@{}];
    [self.plugin handleMethodCall:call result:^(id result) {
        expect(result).notTo.equal(@"Ok");
        OCMVerifyAll(self.validatorMock);
        [e fulfill];
    }];
    
    [self waitForExpectations:@[e] timeout:0.1];
}

@end
