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

#pragma mark - Invalid calls -

- (void)testHandlerReturnsErrorForInvalidCallName {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    OCMStub([self.callValidatorMock eventMethodSupported:[OCMArg any]]).andReturn(NO);
    
    FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"foo" arguments:@{}];
    [self.handler handleMethodCall:call result:^(id result) {
        expect(result).to.equal(FlutterMethodNotImplemented);
        [e fulfill];
    }];
    
    [self waitForExpectations:@[e] timeout:1.1];
}

- (void)testHandlerReturnsErrorForInvalidCallArgs {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    
    OCMStub([self.callValidatorMock eventMethodSupported:[OCMArg any]]).andReturn(YES);
    
    NSString *errorDescription = @"foo_error";
    NSError *error = OCMClassMock([NSError class]);
    OCMStub([error localizedDescription]).andReturn(errorDescription);
    OCMStub([self.callValidatorMock argumentsValid:[OCMArg any] call:[OCMArg any] error:[OCMArg setTo:error]]).andReturn(NO);
    
    FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"foo" arguments:@{}];
    [self.handler handleMethodCall:call result:^(id result) {
        expect(result).to.equal(errorDescription);
        [e fulfill];
    }];
    
    [self waitForExpectations:@[e] timeout:1.1];
}


- (void)testHandlerSendsLogEvent {
    NSDictionary *payload = @{ @"level" : @"warning",
                               @"message" : @"test" };
    FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:kLogEventMethodName arguments:payload];
    ASExternalEvent *expectedEvent = [[ASExternalEvent alloc] initWithMonitorID:AS_LOG_MONITOR eventID:@"log" payload:payload];
    
    [self performCall:call andValidateEvent:expectedEvent];
}

- (void)testHandlerSendsHTTPRequestEvent {
    NSData *rawData = [@"DESDBEEF" dataUsingEncoding:NSUTF8StringEncoding];
    FlutterStandardTypedData *flutterData = [FlutterStandardTypedData typedDataWithBytes:rawData];
    NSString *UUID = [NSUUID UUID].UUIDString;
    
    NSDictionary *args = @{ @"uid"          : UUID,
                            @"url"           : @"http://google.com",
                            @"method"        : @"GET",
                            @"body"          : flutterData,
                            @"headers"       : @{} };
    
    NSDictionary *payload = @{ @"uuid"          : UUID,
                               @"url"           : @"http://google.com",
                               @"method"        : @"GET",
                               @"body"          : rawData,
                               @"hasLargeBody"  : @(NO),
                               @"headers"       : @{} };
    FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:kHTTPRequestMethodName arguments:args];
    ASExternalEvent *expectedEvent = [[ASExternalEvent alloc] initWithMonitorID:AS_HTTP_MONITOR eventID:@"http-request" payload:payload];
    
    [self performCall:call andValidateEvent:expectedEvent];
}

/// If handler gets event with invalid body it sould substitute it with emty data
- (void)testHandlerSendsHTTPRequestEventWithoutBody {
    NSString *UUID = [NSUUID UUID].UUIDString;
    NSDictionary *args = @{ @"uid"          : UUID,
                            @"url"           : @"http://google.com",
                            @"method"        : @"GET",
                            @"body"          : [NSObject new],
                            @"headers"       : @{} };
    
    NSDictionary *payload = @{ @"uuid"          : UUID,
                               @"url"           : @"http://google.com",
                               @"method"        : @"GET",
                               @"body"          : [NSData data],
                               @"hasLargeBody"  : @(NO),
                               @"headers"       : @{} };
    FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:kHTTPRequestMethodName arguments:args];
    ASExternalEvent *expectedEvent = [[ASExternalEvent alloc] initWithMonitorID:AS_HTTP_MONITOR eventID:@"http-request" payload:payload];
    
    [self performCall:call andValidateEvent:expectedEvent];
}

- (void)testHandlerSendsHTTPResponseEvent {
    NSData *rawData = [@"DESDBEEF" dataUsingEncoding:NSUTF8StringEncoding];
    FlutterStandardTypedData *flutterData = [FlutterStandardTypedData typedDataWithBytes:rawData];
    NSString *UUID = [NSUUID UUID].UUIDString;
    
    NSDictionary *args = @{ @"uid"          : UUID,
                            @"code"         : @(200),
                            @"body"         : flutterData,
                            @"headers"      : @{},
                            @"tookMs"       : @(100) };
    
    NSDictionary *payload = @{ @"uuid"              : UUID,
                               @"statusCode"        : @(200),
                               @"body"              : rawData,
                               @"hasLargeBody"      : @(NO),
                               @"headers"           : @{},
                               @"responseDuration"  : @(100),
                               @"error"             : @"" };
    FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:kHTTPResponseMethodName arguments:args];
    ASExternalEvent *expectedEvent = [[ASExternalEvent alloc] initWithMonitorID:AS_HTTP_MONITOR eventID:@"http-response" payload:payload];
    
    [self performCall:call andValidateEvent:expectedEvent];
}

/// If handler gets event with invalid body it sould substitute it with emty data
- (void)testHandlerSendsHTTPResponseEventWithoutBody {
    NSString *UUID = [NSUUID UUID].UUIDString;
    NSDictionary *args = @{ @"uid"          : UUID,
                            @"code"         : @(200),
                            @"body"         : [NSObject new],
                            @"headers"      : @{},
                            @"tookMs"       : @(100) };
    
    NSDictionary *payload = @{ @"uuid"              : UUID,
                               @"statusCode"        : @(200),
                               @"body"              : [NSData data],
                               @"hasLargeBody"      : @(NO),
                               @"headers"           : @{},
                               @"responseDuration"  : @(100),
                               @"error"             : @"" };
    FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:kHTTPResponseMethodName arguments:args];
    ASExternalEvent *expectedEvent = [[ASExternalEvent alloc] initWithMonitorID:AS_HTTP_MONITOR eventID:@"http-response" payload:payload];
    
    [self performCall:call andValidateEvent:expectedEvent];
}


#pragma mark - Event sender

- (void)performCall:(FlutterMethodCall *)call andValidateEvent:(ASExternalEvent *)expectedEvent {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    
    OCMStub([self.callValidatorMock eventMethodSupported:[OCMArg any]]).andReturn(YES);
    OCMStub([self.callValidatorMock argumentsValid:[OCMArg any] call:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);
    
    id sdkMock = [OCMockObject mockForClass:[AppSpector class]];
    OCMExpect([sdkMock sendEvent:[OCMArg checkWithBlock:^BOOL(ASExternalEvent *event) {
        expect(event.monitorID).to.equal(expectedEvent.monitorID);
        expect(event.eventID).to.equal(expectedEvent.eventID);
        expect(event.payload).to.equal(expectedEvent.payload);
        return YES;
    }]]);
    
    [self.handler handleMethodCall:call result:^(id result) {
        expect(result).toNot.beNil();
        OCMVerifyAll(sdkMock);
        [e fulfill];
    }];
    
    [self waitForExpectations:@[e] timeout:1.1];
}

@end
