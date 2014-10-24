//
//  NavDictNode.h
//  NavNodeKit
//
//  Created by Steve Dekorte on 3/24/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//

#import "NavInfoNode.h"

//@class MKMsg;

@interface NavDictNode : NavInfoNode

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) JSONDB *db;
@property (strong, nonatomic) NSMutableArray *dictPropertyNames;
//@property (assign, nonatomic) NSInteger count;

+ (MKGroup *)rootInstance;

- (void)setDict:(NSDictionary *)dict;
- (NSDictionary *)dict;

- (void)setPropertiesDict:(NSDictionary *)dict;
- (NSDictionary *)propertiesDict;

- (void)addPropertyName:(NSString *)aName;


- (void)read;
- (void)write;

- (NSArray *)groupSubpaths;
- (NSArray *)groupNamePath;

- (void)updateCounts;
- (NSInteger)countOfLeafChildren;


@end
