//
//  NavDataSlot.h
//  NavNodeKit
//
//  Created by Steve Dekorte on 5/19/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//

#import "NavSlot.h"

@interface NavDataSlot : NavSlot

// isPersisted

- (void)setIsPersisted:(BOOL)aBool;
- (BOOL)isPersisted;

// isEditable

- (void)setIsEditable:(BOOL)aBool;
- (BOOL)isEditable;

// uneditedValue

- (void)setUneditedValue:(NSString *)aString;
- (NSString *)uneditedValue;

// nodeValue

- (id)nodeValue;
- (void)setNodeValue:(id)aValue;

@end
