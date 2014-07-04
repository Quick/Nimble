#import <XCTest/XCTest.h>
#import <Kick/Kick.h>


@interface CompatibilityTest : XCTestCase

@end

@implementation CompatibilityTest

- (void)testBeAnInstanceOf {
    expect([NSNull null]).to(beAnInstanceOf([NSNull class]));
    expect(@1).toNot(beAnInstanceOf([NSNull class]));
}
- (void)testBeASubclassOf {
    expect([NSMutableArray array]).to(beASubclassOf([NSArray class]));
    expect(@1).toNot(beASubclassOf([NSNull class]));
}

- (void)testBeCloseTo {
    expect(@1.2).to(beCloseTo(@1.2001));
    expect(@1.2).to(beCloseTo(@2).within(10));
}

- (void)testBeginWith {
    expect(@"hello world!").to(beginWith(@"hello"));
    expect(@"hello world!").toNot(beginWith(@"world"));
    expect(@[@1, @2]).to(beginWith(@1));
    expect(@[@1, @2]).toNot(beginWith(@2));
}

- (void)testBeGreaterThan {
    expect(@2).to(beGreaterThan(@1));
    expect(@2).toNot(beGreaterThan(@2));
}

- (void)testBeGreaterThanOrEqualTo {
    expect(@2).to(beGreaterThanOrEqualTo(@2));
    expect(@2).toNot(beGreaterThanOrEqualTo(@3));
}

- (void)testBeIdenticalTo {
    expect([NSNull null]).to(beIdenticalTo([NSNull null]));
    expect(@2).toNot(beIdenticalTo(@3));
}

- (void)testBeLessThan {
    expect(@2).to(beLessThan(@3));
    expect(@2).toNot(beLessThan(@2));
}

- (void)testBeLessThanOrEqualTo {
    expect(@2).to(beLessThanOrEqualTo(@2));
    expect(@2).toNot(beLessThanOrEqualTo(@1));
}

- (void)testBeTruthy {
    expect(@YES).to(beTruthy());
    expect(@NO).toNot(beTruthy());
}

- (void)testBeFalsy {
    expect(@NO).to(beFalsy());
    expect(@YES).toNot(beFalsy());
}

- (void)testBeNil {
    expect(nil).to(beNil());
    expect(@NO).toNot(beNil());
}

- (void)testContain {
    expect(@[@1, @2]).to(contain(@1));
    expect(@[@1, @2]).toNot(contain(@"HI"));
}

- (void)testEndWith {
    expect(@"hello world!").to(endWith(@"world!"));
    expect(@"hello world!").toNot(endWith(@"hello"));
    expect(@[@1, @2]).to(endWith(@2));
    expect(@[@1, @2]).toNot(endWith(@1));
}

- (void)testEqual {
    expect(@1).to(equal(@1));
    expect(@1).toNot(equal(@2));
    expect(@1).notTo(equal(@2));
    expect(@"hello").to(equal(@"hello"));
}

//- (void)testOneOf {
//    expect(@1).to(beOneOf(@1));
//    expect(@1).toNot(equal(@2));
//    expect(@1).notTo(equal(@2));
//    expect(@"hello").to(equal(@"hello"));
//}

@end
