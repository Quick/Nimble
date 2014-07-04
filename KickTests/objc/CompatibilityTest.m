#import <XCTest/XCTest.h>
#import <Kick/Kick.h>

@interface CompatibilityTest : XCTestCase

@end

@implementation CompatibilityTest

- (void)testExpectations {
    expect(@1).to(equal(@1));
    expect(@1).toNot(equal(@2));
    expect(@"hello").to(equal(@"hello"));
//    expect(@1).to(equal(@1));
}

@end
