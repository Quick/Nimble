#import <XCTest/XCTest.h>
#import <Nimble/Nimble.h>
#import "NimbleTests-Swift.h"

#define expectNilFailureMessage(MSG, BLOCK) \
[NimbleHelper expectFailureMessageForNil:(MSG) block:(BLOCK) file:@(__FILE__) line:__LINE__];

#define expectFailureMessage(MSG, BLOCK) \
[NimbleHelper expectFailureMessage:(MSG) block:(BLOCK) file:@(__FILE__) line:__LINE__];


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

    expectNilFailureMessage(@"expected to be an instance of NSNull, got <nil>", ^{
        expect(nil).to(beAnInstanceOf([NSNull class]));
    });

    expectNilFailureMessage(@"expected to not be an instance of NSNull, got <nil>", ^{
        expect(nil).toNot(beAnInstanceOf([NSNull class]));
    });
}

- (void)testBeAKindOf {
    NSMutableArray *array = [NSMutableArray array];
    expect(array).to(beAKindOf([NSArray class]));
    expect(@1).toNot(beAKindOf([NSNull class]));
    expectNilFailureMessage(@"expected to be a kind of NSNull, got <nil>", ^{
        expect(nil).to(beAKindOf([NSNull class]));
    });
    expectNilFailureMessage(@"expected to not be a kind of NSNull, got <nil>", ^{
        expect(nil).toNot(beAKindOf([NSNull class]));
    });
}

- (void)testBeCloseTo {
    expect(@1.2).to(beCloseTo(@1.2001));
    expect(@1.2).to(beCloseTo(@2).within(10));
    expectNilFailureMessage(@"expected to be close to <0.0000> (within 0.0010), got <nil>", ^{
        expect(nil).to(beCloseTo(@0));
    });
    expectNilFailureMessage(@"expected to not be close to <0.0000> (within 0.0010), got <nil>", ^{
        expect(nil).toNot(beCloseTo(@0));
    });
}

- (void)testBeginWith {
    expect(@"hello world!").to(beginWith(@"hello"));
    expect(@"hello world!").toNot(beginWith(@"world"));

    NSArray *array = @[@1, @2];
    expect(array).to(beginWith(@1));
    expect(array).toNot(beginWith(@2));

    expectNilFailureMessage(@"expected to begin with <1>, got <nil>", ^{
        expect(nil).to(beginWith(@1));
    });
    expectNilFailureMessage(@"expected to not begin with <1>, got <nil>", ^{
        expect(nil).toNot(beginWith(@1));
    });
}

- (void)testBeGreaterThan {
    expect(@2).to(beGreaterThan(@1));
    expect(@2).toNot(beGreaterThan(@2));
    expectNilFailureMessage(@"expected to be greater than <-1.0000>, got <nil>", ^{
        expect(nil).to(beGreaterThan(@(-1)));
    });
    expectNilFailureMessage(@"expected to not be greater than <1.0000>, got <nil>", ^{
        expect(nil).toNot(beGreaterThan(@(1)));
    });
}

- (void)testBeGreaterThanOrEqualTo {
    expect(@2).to(beGreaterThanOrEqualTo(@2));
    expect(@2).toNot(beGreaterThanOrEqualTo(@3));
    expectNilFailureMessage(@"expected to be greater than or equal to <-1.0000>, got <nil>", ^{
        expect(nil).to(beGreaterThanOrEqualTo(@(-1)));
    });
    expectNilFailureMessage(@"expected to not be greater than or equal to <1.0000>, got <nil>", ^{
        expect(nil).toNot(beGreaterThanOrEqualTo(@(1)));
    });
}

- (void)testBeIdenticalTo {
    NSNull *obj = [NSNull null];
    expect(obj).to(beIdenticalTo([NSNull null]));
    expect(@2).toNot(beIdenticalTo(@3));
    expectNilFailureMessage(@"expected to be identical to nil, got nil", ^{
        expect(nil).to(beIdenticalTo(nil));
    });
    expectNilFailureMessage(([NSString stringWithFormat:@"expected to not be identical to <%p>, got nil", obj]), ^{
        expect(nil).toNot(beIdenticalTo(obj));
    });
}

