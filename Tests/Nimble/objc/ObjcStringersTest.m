@import XCTest;
@import Nimble;

@interface ObjcStringersTest : XCTestCase

@end

@implementation ObjcStringersTest

- (void)testItCanStringifyArrays {
    NSArray *array = @[@1, @2, @3];
    NSString *result = NMBStringify(array);
    
    XCTAssert([result isEqualToString:@"(1, 2, 3)"], @"got <%@>, expected <(1, 2, 3)>", result);
}

- (void)testItRoundsLongDecimals {
    NSNumber *num = @291.123782163;
    NSString *result = NMBStringify(num);
    
    XCTAssert([result isEqualToString:@"291.1238"], @"got <%@>, expected <291.1238>", result);
}

@end
