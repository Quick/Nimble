#import <Foundation/Foundation.h>

@class KICExpectation;
@class KICObjCBeCloseToMatcher;
@protocol KICMatcher;


#define KICK_EXPORT FOUNDATION_EXPORT

#ifdef KICK_DISABLE_SHORTHAND
#define KICK_SHORT(PROTO, ORIGINAL)
#else
#define KICK_SHORT(PROTO, ORIGINAL) FOUNDATION_STATIC_INLINE PROTO { return (ORIGINAL); }
#endif


KICK_EXPORT KICExpectation *KIC_expect(id(^actualBlock)(), const char *file, int line);

KICK_EXPORT id<KICMatcher> KIC_equal(id expectedValue);
KICK_SHORT(id<KICMatcher> equal(id expectedValue),
           KIC_equal(expectedValue));

KICK_EXPORT KICObjCBeCloseToMatcher *KIC_beCloseTo(NSNumber *expectedValue);
KICK_SHORT(KICObjCBeCloseToMatcher *beCloseTo(id expectedValue),
           KIC_beCloseTo(expectedValue));

KICK_EXPORT id<KICMatcher> KIC_beAnInstanceOf(Class expectedClass);
KICK_SHORT(id<KICMatcher> beAnInstanceOf(Class expectedClass),
           KIC_beAnInstanceOf(expectedClass));

KICK_EXPORT id<KICMatcher> KIC_beASubclassOf(Class expectedClass);
KICK_SHORT(id<KICMatcher> beASubclassOf(Class expectedClass),
           KIC_beASubclassOf(expectedClass));

KICK_EXPORT id<KICMatcher> KIC_beginWith(id itemElementOrSubstring);
KICK_SHORT(id<KICMatcher> beginWith(id itemElementOrSubstring),
           KIC_beginWith(itemElementOrSubstring));

KICK_EXPORT id<KICMatcher> KIC_beGreaterThan(NSNumber *expectedValue);
KICK_SHORT(id<KICMatcher> beGreaterThan(NSNumber *expectedValue),
           KIC_beGreaterThan(expectedValue));

KICK_EXPORT id<KICMatcher> KIC_beGreaterThanOrEqualTo(NSNumber *expectedValue);
KICK_SHORT(id<KICMatcher> beGreaterThanOrEqualTo(NSNumber *expectedValue),
           KIC_beGreaterThanOrEqualTo(expectedValue));

KICK_EXPORT id<KICMatcher> KIC_beIdenticalTo(id expectedInstance);
KICK_SHORT(id<KICMatcher> beIdenticalTo(id expectedInstance),
           KIC_beIdenticalTo(expectedInstance));

KICK_EXPORT id<KICMatcher> KIC_beLessThan(NSNumber *expectedValue);
KICK_SHORT(id<KICMatcher> beLessThan(NSNumber *expectedValue),
           KIC_beLessThan(expectedValue));

KICK_EXPORT id<KICMatcher> KIC_beLessThanOrEqualTo(NSNumber *expectedValue);
KICK_SHORT(id<KICMatcher> beLessThanOrEqualTo(NSNumber *expectedValue),
           KIC_beLessThanOrEqualTo(expectedValue));

KICK_EXPORT id<KICMatcher> KIC_beTruthy();
KICK_SHORT(id<KICMatcher> beTruthy(),
           KIC_beTruthy());

KICK_EXPORT id<KICMatcher> KIC_beFalsy();
KICK_SHORT(id<KICMatcher> beFalsy(),
           KIC_beFalsy());

KICK_EXPORT id<KICMatcher> KIC_beNil();
KICK_SHORT(id<KICMatcher> beNil(),
           KIC_beNil());

KICK_EXPORT id<KICMatcher> KIC_contain(id itemOrSubstring);
KICK_SHORT(id<KICMatcher> contain(id itemOrSubstring),
           KIC_contain(itemOrSubstring));

KICK_EXPORT id<KICMatcher> KIC_endWith(id itemElementOrSubstring);
KICK_SHORT(id<KICMatcher> endWith(id itemElementOrSubstring),
           KIC_endWith(itemElementOrSubstring));

#ifndef KICK_DISABLE_SHORTHAND
#define expect(...) KIC_expect(^id{ return (__VA_ARGS__); }, __FILE__, __LINE__)
#endif
