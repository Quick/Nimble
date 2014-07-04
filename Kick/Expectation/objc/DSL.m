#import <Kick/DSL.h>
#import <Kick/Kick-Swift.h>

KICK_EXPORT KICExpectation *KIC_expect(id(^actualBlock)(), const char *file, int line) {
    return [[KICExpectation alloc] initWithActualBlock:actualBlock
                                              negative:NO
                                                  file:[[NSString alloc] initWithFormat:@"%s", file]
                                                  line:line];
}

KICK_EXPORT id<KICMatcher> KIC_beAnInstanceOf(Class expectedClass) {
    return [KICObjCMatcher beAnInstanceOfMatcher:expectedClass];
}

KICK_EXPORT id<KICMatcher> KIC_beASubclassOf(Class expectedClass) {
    return [KICObjCMatcher beASubclassOfMatcher:expectedClass];
}

KICK_EXPORT KICObjCBeCloseToMatcher *KIC_beCloseTo(NSNumber *expectedValue) {
    return [KICObjCMatcher beCloseToMatcher:expectedValue within:0.001];
}

KICK_EXPORT id<KICMatcher> KIC_beginWith(id itemElementOrSubstring) {
    return [KICObjCMatcher beginWithMatcher:itemElementOrSubstring];
}

KICK_EXPORT id<KICMatcher> KIC_beGreaterThan(NSNumber *expectedValue) {
    return [KICObjCMatcher beGreaterThanMatcher:expectedValue];
}

KICK_EXPORT id<KICMatcher> KIC_beGreaterThanOrEqualTo(NSNumber *expectedValue) {
    return [KICObjCMatcher beGreaterThanOrEqualToMatcher:expectedValue];
}

KICK_EXPORT id<KICMatcher> KIC_beIdenticalTo(id expectedInstance) {
    return [KICObjCMatcher beIdenticalToMatcher:expectedInstance];
}

KICK_EXPORT id<KICMatcher> KIC_beLessThan(NSNumber *expectedValue) {
    return [KICObjCMatcher beLessThanMatcher:expectedValue];
}

KICK_EXPORT id<KICMatcher> KIC_beLessThanOrEqualTo(NSNumber *expectedValue) {
    return [KICObjCMatcher beLessThanOrEqualToMatcher:expectedValue];
}

KICK_EXPORT id<KICMatcher> KIC_beTruthy() {
    return [KICObjCMatcher beTruthyMatcher];
}

KICK_EXPORT id<KICMatcher> KIC_beFalsy() {
    return [KICObjCMatcher beFalsyMatcher];
}

KICK_EXPORT id<KICMatcher> KIC_beNil() {
    return [KICObjCMatcher beNilMatcher];
}

KICK_EXPORT id<KICMatcher> KIC_contain(id itemOrSubstring) {
    return [KICObjCMatcher containMatcher:itemOrSubstring];
}

KICK_EXPORT id<KICMatcher> KIC_endWith(id itemElementOrSubstring) {
    return [KICObjCMatcher endWithMatcher:itemElementOrSubstring];
}

KICK_EXPORT id<KICMatcher> KIC_equal(id expectedValue) {
    return [KICObjCMatcher equalMatcher:expectedValue];
}

