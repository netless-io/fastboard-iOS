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

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    id result = [self.target methodSignatureForSelector:sel];
    if (!result) {
        result = [self.middleMan methodSignatureForSelector:sel];
    }
    return result;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if ([self.middleMan respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:self.middleMan];
    }
    if ([self.target respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:self.target];
    }
}


@end
