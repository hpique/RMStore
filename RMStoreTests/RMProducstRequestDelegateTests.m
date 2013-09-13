//
//  RMProducstRequestDelegateTests.m
//  RMStore
//
//  Created by Hermes on 9/10/13.
//  Copyright (c) 2013 Robot Media. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#import "RMStore.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles" // To use ST macros in blocks

typedef void (^RMSKProductsRequestFailureBlock)(NSError *error);
typedef void (^RMSKProductsRequestSuccessBlock)(NSArray *products, NSArray *invalidIdentifiers);

@interface RMProductsRequestDelegate : NSObject<SKProductsRequestDelegate>

@property (nonatomic, strong) RMSKProductsRequestSuccessBlock successBlock;
@property (nonatomic, strong) RMSKProductsRequestFailureBlock failureBlock;
@property (nonatomic, weak) RMStore *store;

@end

@interface RMProducstRequestDelegateTests : SenTestCase

@end

@implementation RMProducstRequestDelegateTests {
    RMProductsRequestDelegate *_object;
}

- (void)setUp
{
    _object = [[RMProductsRequestDelegate alloc] init];
    _object.store = [RMStore defaultStore];
}

- (void)testProductsRequestDidReceiveResponse_Empty
{
    id request = [OCMockObject mockForClass:[SKProductsRequest class]];
    id response = [OCMockObject mockForClass:[SKProductsResponse class]];
    [[[response stub] andReturn:@[]] products];
    [[[response stub] andReturn:@[]] invalidProductIdentifiers];
    _object.successBlock = ^(NSArray *products, NSArray *invalidIdentifiers) {
        STAssertNotNil(products, @"");
        STAssertNotNil(invalidIdentifiers, @"");
        STAssertTrue(products.count == 0, @"");
        STAssertTrue(invalidIdentifiers.count == 0, @"");
    };
    _object.failureBlock = ^(NSError *error) {
        STFail(@"");
    };
    [_object productsRequest:request didReceiveResponse:response];
}

- (void)testProductsRequestDidReceiveResponse_OneProduct
{
    id request = [OCMockObject mockForClass:[SKProductsRequest class]];
    id response = [OCMockObject mockForClass:[SKProductsResponse class]];
    
    id product = [OCMockObject mockForClass:[SKProduct class]];
    [[[product stub] andReturn:@"test"] productIdentifier];

    [[[response stub] andReturn:@[product]] products];
    [[[response stub] andReturn:@[]] invalidProductIdentifiers];
    _object.successBlock = ^(NSArray *products, NSArray *invalidIdentifiers) {
        STAssertNotNil(products, @"");
        STAssertNotNil(invalidIdentifiers, @"");
        STAssertTrue(products.count == 1, @"");
        STAssertTrue(invalidIdentifiers.count == 0, @"");
        STAssertTrue([products containsObject:product], @"");
    };
    _object.failureBlock = ^(NSError *error) {
        STFail(@"");
    };
    [_object productsRequest:request didReceiveResponse:response];
}

- (void)testProductsRequestDidReceiveResponse_OneInvalidIdentifier
{
    id request = [OCMockObject mockForClass:[SKProductsRequest class]];
    id response = [OCMockObject mockForClass:[SKProductsResponse class]];
    [[[response stub] andReturn:@[]] products];
    [[[response stub] andReturn:@[@"test"]] invalidProductIdentifiers];
    _object.successBlock = ^(NSArray *products, NSArray *invalidIdentifiers) {
        STAssertNotNil(products, @"");
        STAssertNotNil(invalidIdentifiers, @"");
        STAssertTrue(products.count == 0, @"");
        STAssertTrue(invalidIdentifiers.count == 1, @"");
        STAssertTrue([invalidIdentifiers containsObject:@"test"], @"");
    };
    _object.failureBlock = ^(NSError *error) {
        STFail(@"");
    };
    [_object productsRequest:request didReceiveResponse:response];
}

- (void)testRequestDidFinish
{
    id request = [OCMockObject mockForClass:[SKProductsRequest class]];
    [_object requestDidFinish:request];
}

- (void)testRequestDidFailWithError_Nil
{
    id request = [OCMockObject mockForClass:[SKProductsRequest class]];
    _object.successBlock = ^(NSArray *products, NSArray *invalidIdentifiers) {
        STFail(@"");
    };
    _object.failureBlock = ^(NSError *error) {
        STAssertNil(error, @"");
    };
    [_object request:request didFailWithError:nil];
}

- (void)testRequestDidFailWithError_Error
{
    id request = [OCMockObject mockForClass:[SKProductsRequest class]];
    _object.successBlock = ^(NSArray *products, NSArray *invalidIdentifiers) {
        STFail(@"");
    };
    NSError *originalError = [NSError errorWithDomain:@"test" code:0 userInfo:nil];
    _object.failureBlock = ^(NSError *error) {
        STAssertEqualObjects(originalError, error, @"");
    };
    [_object request:request didFailWithError:originalError];
}

@end

#pragma clang diagnostic pop
