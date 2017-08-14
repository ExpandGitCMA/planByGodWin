//
//  UIControl+DFCTimeInterval.m
//  planByGodWin
//
//  Created by DaFenQi on 17/2/16.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "UIControl+DFCTimeInterval.h"
#import <objc/runtime.h>

@implementation UIControl (DFCTimeInterval)

static const void *kTimeIntervalKey = "kTimeIntervalKey";
static const void *kAcceptTimeKey = "kAcceptTimeKey";


- (void)setDFC_timeInterval:(NSTimeInterval)DFC_timeInterval {
    objc_setAssociatedObject(self, kTimeIntervalKey, @(DFC_timeInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)DFC_timeInterval {
    id obj = objc_getAssociatedObject(self, kTimeIntervalKey);
    return [obj doubleValue];
}

- (void)setDFC_acceptEventTime:(NSTimeInterval)DFC_acceptEventTime {
    objc_setAssociatedObject(self, kAcceptTimeKey, @(DFC_acceptEventTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)DFC_acceptEventTime {
    id obj = objc_getAssociatedObject(self, kAcceptTimeKey);
    return [obj doubleValue];
}

+ (void)load {
    Method old = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
    Method new = class_getInstanceMethod(self, @selector(DFC_sendAction:to:forEvent:));
    method_exchangeImplementations(old, new);
}

- (void)DFC_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    if ([self isKindOfClass:[UIButton class]]) {
        if ([NSDate date].timeIntervalSince1970 - self.DFC_acceptEventTime < self.DFC_timeInterval) {
            return;
        }
        
        if (self.DFC_timeInterval > 0) {
            self.DFC_acceptEventTime = [NSDate date].timeIntervalSince1970;
        }
    }
    
    [self DFC_sendAction:action
                      to:target
                forEvent:event];
}

@end
