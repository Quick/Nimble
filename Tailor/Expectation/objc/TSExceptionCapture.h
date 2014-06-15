#import <Foundation/Foundation.h>

@interface TSExceptionCapture : NSObject

- (id)initWithHandler:(void(^)(NSException *))handler finally:(void(^)())finally;
- (void)tryBlock:(void(^)())unsafeBlock;

@end