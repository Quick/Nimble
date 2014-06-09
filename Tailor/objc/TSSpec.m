#import "TSSpec.h"
#import <Tailor/Tailor-Swift.h>
#import <objc/runtime.h>

@implementation TSSpec

+ (void)defineBehaviors {
}

+ (NSArray *)behaviorInvocationsWithMethodsIfNeeded {
    TSSpecContext *spec = [TSSpecContext behaviors:^{
        [self defineBehaviors];
    } file:@"" line:0];
    spec.root.name = NSStringFromClass([self class]);

    NSMutableArray *testInvocations = [NSMutableArray array];
    Method dummyMethod = class_getInstanceMethod([self class], @selector(TS_dummyMethod));
    const char *types = method_getTypeEncoding(dummyMethod);

    [spec eachLeafExampleWithRootNode:spec.root closure:^(ExampleNode *node) {
        NSMutableArray *fullName = [NSMutableArray arrayWithObject:[self santizeString:node.name]];
        for (ExampleNode *parent in node.parents) {
            [fullName insertObject:[self santizeString:parent.name]
                           atIndex:0];
        }

        IMP testMethod = imp_implementationWithBlock(^(id receiver){

        });

        [fullName removeObjectAtIndex:0];
        NSString *selectorString = [fullName componentsJoinedByString:@"_"];
        SEL selector = NSSelectorFromString(selectorString);
        class_addMethod(self, selector, testMethod, types);

        NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];
        NSInvocation *testInvocation = [NSInvocation invocationWithMethodSignature:signature];
        testInvocation.selector = selector;
        [testInvocations addObject:testInvocation];
    }];
    return testInvocations;
}

+ (NSArray *)testInvocations {
    if ([NSStringFromClass(self) isEqual:NSStringFromClass([TSSpec class])]) {
        return @[];
    }

    NSArray *behaviorTests = [self behaviorInvocationsWithMethodsIfNeeded];
    return [[super testInvocations] arrayByAddingObjectsFromArray:behaviorTests];
}

+ (NSString *)santizeString:(NSString *)string {
    NSMutableString *mutableString = [NSMutableString string];
    NSCharacterSet *characterSet = [NSCharacterSet alphanumericCharacterSet];
    for (NSUInteger i = 0; i < string.length; i++) {
        unichar chr = [string characterAtIndex:i];
        if ([characterSet characterIsMember:chr]) {
            [mutableString appendFormat:@"%c", chr];
        } else if (chr == ' ') {
            [mutableString appendString:@"_"];
        }
    }
    return [mutableString stringByReplacingOccurrencesOfString:@"__" withString:@"_"];
}

- (void)TS_dummyMethod {}

@end
