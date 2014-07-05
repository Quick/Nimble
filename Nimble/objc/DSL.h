#import <Foundation/Foundation.h>

@class KICExpectation;
@class KICObjCBeCloseToMatcher;
@class KICObjCRaiseExceptionMatcher;
@protocol KICMatcher;


#define Nimble_EXPORT FOUNDATION_EXPORT

#ifdef Nimble_DISABLE_SHORT_SYNTAX
#define Nimble_SHORT(PROTO, ORIGINAL)
#else
#define Nimble_SHORT(PROTO, ORIGINAL) FOUNDATION_STATIC_INLINE PROTO { return (ORIGINAL); }
#endif

Nimble_EXPORT KICExpectation *KIC_expect(id(^actualBlock)(), const char *file, int line);

Nimble_EXPORT id<KICMatcher> KIC_equal(id expectedValue);
Nimble_SHORT(id<KICMatcher> equal(id expectedValue),
           KIC_equal(expectedValue));

Nimble_EXPORT KICObjCBeCloseToMatcher *KIC_beCloseTo(NSNumber *expectedValue);
Nimble_SHORT(KICObjCBeCloseToMatcher *beCloseTo(id expectedValue),
           KIC_beCloseTo(expectedValue));

Nimble_EXPORT id<KICMatcher> KIC_beAnInstanceOf(Class expectedClass);
Nimble_SHORT(id<KICMatcher> beAnInstanceOf(Class expectedClass),
           KIC_beAnInstanceOf(expectedClass));

Nimble_EXPORT id<KICMatcher> KIC_beASubclassOf(Class expectedClass);
Nimble_SHORT(id<KICMatcher> beASubclassOf(Class expectedClass),
           KIC_beASubclassOf(expectedClass));

Nimble_EXPORT id<KICMatcher> KIC_beginWith(id itemElementOrSubstring);
Nimble_SHORT(id<KICMatcher> beginWith(id itemElementOrSubstring),
           KIC_beginWith(itemElementOrSubstring));

Nimble_EXPORT id<KICMatcher> KIC_beGreaterThan(NSNumber *expectedValue);
Nimble_SHORT(id<KICMatcher> beGreaterThan(NSNumber *expectedValue),
           KIC_beGreaterThan(expectedValue));

Nimble_EXPORT id<KICMatcher> KIC_beGreaterThanOrEqualTo(NSNumber *expectedValue);
Nimble_SHORT(id<KICMatcher> beGreaterThanOrEqualTo(NSNumber *expectedValue),
           KIC_beGreaterThanOrEqualTo(expectedValue));

Nimble_EXPORT id<KICMatcher> KIC_beIdenticalTo(id expectedInstance);
Nimble_SHORT(id<KICMatcher> beIdenticalTo(id expectedInstance),
           KIC_beIdenticalTo(expectedInstance));

Nimble_EXPORT id<KICMatcher> KIC_beLessThan(NSNumber *expectedValue);
Nimble_SHORT(id<KICMatcher> beLessThan(NSNumber *expectedValue),
           KIC_beLessThan(expectedValue));

Nimble_EXPORT id<KICMatcher> KIC_beLessThanOrEqualTo(NSNumber *expectedValue);
Nimble_SHORT(id<KICMatcher> beLessThanOrEqualTo(NSNumber *expectedValue),
           KIC_beLessThanOrEqualTo(expectedValue));

Nimble_EXPORT id<KICMatcher> KIC_beTruthy();
Nimble_SHORT(id<KICMatcher> beTruthy(),
           KIC_beTruthy());

Nimble_EXPORT id<KICMatcher> KIC_beFalsy();
Nimble_SHORT(id<KICMatcher> beFalsy(),
           KIC_beFalsy());

Nimble_EXPORT id<KICMatcher> KIC_beNil();
Nimble_SHORT(id<KICMatcher> beNil(),
           KIC_beNil());

Nimble_EXPORT id<KICMatcher> KIC_contain(id itemOrSubstring);
Nimble_SHORT(id<KICMatcher> contain(id itemOrSubstring),
           KIC_contain(itemOrSubstring));

Nimble_EXPORT id<KICMatcher> KIC_endWith(id itemElementOrSubstring);
Nimble_SHORT(id<KICMatcher> endWith(id itemElementOrSubstring),
           KIC_endWith(itemElementOrSubstring));

Nimble_EXPORT KICObjCRaiseExceptionMatcher *KIC_raiseException();
Nimble_SHORT(KICObjCRaiseExceptionMatcher *raiseException(),
           KIC_raiseException());

#ifndef Nimble_DISABLE_SHORT_SYNTAX
#define expect(EXPR) KIC_expect(^id{ return (EXPR); }, __FILE__, __LINE__)
#define expectBlock(EXPR) KIC_expect(^id{ (EXPR); return nil; }, __FILE__, __LINE__)
#endif
