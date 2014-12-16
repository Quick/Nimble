#import <XCTest/XCTest.h>
#import "NimbleSpecHelper.h"

@interface ObjCRaiseExceptionTest : XCTestCase

@end

@implementation ObjCRaiseExceptionTest

- (void)testPositiveMatches {
    __block NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException
                                                             reason:@"No food"
                                                           userInfo:nil];
    expectAction([exception raise]).to(raiseException());
    expectAction(exception).toNot(raiseException());
}

- (void)testNegativeMatches {
    __block NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException
                                                             reason:@"No food"
                                                           userInfo:nil];
    expectFailureMessage(@"expected to raise any exception", ^{
        expectAction([exception reason]).to(raiseException());
    });
    expectFailureMessage(@"expected to not raise any exception", ^{
        expectAction([exception raise]).toNot(raiseException());
    });
}

@end
