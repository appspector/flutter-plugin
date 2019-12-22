//
//  ASPluginCallValidatorTests.m
//  AppSpectorPluginTests
//
//  Created by Deszip on 22.12.2019.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>

#import <AppSpectorSDK/AppSpector.h>
#import "ASPluginCallValidator.h"


@interface ASPluginCallValidatorTests : XCTestCase

@property (strong, nonatomic) ASPluginCallValidator *validator;

@end

@implementation ASPluginCallValidatorTests

- (void)setUp {
    self.validator = [ASPluginCallValidator new];
}

- (void)tearDown {
    self.validator = nil;
}

- (void)testValidatorChecksControlMethods {
    expect([self.validator controlMethodSupported:kRunMethodName]).to.beTruthy();
    expect([self.validator controlMethodSupported:@"FAKE_METHOD"]).to.beFalsy();
}

- (void)testValidatorChecksEventMethods {
    expect([self.validator eventMethodSupported:kHTTPRequestMethodName]).to.beTruthy();
    expect([self.validator eventMethodSupported:kHTTPResponseMethodName]).to.beTruthy();
    expect([self.validator eventMethodSupported:kLogEventMethodName]).to.beTruthy();
    
    expect([self.validator eventMethodSupported:@"FAKE_METHOD"]).to.beFalsy();
}

- (void)testRunCallParametersValidation {
    [self verifyValidParams:@{ kAPIKeyArgument : @"API_KEY"} forCall:kRunMethodName];
    [self verifyInvalidParams:@{ @"FAKE_ARG" : @"FAKE_VALUE"} forCall:kRunMethodName];
}

- (void)testHTTPRequestCallParametersValidation {
    [self verifyValidParams:@{ kUIDArgument : @"UID",
                               kURLArgument : @"URL",
                               kMethodArgument : @"METHOD",
                               kBodyArgument : @"BODY",
                               kHeadersArgument : @"HEADERS" }
                    forCall:kHTTPRequestMethodName];
    
    [self verifyInvalidParams:@{ @"FAKE_ARG" : @"FAKE_VALUE"} forCall:kHTTPRequestMethodName];
}

- (void)testHTTPResponseCallParametersValidation {
    [self verifyValidParams:@{ kUIDArgument : @"UID",
                               kCodeArgument : @"CODE",
                               kBodyArgument : @"BODY",
                               kHeadersArgument : @"BODY",
                               kTookMSArgument : @"HEADERS" }
                    forCall:kHTTPResponseMethodName];
    
    [self verifyInvalidParams:@{ @"FAKE_ARG" : @"FAKE_VALUE"} forCall:kHTTPResponseMethodName];
}

- (void)testLogCallParametersValidation {
    [self verifyValidParams:@{ kLevelArgument : @"UID",
                               kTagArgument : @"CODE",
                               kMessageArgument : @"BODY" }
                    forCall:kLogEventMethodName];
    
    [self verifyInvalidParams:@{ @"FAKE_ARG" : @"FAKE_VALUE"} forCall:kLogEventMethodName];
}

#pragma mark - Validators -

- (void)verifyValidParams:(ASPluginMethodArgumentsList *)args forCall:(ASPluginMethodName *)methodName {
    NSError *validCallError = nil;
    BOOL success = [self.validator argumentsValid:args call:methodName error:&validCallError];
    expect(success).to.beTruthy();
    expect(validCallError).to.beNil();
}

- (void)verifyInvalidParams:(ASPluginMethodArgumentsList *)args forCall:(ASPluginMethodName *)methodName {
    NSError * __autoreleasing invalidCallError = nil;
    BOOL success = [self.validator argumentsValid:args call:methodName error:&invalidCallError];
    expect(success).to.beFalsy();
    NSError *error = invalidCallError;
    NSString *errorDescription = invalidCallError.localizedDescription;
    expect(error).toNot.beNil();
    expect(errorDescription).toNot.beNil();
}

@end
