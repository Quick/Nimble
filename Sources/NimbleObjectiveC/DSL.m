#import "DSL.h"

#if SWIFT_PACKAGE
@import Nimble;
#else
#if __has_include("Nimble-Swift.h")
#import "Nimble-Swift.h"
#else
#import <Nimble/Nimble-Swift.h>
#endif
#endif


NS_ASSUME_NONNULL_BEGIN


NIMBLE_EXPORT NIMBLE_OVERLOADABLE NMBExpectation *__nonnull NMB_expect(id __nullable(^actualBlock)(void), NSString *__nonnull file, NSUInteger line) {
    return [[NMBExpectation alloc] initWithActualBlock:actualBlock
                                              negative:NO
                                                  file:file
                                                  line:line];
}

NIMBLE_EXPORT NMBExpectation *NMB_expectAction(void(^actualBlock)(void), NSString *file, NSUInteger line) {
    return NMB_expect(^id{
        actualBlock();
        return nil;
    }, file, line);
}

NIMBLE_EXPORT void NMB_failWithMessage(NSString *msg, NSString *file, NSUInteger line) {
    return [NMBExpectation failWithMessage:msg file:file line:line];
}

NIMBLE_EXPORT NMBMatcher *NMB_beAnInstanceOf(Class expectedClass) {
    return [NMBMatcher beAnInstanceOfMatcher:expectedClass];
}

NIMBLE_EXPORT NMBMatcher *NMB_beAKindOf(Class expectedClass) {
    return [NMBMatcher beAKindOfMatcher:expectedClass];
}

NIMBLE_EXPORT NIMBLE_OVERLOADABLE NMBObjCBeCloseToMatcher *NMB_beCloseTo(NSNumber *expectedValue) {
    return [NMBMatcher beCloseToMatcher:expectedValue within:0.001];
}

NIMBLE_EXPORT NMBMatcher *NMB_beginWith(id itemElementOrSubstring) {
    return [NMBMatcher beginWithMatcher:itemElementOrSubstring];
}

NIMBLE_EXPORT NIMBLE_OVERLOADABLE NMBMatcher *NMB_beGreaterThan(NSNumber *expectedValue) {
    return [NMBMatcher beGreaterThanMatcher:expectedValue];
}

NIMBLE_EXPORT NIMBLE_OVERLOADABLE NMBMatcher *NMB_beGreaterThanOrEqualTo(NSNumber *expectedValue) {
    return [NMBMatcher beGreaterThanOrEqualToMatcher:expectedValue];
}

NIMBLE_EXPORT NMBMatcher *NMB_beIdenticalTo(id expectedInstance) {
    return [NMBMatcher beIdenticalToMatcher:expectedInstance];
}

NIMBLE_EXPORT NMBMatcher *NMB_be(id expectedInstance) {
    return [NMBMatcher beIdenticalToMatcher:expectedInstance];
}

NIMBLE_EXPORT NIMBLE_OVERLOADABLE NMBMatcher *NMB_beLessThan(NSNumber *expectedValue) {
    return [NMBMatcher beLessThanMatcher:expectedValue];
}

NIMBLE_EXPORT NIMBLE_OVERLOADABLE NMBMatcher *NMB_beLessThanOrEqualTo(NSNumber *expectedValue) {
    return [NMBMatcher beLessThanOrEqualToMatcher:expectedValue];
}

NIMBLE_EXPORT NMBMatcher *NMB_beTruthy(void) {
    return [NMBMatcher beTruthyMatcher];
}

NIMBLE_EXPORT NMBMatcher *NMB_beFalsy(void) {
    return [NMBMatcher beFalsyMatcher];
}

NIMBLE_EXPORT NMBMatcher *NMB_beTrue(void) {
    return [NMBMatcher beTrueMatcher];
}

NIMBLE_EXPORT NMBMatcher *NMB_beFalse(void) {
    return [NMBMatcher beFalseMatcher];
}

NIMBLE_EXPORT NMBMatcher *NMB_beNil(void) {
    return [NMBMatcher beNilMatcher];
}

NIMBLE_EXPORT NMBMatcher *NMB_beEmpty(void) {
    return [NMBMatcher beEmptyMatcher];
}

NIMBLE_EXPORT NMBMatcher *NMB_containWithNilTermination(id itemOrSubstring, ...) {
    NSMutableArray *itemOrSubstringArray = [NSMutableArray array];

    if (itemOrSubstring) {
        [itemOrSubstringArray addObject:itemOrSubstring];

        va_list args;
        va_start(args, itemOrSubstring);
        id next;
        while ((next = va_arg(args, id))) {
            [itemOrSubstringArray addObject:next];
        }
        va_end(args);
    }

    return [NMBMatcher containMatcher:itemOrSubstringArray];
}

NIMBLE_EXPORT NMBMatcher *NMB_containElementSatisfying(BOOL(^matcher)(id)) {
    return [NMBMatcher containElementSatisfyingMatcher:matcher];
}

NIMBLE_EXPORT NMBMatcher *NMB_endWith(id itemElementOrSubstring) {
    return [NMBMatcher endWithMatcher:itemElementOrSubstring];
}

NIMBLE_EXPORT NIMBLE_OVERLOADABLE NMBMatcher *NMB_equal(__nullable id expectedValue) {
    return [NMBMatcher equalMatcher:expectedValue];
}

NIMBLE_EXPORT NIMBLE_OVERLOADABLE NMBMatcher *NMB_haveCount(id expectedValue) {
    return [NMBMatcher haveCountMatcher:expectedValue];
}

NIMBLE_EXPORT NMBMatcher *NMB_match(id expectedValue) {
    return [NMBMatcher matchMatcher:expectedValue];
}

NIMBLE_EXPORT NMBMatcher *NMB_allPass(id expectedValue) {
    return [NMBMatcher allPassMatcher:expectedValue];
}

NIMBLE_EXPORT NMBMatcher *NMB_satisfyAnyOfWithMatchers(id matchers) {
    return [NMBMatcher satisfyAnyOfMatcher:matchers];
}

NIMBLE_EXPORT NMBMatcher *NMB_satisfyAllOfWithMatchers(id matchers) {
    return [NMBMatcher satisfyAllOfMatcher:matchers];
}

#if !SWIFT_PACKAGE
NIMBLE_EXPORT NMBObjCRaiseExceptionMatcher *NMB_raiseException(void) {
    return [NMBMatcher raiseExceptionMatcher];
}
#endif

NIMBLE_EXPORT NMBWaitUntilTimeoutBlock NMB_waitUntilTimeoutBuilder(NSString *file, NSUInteger line) {
    return ^(NSTimeInterval timeout, void (^ _Nonnull action)(void (^ _Nonnull)(void))) {
        [NMBWait untilTimeout:timeout file:file line:line action:action];
    };
}

NIMBLE_EXPORT NMBWaitUntilBlock NMB_waitUntilBuilder(NSString *file, NSUInteger line) {
  return ^(void (^ _Nonnull action)(void (^ _Nonnull)(void))) {
    [NMBWait untilFile:file line:line action:action];
  };
}

NS_ASSUME_NONNULL_END
