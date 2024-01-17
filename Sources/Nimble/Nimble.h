#import <Foundation/Foundation.h>

// When running below Xcode 15, TARGET_OS_VISION is not defined. Since the project has TREAT_WARNINGS_AS_ERROS enabled
// we need to workaround this warning.
#ifndef TARGET_OS_VISION
    #define TARGET_OS_VISION   0
#endif /* TARGET_OS_VISION */

#import <Nimble/NMBExceptionCapture.h>
#import <Nimble/NMBStringify.h>
#import <Nimble/DSL.h>

#if TARGET_OS_OSX || TARGET_OS_IOS || TARGET_OS_VISION
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
