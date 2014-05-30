//
//  NavActionSlot.m
//  NavNodeKit
//
//  Created by Steve Dekorte on 5/19/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//

#import "NavActionSlot.h"
#import "NavMirror.h"
#import "NavNode.h"

@implementation NavActionSlot

- (id)init
{
    self = [super init];

    [self setIsActive:YES];
    
    return self;
}

// isActive

- (void)setIsActive:(BOOL)aBool
{
    [self setAttributeObject:[NSNumber numberWithBool:aBool] forKey:@"isActive"];
}

- (BOOL)isActive
{
    NSNumber *boolNumber = [self.attributes objectForKey:@"isActive"];
    
    if (boolNumber)
    {
        return boolNumber.boolValue;
    }
    
    return NO;
}

- (void)sendAction
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.mirror.node performSelector:NSSelectorFromString(self.name)];
#pragma clang diagnostic pop
}

@end
