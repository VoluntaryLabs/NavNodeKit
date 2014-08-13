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

// valueSuffix

- (void)setValueSuffix:(NSString *)aString;
- (NSString *)valueSuffix;

// nodeValue

- (id)value;
- (void)setValue:(id)aValue;
- (BOOL)hasEmptyValue;

- (NSNumber *)numberValue;
- (NSString *)stringValue;

// lineCount

- (void)setLineCount:(NSNumber *)aNumber;
- (NSNumber *)lineCount;


// format

- (void)setFormatterClassName:(NSString *)aString;
- (BOOL)canFormat;
- (NSString *)formatterClassName;
- (NSFormatter *)formatter;

// sync

- (void)setSyncsWhileEditing:(BOOL)aBool;
- (BOOL)syncsWhileEditing;

// valid

- (BOOL)canValidate;
- (BOOL)isValid;

@end
