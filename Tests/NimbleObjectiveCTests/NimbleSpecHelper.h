@import XCTest;
@import Nimble;
@import Foundation;
#if SWIFT_PACKAGE
@import NimbleSharedTestHelpers;
@import NimbleObjectiveC;
#else
#import "NimbleTests-Swift.h"
#endif

// Use this when you want to verify the failure message for when an expectation fails
#define expectFailureMessage(MSG, BLOCK) \
[NimbleHelper expectFailureMessage:(MSG) block:(BLOCK) file:@(__FILE__) line:__LINE__];

#define expectFailureMessages(MSGS, BLOCK) \
[NimbleHelper expectFailureMessages:(MSGS) block:(BLOCK) file:@(__FILE__) line:__LINE__];

#define expectFailureMessageRegex(REGEX, BLOCK) \
[NimbleHelper expectFailureMessageRegex:(REGEX) block:(BLOCK) file: @(__FILE__) line:__LINE__];

// Use this when you want to verify the failure message with the nil message postfixed
// to it: " (use beNil() to match nils)"
#define expectNilFailureMessage(MSG, BLOCK) \
[NimbleHelper expectFailureMessageForNil:(MSG) block:(BLOCK) file:@(__FILE__) line:__LINE__];
