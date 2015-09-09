#import <XCTest/XCTest.h>
#import "NimbleSpecHelper.h"

@interface ObjCHaveCountTest : XCTestCase

@end

@implementation ObjCHaveCountTest

- (void)testCount {
    expect(@[@1, @2, @3]).to(haveCount(@3));
    expect(@[@1, @2, @3]).notTo(haveCount(@1));

    expectFailureMessage(@"expected to have [1, 2, 3] with count 3, got 1", ^{
        expect(@[@1, @2, @3]).to(haveCount(@1));
    });

    expectFailureMessage(@"expected to not have [1, 2, 3] with count 3, got 3", ^{
        expect(@[@1, @2, @3]).notTo(haveCount(@3));
    });
}

@end
