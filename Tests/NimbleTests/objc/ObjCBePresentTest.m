#import <XCTest/XCTest.h>
#import "NimbleSpecHelper.h"

@interface ObjCBePresentTest: XCTestCase

@end

@implementation ObjCBePresentTest

- (void)testPositiveMatches {
    expect(@NO).to(bePresent());
    expect(nil).toNot(bePresent());
}

- (void)testNegativeMatches {
    expectFailureMessage(@"expected to be present, got <nil>", ^{
        expect(nil).to(bePresent());
    });
    expectFailureMessage(@"expected to not be present, got <1>", ^{
        expect(@1).toNot(bePresent());
    });
}

@end

