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

- (void)defineBehaviors {
}

- (void)testBehaviors {
    TSSpecContext *spec = [TSSpecContext behaviors:^{
        [self defineBehaviors];
    } file:@"" line:0];
    spec.root.name = NSStringFromClass([self class]);
    [spec verifyBehaviors];
}

@end
