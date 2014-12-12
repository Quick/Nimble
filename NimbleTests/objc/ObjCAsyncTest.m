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

@end
