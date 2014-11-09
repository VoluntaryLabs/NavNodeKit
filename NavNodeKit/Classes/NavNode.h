//
//  NavNode.h
//  Bitmarket
//
//  Created by Steve Dekorte on 1/31/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FoundationCategoriesKit/FoundationCategoriesKit.h>
#import "NavMirror.h"
#import "NavSlot.h"

#define NavNodeSelectedNotification      @"NavNodeSelected"
#define NavNodeChangedNotification       @"NavNodeChanged"
#define NavNodeAddedChildNotification    @"NavNodeAddedChild"
#define NavNodeRemovedChildNotification  @"NavNodeRemovedChild"


@class NavNode;

@protocol NodeViewProtocol <NSObject>
- (void)setNode:(id)aNode;
- (BOOL)handlesNodeActions; // optional
@end


@interface NavNode : NSObject

@property (assign, nonatomic) NavNode *nodeParent;
@property (strong, nonatomic) NSMutableArray *children;
//@property (strong, nonatomic) NSMutableArray *actions;
@property (strong, nonatomic) NSView *nodeView;
@property (assign, nonatomic) Class nodeViewClass;

@property (assign, nonatomic) BOOL shouldSelectChildOnAdd;
@property (assign, nonatomic) BOOL shouldSortChildren;
@property (assign, nonatomic) BOOL shouldUseCountForNodeNote;
@property (assign, nonatomic) BOOL isDirty;

@property (strong, nonatomic) Class childClass;
@property (strong, nonatomic) NSString *sortChildrenKey;
@property (assign, nonatomic) BOOL sortAccending;
@property (assign, nonatomic) BOOL nodeForceDisplayChildren;
@property (assign, nonatomic) CGFloat nodeSuggestedWidth;
@property (assign, nonatomic) CGFloat nodeMinWidth;

@property (strong, nonatomic) NavMirror *navMirror;

@property (assign, nonatomic) BOOL doesRememberChildPath;
@property (strong, nonatomic) NSArray *rememberedChildTitlePath;



- (NSString *)nodeTitle;
- (NSString *)nodeSubtitle;
- (NSString *)nodeSubtitleDetailed;
- (NSString *)nodeNote;

- (NSArray *)nodePathArray;
- (NSArray *)pathOfClass:(Class)aClass;
- (NSUInteger)nodeDepth;

// children

- (BOOL)addChild:(id)aChild;
- (void)add; 

- (void)removeChild:(id)aChild;
- (void)sortChildren;
- (void)sortChildrenWithKey:(NSString *)aKey;

- (void)removeFromParent;

- (void)mergeWithChildren:(NSArray *)newChildren;

// inlining

@property (assign, nonatomic) BOOL shouldInlineChildren;
- (NSArray *)inlinedChildren;
- (BOOL)nodeParentInlines;
- (BOOL)nodeShouldIndent;
- (CGFloat)nodeSuggestedRowHeight;

- (NavNode *)childWithTitle:(NSString *)aTitle;
- (NSArray *)nodeTitlePath:(NSArray *)pathComponents;
- (NSArray *)nodeMaxTitlePath:(NSArray *)pathComponents;

- (NSImage *)nodeIconForState:(NSString *)aState;

- (BOOL)isRead;

// updating

@property (assign, nonatomic) BOOL deepRefreshes;
@property (assign, nonatomic) NSTimeInterval refreshInterval;
@property (nonatomic, retain) NSTimer *refreshTimer;

- (void)initCategory;

- (void)deepFetch;
- (void)fetch;
- (void)refresh;

- (void)postParentChanged;
- (void)postSelfChanged;
- (void)postParentChainChanged;
- (void)nodePostSelected;

- (id)firstChildWithKindOfClass:(Class)aClass;

// --- search ---

@property (assign, nonatomic) BOOL isSearching;
@property (strong, nonatomic) NSMutableArray *searchResults;

- (BOOL)canSearch;
- (void)search:(NSString *)aString;
- (BOOL)nodeMatchesSearch:(NSString *)aString;

// actions

- (NSArray *)actions;
- (NSArray *)modelActions; // deprecated
- (NSArray *)uiActions; // deprecated

- (NSString *)verifyActionMessage:(NSString *)aString; // deprecating

- (id)addChild;

// dirty

- (BOOL)isDirtyRecursive;
- (void)setCleanRecursive;

// chain

- (BOOL)onFirstRespondingInParentChainSend:(SEL)aSelector;
- (id)firstInParentChainOfClass:(Class)aClass;
- (BOOL)inParentChainHasClass:(Class)aClass;
- (NSArray *)childrenWith:(SEL)selector equalTo:anObject;

- (void)updatedSlot:(NavSlot *)aNavSlot;

- (void)delete;

// helper

/*
- (NSMutableArray *)nodeLeafs;
- (void)nodeFlattenChildren;
*/

@end
