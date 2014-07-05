#import <Nimble/DSL.h>
#import <Nimble/Nimble-Swift.h>

Nimble_EXPORT KICExpectation *KIC_expect(id(^actualBlock)(), const char *file, int line) {
    return [[KICExpectation alloc] initWithActualBlock:actualBlock
                                              negative:NO
                                                  file:[[NSString alloc] initWithFormat:@"%s", file]
                                                  line:line];
}

Nimble_EXPORT id<KICMatcher> KIC_beAnInstanceOf(Class expectedClass) {
    return [KICObjCMatcher beAnInstanceOfMatcher:expectedClass];
}

Nimble_EXPORT id<KICMatcher> KIC_beASubclassOf(Class expectedClass) {
    return [KICObjCMatcher beASubclassOfMatcher:expectedClass];
}

Nimble_EXPORT KICObjCBeCloseToMatcher *KIC_beCloseTo(NSNumber *expectedValue) {
    return [KICObjCMatcher beCloseToMatcher:expectedValue within:0.001];
}

Nimble_EXPORT id<KICMatcher> KIC_beginWith(id itemElementOrSubstring) {
    return [KICObjCMatcher beginWithMatcher:itemElementOrSubstring];
}

Nimble_EXPORT id<KICMatcher> KIC_beGreaterThan(NSNumber *expectedValue) {
    return [KICObjCMatcher beGreaterThanMatcher:expectedValue];
}

Nimble_EXPORT id<KICMatcher> KIC_beGreaterThanOrEqualTo(NSNumber *expectedValue) {
    return [KICObjCMatcher beGreaterThanOrEqualToMatcher:expectedValue];
}

Nimble_EXPORT id<KICMatcher> KIC_beIdenticalTo(id expectedInstance) {
    return [KICObjCMatcher beIdenticalToMatcher:expectedInstance];
}

Nimble_EXPORT id<KICMatcher> KIC_beLessThan(NSNumber *expectedValue) {
    return [KICObjCMatcher beLessThanMatcher:expectedValue];
}

Nimble_EXPORT id<KICMatcher> KIC_beLessThanOrEqualTo(NSNumber *expectedValue) {
    return [KICObjCMatcher beLessThanOrEqualToMatcher:expectedValue];
}

Nimble_EXPORT id<KICMatcher> KIC_beTruthy() {
    return [KICObjCMatcher beTruthyMatcher];
}

Nimble_EXPORT id<KICMatcher> KIC_beFalsy() {
    return [KICObjCMatcher beFalsyMatcher];
}

Nimble_EXPORT id<KICMatcher> KIC_beNil() {
    return [KICObjCMatcher beNilMatcher];
}

Nimble_EXPORT id<KICMatcher> KIC_contain(id itemOrSubstring) {
    return [KICObjCMatcher containMatcher:itemOrSubstring];
}

Nimble_EXPORT id<KICMatcher> KIC_endWith(id itemElementOrSubstring) {
    return [KICObjCMatcher endWithMatcher:itemElementOrSubstring];
}

Nimble_EXPORT id<KICMatcher> KIC_equal(id expectedValue) {
    return [KICObjCMatcher equalMatcher:expectedValue];
}

Nimble_EXPORT KICObjCRaiseExceptionMatcher *KIC_raiseException() {
    return [KICObjCMatcher raiseExceptionMatcher];
}

