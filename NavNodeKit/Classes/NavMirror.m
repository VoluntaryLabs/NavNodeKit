//
//  NavMirror.m
//  NavNodeKit
//
//  Created by Steve Dekorte on 5/19/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//

#import "NavMirror.h"
#import "NavSlot.h"

@implementation NavMirror

- (id)init
{
    self = [super init];
    
    self.slots = [NSMutableArray array];
    
    return self;
}

- (NSDictionary *)nodeDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    /*
    for (NavSlot *slot in self.slots)
    {
        // ...
    }
    */
    
    return dict;
}

- (void)setNodeDict:(NSDictionary *)dict
{
    
}


// slots

- (NSArray *)slotsOfKind:(Class)aClass
{
    NSMutableArray *dataSlots = [NSMutableArray array];
    
    for (NavSlot *slot in self.slots)
    {
        if ([slot isKindOfClass:aClass])
        {
            [dataSlots addObject:slot];
        }
    }
    
    return dataSlots;
}


- (NSArray *)dataSlots
{
    return [self slotsOfKind:NavDataSlot.class];
}

- (NSArray *)actionSlots
{
    return [self slotsOfKind:NavActionSlot.class];
}

// slot

- (NavSlot *)slotNamed:(NSString *)aName
{
    for (NavSlot *slot in self.slots)
    {
        if ([slot.name isEqualToString:aName])
        {
            return slot;
        }
    }
    
    return nil;
}

- (NavDataSlot *)newDataSlotWithName:(NSString *)aName
{
    NavDataSlot *slot = (NavDataSlot *)[self slotNamed:aName];
    
    if (!slot)
    {
        slot = [[NavDataSlot alloc] init];
        [slot setMirror:self];
        [slot setName:aName];
        [self.slots addObject:slot];
    }
    else if (![slot isKindOfClass:NavDataSlot.class])
    {
        [NSException raise:@"wrong slot type" format:nil];
    }
    
    return slot;
}

- (NavActionSlot *)newActionSlotWithName:(NSString *)aName
{
    NavActionSlot *slot = (NavActionSlot *)[self slotNamed:aName];
    
    if (!slot)
    {
        slot = [[NavActionSlot alloc] init];
        [slot setMirror:self];
        [slot setName:aName];
        [self.slots addObject:slot];
    }
    else if (![slot isKindOfClass:NavActionSlot.class])
    {
        [NSException raise:@"wrong slot type" format:nil];
    }
    
    return slot;
}

- (NavActionSlot *)actionSlotNamed:(NSString *)aName
{
    NavActionSlot *slot = (NavActionSlot *)[self slotNamed:aName];
    return slot;
}

- (NavDataSlot *)dataSlotNamed:(NSString *)aName
{
    NavDataSlot *slot = (NavDataSlot *)[self slotNamed:aName];
    return slot;
}

@end
