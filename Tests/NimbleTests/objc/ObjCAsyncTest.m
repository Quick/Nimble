#import <XCTest/XCTest.h>
#import <Nimble/Nimble.h>
#import "NimbleSpecHelper.h"

@interface ObjCAsyncTest : XCTestCase

@end

@implementation ObjCAsyncTest

- (void)testAsync {
    __block id obj = @1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        obj = nil;
    });
    expect(obj).toEventually(beNil());
}


- (void)testAsyncWithCustomTimeout {
    __block id obj = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        obj = @1;
    });
    expect(obj).withTimeout(5).toEventuallyNot(beNil());
}

- (void)testAsyncCallback {
    waitUntil(^(void (^done)(void)){
        done();
    });
    waitUntil(^(void (^done)(void)){
        dispatch_async(dispatch_get_main_queue(), ^{
            done();
        });
    });

    expectFailureMessage(@"Waited more than 1.0 second", ^{
        waitUntil(^(void (^done)(void)){ /* ... */ });
    });

    expectFailureMessage(@"Waited more than 0.01 seconds", ^{
        waitUntilTimeout(0.01, ^(void (^done)(void)){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [NSThread sleepForTimeInterval:0.1];
                done();
            });
        });
    });

    expectFailureMessage(@"expected to equal <goodbye>, got <hello>", ^{
        waitUntil(^(void (^done)(void)){
            [NSThread sleepForTimeInterval:0.1];
            expect(@"hello").to(equal(@"goodbye"));
            done();
        });
    });
}

- (void)testToNeverPositiveMatches {
    __block id value = @0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        value = @1;
    });
    expect(value).toNever(beGreaterThan(1));

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        value = @0;
    });
    expect(value).neverTo(beGreaterThan(1));
}

- (void)testToNeverNegativeMatches {
    __block id value = @0;
    expectFailureMessage(@"expected to never equal <0>, got <0>", ^{
        expect(value).toNever(equal(0));
    });
    expectFailureMessage(@"expected to never equal <0>, got <0>", ^{
        expect(value).neverTo(equal(0));
    });
    expectFailureMessage(@"expected to never equal <1>, got <1>", ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            value = @1;
        });
        expect(value).toNever(equal(1));
    });
    expectFailureMessage(@"expected to never equal <1>, got <1>", ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            value = @1;
        });
        expect(value).neverTo(equal(1));
    });
}

- (void)testToAlwaysPositiveMatches {
    __block id value = @2;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        value = @3;
    });
    expect(value).toAlways(beGreaterThan(1));

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        value = @2;
    });
    expect(value).alwaysTo(beGreaterThan(1));
}

- (void)testToAlwaysNegativeMatches {
    __block id value = @0;
    expectFailureMessage(@"expected to always equal <0>, got <1>", ^{
        value = @1;
        expect(value).toAlways(equal(0));
    });
    expectFailureMessage(@"expected to always equal <0>, got <1>", ^{
        value = @1;
        expect(value).alwaysTo(equal(0));
    });
    expectFailureMessage(@"expected to always equal <1>, got <2>", ^{
        value = @1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            value = @2;
        });
        expect(value).toAlways(equal(1));
    });
    expectFailureMessage(@"expected to always equal <1>, got <2>", ^{
        value = @1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            value = @2;
        });
        expect(value).alwaysTo(equal(1));
    });
}

@end
