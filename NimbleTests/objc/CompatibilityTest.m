#import <XCTest/XCTest.h>
#import <Nimble/Nimble.h>
#import "NimbleTests-Swift.h"

@interface CompatibilityTest : XCTestCase
@end

@implementation CompatibilityTest

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
    expect(obj).withTimeout(2).toEventuallyNot(beNil());
}

- (void)testBeAnInstanceOf {
    NSNull *obj = [NSNull null];
    expect(obj).to(beAnInstanceOf([NSNull class]));
    expect(@1).toNot(beAnInstanceOf([NSNull class]));

    [self expectFailureMessageForNil:@"expected to not be an instance of NSNull, got <nil>" inBlock:^{
        expect(nil).toNot(beAnInstanceOf([NSNull class]));
    }];
}

- (void)testBeAKindOf {
    NSMutableArray *array = [NSMutableArray array];
    expect(array).to(beAKindOf([NSArray class]));
    expect(@1).toNot(beAKindOf([NSNull class]));
    expect(nil).toNot(beAKindOf([NSNull class]));
}

- (void)testBeCloseTo {
    expect(@1.2).to(beCloseTo(@1.2001));
    expect(@1.2).to(beCloseTo(@2).within(10));
    [self expectFailureMessageForNil:@"expected to not be close to <0.0000> (within 0.0010), got <nil>" inBlock:^{
        expect(nil).toNot(beCloseTo(@0));
    }];
}

- (void)testBeginWith {
    expect(@"hello world!").to(beginWith(@"hello"));
    expect(@"hello world!").toNot(beginWith(@"world"));

    NSArray *array = @[@1, @2];
    expect(array).to(beginWith(@1));
    expect(array).toNot(beginWith(@2));
    expect(nil).toNot(beginWith(@1));
}

- (void)testBeGreaterThan {
    expect(@2).to(beGreaterThan(@1));
    expect(@2).toNot(beGreaterThan(@2));
    expect(nil).toNot(beGreaterThan(@(-1)));
}

- (void)testBeGreaterThanOrEqualTo {
    expect(@2).to(beGreaterThanOrEqualTo(@2));
    expect(@2).toNot(beGreaterThanOrEqualTo(@3));
    expect(nil).toNot(beGreaterThanOrEqualTo(@(-1)));
}

- (void)testBeIdenticalTo {
    NSNull *obj = [NSNull null];
    expect(obj).to(beIdenticalTo([NSNull null]));
    expect(@2).toNot(beIdenticalTo(@3));
    expect(nil).toNot(beIdenticalTo(nil));
    expect(nil).toNot(beIdenticalTo(@1));
}

- (void)testBeLessThan {
    expect(@2).to(beLessThan(@3));
    expect(@2).toNot(beLessThan(@2));
    expect(nil).toNot(beLessThan(@1));
}

- (void)testBeLessThanOrEqualTo {
    expect(@2).to(beLessThanOrEqualTo(@2));
    expect(@2).toNot(beLessThanOrEqualTo(@1));
    expect(nil).toNot(beLessThan(@2));
}

- (void)testBeTruthy {
    expect(@YES).to(beTruthy());
    expect(@NO).toNot(beTruthy());
    expect(nil).toNot(beTruthy());
}

- (void)testBeFalsy {
    expect(@NO).to(beFalsy());
    expect(@YES).toNot(beFalsy());
    expect(nil).to(beFalsy());
}

- (void)testBeTrue {
    expect(@YES).to(beTrue());
    expect(@NO).toNot(beTrue());
    expect(nil).toNot(beTrue());
}

- (void)testBeFalse {
    expect(@NO).to(beFalse());
    expect(@YES).toNot(beFalse());
    expect(nil).toNot(beFalse());
}

- (void)testBeNil {
    expect(nil).to(beNil());
    expect(@NO).toNot(beNil());
}

- (void)testContain {
    NSArray *array = @[@1, @2];
    expect(array).to(contain(@1));
    expect(array).toNot(contain(@"HI"));
    expect(nil).toNot(contain(@"hi"));
    expect(@"String").to(contain(@"Str"));
    expect(@"Other").toNot(contain(@"Str"));
}

- (void)testEndWith {
    NSArray *array = @[@1, @2];
    expect(@"hello world!").to(endWith(@"world!"));
    expect(@"hello world!").toNot(endWith(@"hello"));
    expect(array).to(endWith(@2));
    expect(array).toNot(endWith(@1));
    expect(nil).toNot(endWith(@1));
    expect(@1).toNot(contain(@"foo"));
}

- (void)testEqual {
    expect(@1).to(equal(@1));
    expect(@1).toNot(equal(@2));
    expect(@1).notTo(equal(@2));
    expect(@"hello").to(equal(@"hello"));
    expect(nil).toNot(equal(nil));

    [self expectFailureMessageForNil:@"expected to equal <nil>, got <nil>" inBlock:^{
        expect(nil).to(equal(nil));
    }];
}

- (void)testMatch {
    expect(@"11:14").to(match(@"\\d{2}:\\d{2}"));
    expect(@"hello").toNot(match(@"\\d{2}:\\d{2}"));
}

- (void)testRaiseException {
    __block NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:@"No food" userInfo:nil];
    expectAction([exception raise]).to(raiseException());
    expectAction(exception).toNot(raiseException());
}

#pragma mark - Private

- (void)expectFailureMessage:(NSString *)message inBlock:(void(^)())block {
    [NimbleHelper expectFailureMessage:message block:block];
}

- (void)expectFailureMessageForNil:(NSString *)message inBlock:(void(^)())block {
    [NimbleHelper expectFailureMessageForNil:message block:block];
}


@end
