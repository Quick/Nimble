#import <Foundation/Foundation.h>
#import <Kick/KICExceptionCapture.h>

FOUNDATION_EXPORT double KickVersionNumber;
FOUNDATION_EXPORT const unsigned char KickVersionString[];

#define expect(EXPR) [[KICExpectation alloc] initWithActualBlock:^id{ return (EXPR); } negative:false file:[[NSString alloc] initWithFormat:@"%s", __FILE__] line:__LINE__]
#define equal(VALUE) [KICDSLMatcher equalMatcher:(VALUE)]
