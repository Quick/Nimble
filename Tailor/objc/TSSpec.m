#import "TSSpec.h"
#import <Tailor/Tailor-Swift.h>
#import <objc/runtime.h>

@implementation TSSpec

+ (NSArray *)testInvocations {
    if ([NSStringFromClass(self) isEqual:NSStringFromClass([TSSpec class])]) {
        return @[];
    }
    return [super testInvocations];
}

- (SpecBehavior *)spec {
    return nil;
}

- (void)testBehaviors {
    SpecBehavior *behavior = [self spec];
    XCTAssertNotNil(behavior, @"-[%@ spec] must define spec behavior", NSStringFromClass([self class]));
    if (behavior) {
        behavior.root.name = NSStringFromClass([self class]);
        [behavior verifyBehaviors];
    }
}

@end
