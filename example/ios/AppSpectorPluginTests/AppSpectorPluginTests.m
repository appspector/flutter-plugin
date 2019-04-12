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

#import "AppSpectorPlugin.h"

@interface AppSpectorPluginTests : XCTestCase

@property (strong, nonatomic) id validatorMock;
@property (strong, nonatomic) AppSpectorPlugin *handler;

@end

@implementation AppSpectorPluginTests

- (void)setUp {
    self.validatorMock = OCMClassMock([ASPluginCallValidator class]);
    self.handler = [[AppSpectorPlugin alloc] initWithCallValidator:self.validatorMock];
}

- (void)tearDown {
    self.validatorMock = nil;
    self.handler = nil;
}

- (void)testHandlerSupportsRunCall {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    
    OCMStub([self.validatorMock controlMethodSupported:[OCMArg any]]).andReturn(YES);
    OCMStub([self.validatorMock argumentsValid:[OCMArg any] call:[OCMArg any] errorMessage:[OCMArg anyObjectRef]]).andReturn(YES);
    
    FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"run" arguments:@{ @"apiKey" : @"DEADBEEF" }];
    [self.handler handleMethodCall:call result:^(id result) {
        expect(result).equal(@"Ok");
        [e fulfill];
    }];
    
    [self waitForExpectations:@[e] timeout:0.1];
}

@end
