#import <XCTest/XCTest.h>
#import "NimbleSpecHelper.h"

@interface ObjCRaiseExceptionTest : XCTestCase

@end

@implementation ObjCRaiseExceptionTest

- (void)testPositiveMatches {
    __block NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException
                                                             reason:@"No food"
                                                           userInfo:@{@"key": @"value"}];
    expectAction([exception raise]).to(raiseException());
    expectAction([exception raise]).to(raiseException().named(NSInvalidArgumentException));
    expectAction([exception raise]).to(raiseException().
                                       named(NSInvalidArgumentException).
                                       reason(@"No food"));
    expectAction([exception raise]).to(raiseException().
                                       named(NSInvalidArgumentException).
                                       reason(@"No food").
                                       userInfo(@{@"key": @"value"}));

    expectAction(exception).toNot(raiseException());
}

- (void)testNegativeMatches {
    __block NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException
                                                             reason:@"No food"
                                                           userInfo:@{@"key": @"value"}];
    expectFailureMessage(@"expected to raise any exception", ^{
        expectAction([exception reason]).to(raiseException());
    });

    expectFailureMessage(@"expected to raise exception named <foo>", ^{
        expectAction([exception reason]).to(raiseException().
                                            named(@"foo"));
    });

    expectFailureMessage(@"expected to raise exception named <NSInvalidArgumentException> with reason <cakes>", ^{
        expectAction([exception reason]).to(raiseException().
                                            named(NSInvalidArgumentException).
                                            reason(@"cakes"));
    });

    expectFailureMessage(@"expected to raise exception named <NSInvalidArgumentException> with reason <No food> and userInfo <{k = v;}>", ^{
        expectAction([exception reason]).to(raiseException().
                                            named(NSInvalidArgumentException).
                                            reason(@"No food").
                                            userInfo(@{@"k": @"v"}));
    });


    expectFailureMessage(@"expected to not raise any exception", ^{
        expectAction([exception raise]).toNot(raiseException());
    });
}

@end
