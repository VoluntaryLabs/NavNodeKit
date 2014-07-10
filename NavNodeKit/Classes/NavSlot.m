//
//  NavSlot.m
//  NavNodeKit
//
//  Created by Steve Dekorte on 5/19/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//

#import "NavNode.h"
#import "NavSlot.h"
#import "NavMirror.h"

@implementation NavSlot

- (id)init
{
    self = [super init];
    
    self.attributes = [NSMutableDictionary dictionary];

    [self setIsVisible:YES];
    
    return self;
}

// key

- (void)setName:(NSString *)aName
{
    [self setAttributeObject:aName forKey:@"name"];
}

- (NSString *)name
{
    return [self.attributes objectForKey:@"name"];
}

- (void)postChangeNotification
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:self forKey:@"slot"];
    
    NSNotification *changeNotification = [NSNotification notificationWithName:@"changedSlotAttribute"
                                         object:self.mirror.node
                                       userInfo:userInfo];
    
    [[NSNotificationCenter defaultCenter] postNotification:changeNotification];
}

- (void)setAttributeObject:(id)newValue forKey:(NSString *)key
{
    id oldValue = [self.attributes objectForKey:key];
    
    if (![oldValue isEqual:newValue])
    {
        [self.attributes setObject:newValue forKey:key];
        [self postChangeNotification];
        [self.mirror.node postSelfChanged];
    }
}

// isVisible

- (void)setIsVisible:(BOOL)aBool
{
    [self setAttributeObject:[NSNumber numberWithBool:aBool] forKey:@"isVisible"];
}

- (BOOL)isVisible
{
    NSNumber *boolNumber = [self.attributes objectForKey:@"isVisible"];
    
    if (boolNumber)
    {
        return boolNumber.boolValue;
    }
    
    return NO;
}

// visibleName

- (void)setVisibleName:(NSString *)aString
{
    [self setAttributeObject:aString forKey:@"visibleName"];
}

- (NSString *)visibleName
{
    return [self.attributes objectForKey:@"visibleName"];
}

// viewClassName

- (void)setViewClassName:(NSString *)aString
{
    [self setAttributeObject:aString forKey:@"viewClassName"];
}

- (NSString *)viewClassName
{
    return [self.attributes objectForKey:@"viewClassName"];
}

- (Class)viewClass
{
    Class viewClass = NSClassFromString(self.viewClassName);
    
    /*
     if (!viewClass && self.type)
     {
     NSString *typeViewClass = [NSString stringWithFormat:@"%@View", self.type];
     viewClass = NSClassFromString(typeViewClass);
     }
     */
    
    if (!viewClass)
    {
        NSString *viewClassName = [self.className stringByAppendingString:@"View"];
        viewClass = NSClassFromString(viewClassName);
    }
    
    return viewClass;
}

- (NSView *)slotView
{
    if (!_slotView)
    {
        Class viewClass = self.viewClass;
        
        if (viewClass)
        {
            _slotView = [[viewClass alloc] initWithFrame:NSMakeRect(0, 0, 300, 30)];
            //[_slotView setNavSlot:self];
            [_slotView setSlot:self];
        }
    }
    
    return _slotView;
    
}

@end
