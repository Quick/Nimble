#import <XCTest/XCTest.h>
#import "NimbleSpecHelper.h"

@interface ObjCContainObjectSatisfyingTest : XCTestCase

@end

@implementation ObjCContainObjectSatisfyingTest

- (void)testPassingMatches {
    NSArray *orderIndifferentArray = @[@1, @2, @3];
    expect(orderIndifferentArray).to(containObjectSatisfying(^BOOL(id object) {
        return [object isEqualToNumber:@1];
    }));
    expect(orderIndifferentArray).to(containObjectSatisfying(^BOOL(id object) {
        return [object isEqualToNumber:@2];
    }));
    expect(orderIndifferentArray).to(containObjectSatisfying(^BOOL(id object) {
        return [object isEqualToNumber:@3];
    }));

    orderIndifferentArray = @[@3, @1, @2];
    expect(orderIndifferentArray).to(containObjectSatisfying(^BOOL(id object) {
        return [object isEqualToNumber:@1];
    }));
    expect(orderIndifferentArray).to(containObjectSatisfying(^BOOL(id object) {
        return [object isEqualToNumber:@2];
    }));
    expect(orderIndifferentArray).to(containObjectSatisfying(^BOOL(id object) {
        return [object isEqualToNumber:@3];
    }));

    NSSet *orderIndifferentSet = [NSSet setWithObjects:@"turtle test", @"turtle assessment", nil];
    expect(orderIndifferentSet).to(containObjectSatisfying(^BOOL(id object) {
        return [object isEqualToString:@"turtle assessment"];
    }));
}

- (void)testFailingMatches {
    expectFailureMessage(@"expected to find object in collection that satisfies predicate", ^{
        expect(@[@1]).to(containObjectSatisfying(^BOOL(id object) {
            return [object isEqualToNumber:@2];
        }));
    });
    expectFailureMessage(@"containObjectSatisfying must be provided an NSFastEnumeration object", ^{
        expect((nil)).to(containObjectSatisfying(^BOOL(id object) {
            return [object isEqualToNumber:@3];
        }));
    });
    expectFailureMessage(@"containObjectSatisfying must be provided an NSFastEnumeration object", ^{
        expect((@3)).to(containObjectSatisfying(^BOOL(id object) {
            return [object isEqualToNumber:@3];
        }));
    });
}

- (void)testNegativeCases {
    NSArray *orderIndifferentArray = @[@"puppies", @"kittens", @"turtles"];
    expect(orderIndifferentArray).toNot(containObjectSatisfying(^BOOL(id object) {
        return [object isEqualToString:@"armadillos"];
    }));
}

@end
