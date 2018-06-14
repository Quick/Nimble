#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>

@interface NMBExceptionCapture : NSObject

- (nonnull instancetype)initWithHandler:(void(^ _Nullable)(NSException * _Nonnull))handler finally:(void(^ _Nullable)(void))finally;

/**
 TEMP: unsafeBlock should be annotated with __attribute__((noescape)). This was removed
 as a workaround to Radar 40857699 https://openradar.appspot.com/radar?id=5595735974215680

 @param unsafeBlock Closure to run inside an @try block.
 */
- (void)tryBlock:(void(^ _Nonnull)(void))unsafeBlock NS_SWIFT_NAME(tryBlock(_:));

@end

typedef void(^NMBSourceCallbackBlock)(BOOL successful);
