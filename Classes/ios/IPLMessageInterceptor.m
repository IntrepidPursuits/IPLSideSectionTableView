//
//  IPLMessageInterceptor.m
//
//  Copyright (c) 2012 Intrepid Pursuits. All rights reserved.
//

#import "IPLMessageInterceptor.h"

@implementation IPLMessageInterceptor

@synthesize receiver;
@synthesize middleMan;

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([middleMan respondsToSelector:aSelector]) {
        return middleMan;
    } else if ([receiver respondsToSelector:aSelector]) {
        return receiver;
    } else {
        return [super forwardingTargetForSelector:aSelector];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([middleMan respondsToSelector:aSelector]) {
        return YES;
    } else if ([receiver respondsToSelector:aSelector]) {
        return YES;
    } else {
        return [super respondsToSelector:aSelector];
    }
}

@end
