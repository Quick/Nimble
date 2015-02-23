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

- (void)testPositiveMatchesWithSubMatchers {
    __block NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException
                                                             reason:@"No food"
                                                           userInfo:@{@"key": @"value"}];
    expectAction([exception raise]).to(raiseException().
                                       withName(equal(NSInvalidArgumentException)).
                                       withReason(beginWith(@"No")));
    expectAction([exception raise]).to(raiseException().
                                       withName(equal(NSInvalidArgumentException)));
    expectAction([exception raise]).toNot(raiseException().withReason(beginWith(@"Much")));
}

- (void)testNegativeMatches {
    __block NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException
                                                             reason:@"No food"
                                                           userInfo:@{@"key": @"value"}];
    expectFailureMessage(@"expected to raise any exception", ^{
        expectAction([exception reason]).to(raiseException());
    });

    expectFailureMessage(@"expected to raise exception named equal <foo>", ^{
        expectAction([exception reason]).to(raiseException().
                                            named(@"foo"));
    });

    expectFailureMessage(@"expected to raise exception named equal <NSInvalidArgumentException> with reason equal <cakes>", ^{
        expectAction([exception reason]).to(raiseException().
                                            named(NSInvalidArgumentException).
                                            reason(@"cakes"));
    });

    expectFailureMessage(@"expected to raise exception named equal <NSInvalidArgumentException> with reason equal <No food> with userInfo equal <{k = v;}>", ^{
        expectAction([exception reason]).to(raiseException().
                                            named(NSInvalidArgumentException).
                                            reason(@"No food").
                                            userInfo(@{@"k": @"v"}));
    });


    expectFailureMessage(@"expected to not raise any exception", ^{
        expectAction([exception raise]).toNot(raiseException());
    });
}

- (void)testNegativeMatchesWithSubMatchers {
    __block NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException
                                                             reason:@"No food"
                                                           userInfo:@{@"key": @"value"}];
    
    expectFailureMessage(@"expected to raise exception named equal <NSInvalidArgumentException> with reason begin with <Much>", ^{
        expectAction([exception raise]).to(raiseException().
                                              withName(equal(NSInvalidArgumentException)).
                                              withReason(beginWith(@"Much")));
    });
    expectFailureMessage(@"expected to raise exception with reason begin with <Much>", ^{
        expectAction([exception raise]).to(raiseException().
                                           withReason(beginWith(@"Much")));
    });
    
    expectFailureMessage(@"expected to not raise exception named equal <NSInvalidArgumentException> with reason begin with <No>", ^{
        expectAction([exception raise]).toNot(raiseException().
                                           withName(equal(NSInvalidArgumentException)).
                                           withReason(beginWith(@"No")));
    });
    expectFailureMessage(@"expected to not raise exception named equal <NSInvalidArgumentException>", ^{
        expectAction([exception raise]).toNot(raiseException().
                                              withName(equal(NSInvalidArgumentException)));
    });
    expectFailureMessage(@"expected to not raise exception with userInfo equal <{key = value;}>", ^{
        expectAction([exception raise]).toNot(raiseException().
                                              withUserInfo(equal(@{@"key": @"value"})));
    });
}

@end
