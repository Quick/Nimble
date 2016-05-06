#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>

@interface NMBExceptionCapture : NSObject

- (id)initWithHandler:(void(^)(NSException *))handler finally:(void(^)())finally;
- (void)tryBlock:(void(^)())unsafeBlock NS_SWIFT_NAME(tryBlock(_:));

@end

typedef void(^NMBSourceCallbackBlock)(BOOL successful);
