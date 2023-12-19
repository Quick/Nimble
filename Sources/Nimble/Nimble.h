#import <Foundation/Foundation.h>
#import <Nimble/NMBExceptionCapture.h>
#import <Nimble/NMBStringify.h>
#import <Nimble/DSL.h>

#if TARGET_OS_OSX || TARGET_OS_IOS
    #import <CwlMachBadInstructionHandler.h>
    #import <CwlCatchException.h>
#endif

FOUNDATION_EXPORT double NimbleVersionNumber;
FOUNDATION_EXPORT const unsigned char NimbleVersionString[];
