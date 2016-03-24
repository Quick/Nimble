#import <XCTest/XCTest.h>
#import <Nimble/Nimble-Swift.h>

SWIFT_CLASS("_TtC6Nimble22CurrentTestCaseTracker")
@interface CurrentTestCaseTracker : NSObject <XCTestObservation>
+ (CurrentTestCaseTracker *)sharedInstance;
@end

@interface CurrentTestCaseTracker (Register) @end

@implementation CurrentTestCaseTracker (Register)

+ (void)load {
    CurrentTestCaseTracker *tracker = [CurrentTestCaseTracker sharedInstance];
    // XCode 7.3 introduced a bug where early registration of a test observer prevented
    // default XCTest test observer from being registered. That caused no longs being printed
    // onto console, which in result broke several tools that relied on this.
    // In order to go around the issue we're deferring registration to allow default
    // test observer to register first.
    dispatch_async(dispatch_get_main_queue(), ^{
        [[XCTestObservationCenter sharedTestObservationCenter] addTestObserver:tracker];
    });
}

@end
