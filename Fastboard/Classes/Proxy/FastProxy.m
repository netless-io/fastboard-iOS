//
//  FastProxy.m
//  Fastboard
//
//  Created by xuyunshi on 2021/12/29.
//

#import "FastProxy.h"

@implementation FastProxy

- (instancetype)initWithTarget: (id _Nullable)target middleMan: (id _Nullable)middleMan {
    self.target = target;
    self.middleMan = middleMan;
    return self;
}

+ (instancetype)target: (id _Nullable)target middleMan: (id _Nullable)middleMan {
    return [[FastProxy alloc] initWithTarget:target middleMan:middleMan];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    id middleMan = self.middleMan;
    id target = self.target;
    return [middleMan respondsToSelector:aSelector] || [target respondsToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    id middleMan = self.middleMan;
    id target = self.target;
    NSMethodSignature *result = [middleMan methodSignatureForSelector:sel];
    if (!result) {
        result = [target methodSignatureForSelector:sel];
    }
    // Prevent NSProxy forwarding crash for respondsToSelector: when both refs are released.
    if (!result && sel == @selector(respondsToSelector:)) {
        result = [NSObject instanceMethodSignatureForSelector:@selector(respondsToSelector:)];
    }
    return result;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    id middleMan = self.middleMan;
    id target = self.target;
    
    // Should trigger respond to selector only once
    if (invocation.selector == @selector(respondsToSelector:)) {
        SEL selector = NULL;
        [invocation getArgument:&selector atIndex:2];
        BOOL result = [middleMan respondsToSelector:selector] || [target respondsToSelector:selector];
        [invocation setReturnValue:&result];
        return;
    }
    
    if ([middleMan respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:middleMan];
    }
    if ([target respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:target];
    }
}

@end
