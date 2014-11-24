//
//  NavMirror.h
//  NavNodeKit
//
//  Created by Steve Dekorte on 5/19/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//
//
// use to replace MKGroup dictPropertyNames
// implement peristence

#import <Foundation/Foundation.h>
#import "NavSlot.h"
#import "NavDataSlot.h"
#import "NavActionSlot.h"

@class NavNode;

@interface NavMirror : NSObject

@property (assign, nonatomic) NavNode *node;
@property (strong, nonatomic) NSView *mirrorView;
@property (strong, nonatomic) NSMutableArray *slots;

// dict

/*
- (NSDictionary *)nodeDict;
- (void)setNodeDict:(NSDictionary *)dict;
*/

// slots

- (NSArray *)slotsOfKind:(Class)aClass;
- (NSArray *)dataSlots;
- (NSArray *)actionSlots;

- (NSArray *)activeActionSlotNames;

// slot

- (NavSlot *)slotNamed:(NSString *)aName;
- (NavActionSlot *)actionSlotNamed:(NSString *)aName;
- (NavDataSlot *)dataSlotNamed:(NSString *)aName;

- (NavDataSlot *)newDataSlotWithName:(NSString *)aName;
- (NavActionSlot *)newActionSlotWithName:(NSString *)aName;

- (BOOL)dataSlotsAreFilled;

// persistence

- (NSDictionary *)persistentDict;
- (void)setPersistentDict:(NSDictionary *)aDict;

@end
