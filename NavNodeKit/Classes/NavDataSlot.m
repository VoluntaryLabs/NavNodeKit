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
        
        //[self postValueChangeNotification];
        
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

- (BOOL)hasEmptyValue
{
    id v = self.value;
    
    if (v == nil)
    {
        return YES;
    }
    else if ([v isKindOfClass:NSString.class])
    {
        if ([v isEqualToString:@""])
        {
            return YES;
        }
        
        if ([v isEqualToString:self.uneditedValue])
        {
            return YES;
        }
    }
    else if ([v isEqual:self.uneditedValue])
    {
        return YES;
    }
    
    return NO;
}

- (NSNumber *)numberValue
{
    if ([self.value isKindOfClass:NSNumber.class])
    {
        return self.value;
    }

    if ([self.value isKindOfClass:NSString.class])
    {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *outNumber = [f numberFromString:self.value];
        return outNumber;
    }
    
    return nil;
}

- (NSString *)stringValue
{
    if ([self.value isKindOfClass:NSString.class])
    {
        return self.value;
    }
    
    //if ([self.value isKindOfClass:NSNumber.class])
    if ([self.value respondsToSelector:@selector(stringValue)])
    {
        return [self.value stringValue];
    }
    
    return nil;
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

/*
- (void)postValueChangeNotification
{
    [super postChangeNotification];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:self forKey:@"slot"];
    
    NSNotification *changeNotification = [NSNotification notificationWithName:@"changedDataSlotValue"
                                                                       object:self.mirror.node
                                                                     userInfo:userInfo];
    
    [NSNotificationCenter.defaultCenter postNotification:changeNotification];
}
*/

// lineCount

- (void)setLineCount:(NSNumber *)aNumber
{
    if (![aNumber isKindOfClass:NSNumber.class])
    {
        [NSException raise:@"dataSlot lineCount attribute must be an NSNumber" format:nil];
    }
    
    [self setAttributeObject:aNumber forKey:@"lineCount"];
}

- (NSNumber *)lineCount
{
    return [self.attributes objectForKey:@"lineCount"];
}

// format

- (void)setFormatterClassName:(NSString *)aString
{
    [self setAttributeObject:aString forKey:@"formatterClassName"];
}

- (NSString *)formatterClassName
{
    return [self.attributes objectForKey:@"formatterClassName"];
}

- (BOOL)canFormat
{
    if (self.formatterClassName)
    {
        Class formatterClass = NSClassFromString(self.formatterClassName);
        return formatterClass != nil;
    }
    
    return NO;
}

- (NSFormatter *)formatter
{
    // should we cache this?
    
    Class formatterClass = NSClassFromString(self.formatterClassName);
    
    if (!formatterClass)
    {
        return nil;
    }
    
    return [[formatterClass alloc] init];
}

// sync

- (void)setSyncsWhileEditing:(BOOL)aBool
{
    [self setAttributeObject:[NSNumber numberWithBool:aBool] forKey:@"syncsWhileEditing"];
}

- (BOOL)syncsWhileEditing
{
    return YES;
}

// valid

- (NSString *)validationMethodName
{
    return [NSString stringWithFormat:@"%@SlotIsValid", self.name];
}

- (BOOL)canValidate
{
    SEL selector = NSSelectorFromString(self.validationMethodName);
    id node = self.mirror.node;
    return selector && [node respondsToSelector:selector];
}

- (BOOL)isValid
{
    SEL selector = NSSelectorFromString(self.validationMethodName);
    
    id node = self.mirror.node;
    
    if ([node respondsToSelector:selector])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return (BOOL)[node performSelector:selector withObject:nil];
#pragma clang diagnostic pop        
    }
    
    return YES;
}


@end
