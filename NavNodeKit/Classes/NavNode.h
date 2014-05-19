//
//  NavNode.h
//  Bitmarket
//
//  Created by Steve Dekorte on 1/31/14.
//  Copyright (c) 2014 Bitmarkets.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FoundationCategoriesKit/FoundationCategoriesKit.h>

@class NavNode;

@protocol NodeViewProtocol <NSObject>
- (void)setNode:(id)aNode;
@end


@interface NavNode : NSObject

@property (assign, nonatomic) NavNode *nodeParent;
@property (strong, nonatomic) NSMutableArray *children;
//@property (strong, nonatomic) NSMutableArray *actions;
@property (strong, nonatomic) NSView *nodeView;
@property (assign, nonatomic) BOOL shouldSelectChildOnAdd;
@property (assign, nonatomic) BOOL shouldSortChildren;
@property (assign, nonatomic) BOOL shouldUseCountForNodeNote;
@property (assign, nonatomic) BOOL isDirty;

@property (strong, nonatomic) Class childClass;
@property (strong, nonatomic) NSString *sortChildrenKey;
@property (assign, nonatomic) BOOL sortAccending;
@property (assign, nonatomic) BOOL nodeForceDisplayChildren;


- (NSString *)nodeTitle;
- (NSString *)nodeSubtitle;
- (NSString *)nodeNote;

- (NSArray *)nodePathArray;
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

- (NSImage *)nodeIconForState:(NSString *)aState;

- (BOOL)isRead;

- (CGFloat)nodeSuggestedWidth;

// updating

@property (assign, nonatomic) BOOL deepRefreshes;
@property (assign, nonatomic) NSTimeInterval refreshInterval;
@property (nonatomic, retain) NSTimer *refreshTimer;

- (void)deepFetch;
- (void)fetch;
- (void)refresh;

- (void)postParentChanged;
- (void)postSelfChanged;
- (void)postParentChainChanged;

- (id)childWithAddress:(NSString *)address; // hack - move to node subclass

// --- search ---

@property (assign, nonatomic) BOOL isSearching;
@property (strong, nonatomic) NSMutableArray *searchResults;

- (BOOL)canSearch;
- (void)search:(NSString *)aString;
- (BOOL)nodeMatchesSearch:(NSString *)aString;

// actions

- (NSArray *)actions;
- (NSArray *)modelActions;
- (NSArray *)uiActions;

- (NSString *)verifyActionMessage:(NSString *)aString;

- (id)addChild;

// dirty

- (BOOL)isDirtyRecursive;
- (void)setCleanRecursive;

// chain

- (BOOL)onFirstRespondingInParentChainSend:(SEL)aSelector;
- (id)firstInParentChainOfClass:(Class)aClass;
- (BOOL)inParentChainHasClass:(Class)aClass;
- (NSArray *)childrenWith:(SEL)selector equalTo:anObject;

@end