- (void)testBeLessThan {
    expect(@2).to(beLessThan(@3));
    expect(@2).toNot(beLessThan(@2));
    expectNilFailureMessage(@"expected to be less than <-1.0000>, got <nil>", ^{
        expect(nil).to(beLessThan(@(-1)));
    });
    expectNilFailureMessage(@"expected to not be less than <1.0000>, got <nil>", ^{
        expect(nil).toNot(beLessThan(@1));
    });
}

- (void)testBeLessThanOrEqualTo {
    expect(@2).to(beLessThanOrEqualTo(@2));
    expect(@2).toNot(beLessThanOrEqualTo(@1));
    expectNilFailureMessage(@"expected to be less than or equal to <1.0000>, got <nil>", ^{
        expect(nil).to(beLessThanOrEqualTo(@1));
    });
    expectNilFailureMessage(@"expected to not be less than or equal to <-1.0000>, got <nil>", ^{
        expect(nil).toNot(beLessThanOrEqualTo(@(-1)));
    });
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
    expectNilFailureMessage(@"expected to be false, got <nil>", ^{
        expect(nil).to(beFalse());
    });
    expectNilFailureMessage(@"expected to not be false, got <nil>", ^{
        expect(nil).toNot(beFalse());
    });
}

- (void)testBeNil {
    expect(nil).to(beNil());
    expect(@NO).toNot(beNil());

    expectFailureMessage(@"expected to not be nil, got <nil>", ^{
        expect(nil).toNot(beNil());
    });
}

- (void)testContain {
    NSArray *array = @[@1, @2];
    expect(array).to(contain(@1));
    expect(array).toNot(contain(@"HI"));
    expect(@"String").to(contain(@"Str"));
    expect(@"Other").toNot(contain(@"Str"));
    expectNilFailureMessage(@"expected to contain <hi>, got <nil>", ^{
        expect(nil).to(contain(@"hi"));
    });
    expectNilFailureMessage(@"expected to not contain <hi>, got <nil>", ^{
        expect(nil).toNot(contain(@"hi"));
    });
}

- (void)testEndWith {
    NSArray *array = @[@1, @2];
    expect(@"hello world!").to(endWith(@"world!"));
    expect(@"hello world!").toNot(endWith(@"hello"));
    expect(array).to(endWith(@2));
    expect(array).toNot(endWith(@1));
    expect(@1).toNot(contain(@"foo"));
    expectNilFailureMessage(@"expected to end with <1>, got <nil>", ^{
        expect(nil).to(endWith(@1));
    });
    expectNilFailureMessage(@"expected to not end with <1>, got <nil>", ^{
        expect(nil).toNot(endWith(@1));
    });
}

- (void)testEqual {
    expect(@1).to(equal(@1));
    expect(@1).toNot(equal(@2));
    expect(@1).notTo(equal(@2));
    expect(@"hello").to(equal(@"hello"));

    expectNilFailureMessage(@"expected to equal <nil>, got <nil>", ^{
        expect(nil).to(equal(nil));
    });
    expectNilFailureMessage(@"expected to not equal <nil>, got <nil>", ^{
        expect(nil).toNot(equal(nil));
    });
}

- (void)testMatch {
    expect(@"11:14").to(match(@"\\d{2}:\\d{2}"));
    expect(@"hello").toNot(match(@"\\d{2}:\\d{2}"));

    expectNilFailureMessage(@"expected to match <\\d{2}:\\d{2}>, got <nil>", ^{
        expect(nil).to(match(@"\\d{2}:\\d{2}"));
    });
    expectNilFailureMessage(@"expected to not match <\\d{2}:\\d{2}>, got <nil>", ^{
        expect(nil).toNot(match(@"\\d{2}:\\d{2}"));
    });
}

- (void)testRaiseException {
    __block NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:@"No food" userInfo:nil];
    expectAction([exception raise]).to(raiseException());
    expectAction(exception).toNot(raiseException());
}

@end
