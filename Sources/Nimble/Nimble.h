#import <Foundation/Foundation.h>
#import <Nimble/NMBExceptionCapture.h>
#import <Nimble/NMBStringify.h>
#import <Nimble/DSL.h>

#if TARGET_OS_OSX || TARGET_OS_IOS
#if COCOAPODS
    #import <CwlMachBadInstructionHandler/CwlMachBadInstructionHandler.h>
    #import <CwlCatchExceptionSupport/CwlCatchException.h>
#else
    #import "CwlMachBadInstructionHandler.h"
    #import "CwlCatchException.h"
#endif
#endif

FOUNDATION_EXPORT double NimbleVersionNumber;
FOUNDATION_EXPORT const unsigned char NimbleVersionString[];
