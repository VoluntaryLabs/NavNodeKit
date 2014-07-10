//
//  NavSlot.h
//  NavNodeKit
//
//  Created by Steve Dekorte on 5/19/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NavMirror;

@protocol NavSlotViewProtocol <NSObject>
- (void)setSlot:(id)slot;
- (void)syncFromSlot;
- (void)syncToSlot;
@end

@interface NavSlot : NSObject

@property (assign, nonatomic) NavMirror *mirror;
@property (strong, nonatomic) NSMutableDictionary *attributes;
@property (strong, nonatomic) NSView <NavSlotViewProtocol> *slotView;

- (void)setAttributeObject:(id)newValue forKey:(NSString *)key;

// key

- (void)setName:(NSString *)aName;
- (NSString *)name;

// isVisible

- (void)setIsVisible:(BOOL)aBool;
- (BOOL)isVisible;

// visibleName

- (void)setVisibleName:(NSString *)aString;
- (NSString *)visibleName;

// viewClassName

- (void)setViewClassName:(NSString *)aString;
- (NSString *)viewClassName;
- (Class)viewClass;

// notifications

- (void)postChangeNotification;


@end
