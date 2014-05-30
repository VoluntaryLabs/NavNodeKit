//
//  NavDataSlot.m
//  NavNodeKit
//
//  Created by Steve Dekorte on 5/19/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//

#import "NavDataSlot.h"
#import "NavNode.h"
#import "NavMirror.h"

@implementation NavDataSlot

// isPersisted

- (void)setIsPersisted:(BOOL)aBool
{
    [self setAttributeObject:[NSNumber numberWithBool:aBool] forKey:@"isPersisted"];
}

- (BOOL)isPersisted
{
    NSNumber *boolNumber = [self.attributes objectForKey:@"isPersisted"];
    
    if (boolNumber)
    {
        return boolNumber.boolValue;
    }
    
    return NO;
}

// isEditable

- (void)setIsEditable:(BOOL)aBool
{
    [self setAttributeObject:[NSNumber numberWithBool:aBool] forKey:@"isEditable"];
}

- (BOOL)isEditable
{
    NSNumber *boolNumber = [self.attributes objectForKey:@"isEditable"];
    
    if (boolNumber)
    {
        return boolNumber.boolValue;
    }
    
    return NO;
}

// uneditedValue

- (void)setUneditedValue:(NSString *)aString
{
    [self setAttributeObject:aString forKey:@"uneditedValue"];
}

- (NSString *)uneditedValue
{
    return [self.attributes objectForKey:@"uneditedValue"];
}

// valueSuffix

- (void)setValueSuffix:(NSString *)aString
{
    [self setAttributeObject:aString forKey:@"valueSuffix"];
}


- (NSString *)valueSuffix
{
    return [self.attributes objectForKey:@"valueSuffix"];
}

// nodeValue

- (id)value
{
    SEL getterSelector = NSSelectorFromString(self.name);
    NavNode *node = self.mirror.node;
    
    if ([node respondsToSelector:getterSelector])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [node performSelector:getterSelector];
#pragma clang diagnostic pop
    }
    else
    {
        [NSException raise:@"no such node getter" format:nil];
    }
    
    return nil;
}

- (void)setValue:(id)aValue
{
    NSString *setterName = [NSString stringWithFormat:@"set%@:",
                            self.name.capitalisedFirstCharacterString];
    
    SEL setterSelector = NSSelectorFromString(setterName);
    NavNode *node = self.mirror.node;
    
    if ([node respondsToSelector:setterSelector])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [node performSelector:setterSelector withObject:aValue];
#pragma clang diagnostic pop
        
        if ([node respondsToSelector:@selector(updatedSlot:)])
        {
            [node updatedSlot:self];
        }
    }
    else
    {
        [NSException raise:@"no such node setter" format:nil];
    }
}

// type

- (void)setType:(NSString *)aString
{
    [self setAttributeObject:aString forKey:@"type"];
}

- (NSString *)type
{
    return [self.attributes objectForKey:@"type"];
}

@end
