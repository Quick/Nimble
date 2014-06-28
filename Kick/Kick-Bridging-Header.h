// #import "KICExceptionCapture.h"
// BUG: we have to inline this import because Swift can't import through a bridging header inside a framework
#import <Foundation/Foundation.h>

@interface KICExceptionCapture : NSObject

- (id)initWithHandler:(void(^)(NSException *))handler finally:(void(^)())finally;
- (void)tryBlock:(void(^)())unsafeBlock;

@end