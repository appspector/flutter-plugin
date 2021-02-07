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
@property (strong, nonatomic) AppSpectorPlugin *handler;
@property (strong, nonatomic) FlutterMethodChannel *channel;

@end

@implementation AppSpectorPluginTests

- (void)setUp {
    self.validatorMock = OCMClassMock([ASPluginCallValidator class]);
    self.channel = OCMClassMock([FlutterMethodChannel class]);
    self.handler = [[AppSpectorPlugin alloc] initWithCallValidator:self.validatorMock channel:self.channel];
}

- (void)tearDown {
    self.validatorMock = nil;
    self.plugin = nil;
}

- (void)testHandlerSupportsRunCall {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    
    FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"run" arguments:@{ @"apiKey" : @"DEADBEEF",
                                                                                              @"enabledMonitors" : @[],
                                                                                              @"metadata" : @{}
    }];
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

- (void)testHandlerSupportsStopCall {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    
    FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"stop" arguments:@{}];
    OCMStub([self.validatorMock controlMethodSupported:[OCMArg any]]).andReturn(YES);
    OCMStub([self.validatorMock argumentsValid:call.arguments call:call.method errorMessage:[OCMArg anyObjectRef]]).andReturn(YES);

    id sdkMock = OCMClassMock([AppSpector class]);
    OCMExpect(ClassMethod([sdkMock stop]));
    
    [self.handler handleMethodCall:call result:^(id result) {
        expect(result).equal(@"Ok");
        OCMVerifyAll(sdkMock);
        [e fulfill];
    }];
    
    [self waitForExpectations:@[e] timeout:0.1];
}

- (void)testHandlerSupportsIsStartedCall {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    
    FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"isStarted" arguments:@{}];
    OCMStub([self.validatorMock controlMethodSupported:[OCMArg any]]).andReturn(YES);
    OCMStub([self.validatorMock argumentsValid:call.arguments call:call.method errorMessage:[OCMArg anyObjectRef]]).andReturn(YES);

    id sdkMock = OCMClassMock([AppSpector class]);
    OCMStub(ClassMethod([sdkMock isRunning])).andReturn(YES);
    
    [self.handler handleMethodCall:call result:^(id result) {
        expect(result).beTruthy();
        [e fulfill];
    }];
    
    [self waitForExpectations:@[e] timeout:0.1];
}

- (void)testHandlerSupportsSetMetadataCall {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    
    FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"setMetadata" arguments:@{ @"key" : @"userSpecifiedDeviceName",
                                                                                              @"value" : @"device name"
    }];
    OCMStub([self.validatorMock controlMethodSupported:[OCMArg any]]).andReturn(YES);
    OCMStub([self.validatorMock argumentsValid:call.arguments call:call.method errorMessage:[OCMArg anyObjectRef]]).andReturn(YES);

    ASMetadata *expectedMetadata = @{AS_DEVICE_NAME_KEY:@"device name"};
  
    id sdkMock = OCMClassMock([AppSpector class]);
    OCMExpect(ClassMethod([sdkMock updateMetadata: expectedMetadata]));
    
    [self.handler handleMethodCall:call result:^(id result) {
        expect(result).equal(@"Ok");
        OCMVerifyAll(sdkMock);
        [e fulfill];
    }];
    
    [self waitForExpectations:@[e] timeout:0.1];
}

- (void)testHandlerSupportsRemoveMetadataCall {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    
    FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"removeMetadata" arguments:@{ @"key" : @"userSpecifiedDeviceName"
    }];
    OCMStub([self.validatorMock controlMethodSupported:[OCMArg any]]).andReturn(YES);
    OCMStub([self.validatorMock argumentsValid:call.arguments call:call.method errorMessage:[OCMArg anyObjectRef]]).andReturn(YES);

    ASMetadata *expectedMetadata = @{};
  
    id sdkMock = OCMClassMock([AppSpector class]);
    OCMExpect(ClassMethod([sdkMock updateMetadata: expectedMetadata]));
    
    [self.handler handleMethodCall:call result:^(id result) {
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
