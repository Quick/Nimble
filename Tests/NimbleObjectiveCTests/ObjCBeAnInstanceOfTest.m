#import "NimbleSpecHelper.h"

@interface ObjCBeAnInstanceOfTest : XCTestCase
@end

@implementation ObjCBeAnInstanceOfTest

- (void)testPositiveMatches {
    NSNull *obj = [NSNull null];
    expect(obj).to(beAnInstanceOf([NSNull class]));
    expect(@1).toNot(beAnInstanceOf([NSNull class]));
}

- (void)testNegativeMatches {
    expectFailureMessageRegex(@"expected to be an instance of NSNull, got <[_A-Za-z]+Number instance>", ^{
        expect(@1).to(beAnInstanceOf([NSNull class]));
    });
    expectFailureMessage(@"expected to not be an instance of NSNull, got <NSNull instance>", ^{
        expect([NSNull null]).toNot(beAnInstanceOf([NSNull class]));
    });
}

- (void)testNilMatches {
    expectNilFailureMessage(@"expected to be an instance of NSNull, got <nil>", ^{
        expect(nil).to(beAnInstanceOf([NSNull class]));
    });

    expectNilFailureMessage(@"expected to not be an instance of NSNull, got <nil>", ^{
        expect(nil).toNot(beAnInstanceOf([NSNull class]));
    });
}

@end
