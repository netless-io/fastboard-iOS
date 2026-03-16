#import <XCTest/XCTest.h>
#import "FastProxy.h"

@interface FastProxyTests : XCTestCase
@end

@implementation FastProxyTests

- (void)testRespondsToSelectorReturnsNOWhenBothTargetsAreNil {
    FastProxy *proxy = [FastProxy target:nil middleMan:nil];
    SEL selector = NSSelectorFromString(@"logger:");
    XCTAssertFalse([proxy respondsToSelector:selector]);
}

@end
