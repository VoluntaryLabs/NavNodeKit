//
//  NavNode.m
//  Bitmarket
//
//  Created by Steve Dekorte on 1/31/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//

#import "NavNode.h"
#import <FoundationCategoriesKit/FoundationCategoriesKit.h>

@implementation NavNode

- (id)init
{
    self = [super init];
    
    self.children = [NSMutableArray array];
    self.nodeSortAccending = @YES;
    self.nodeShouldSortChildren = @YES;
    self.nodeSuggestedWidth = @300;
    
    [self initCategory];
    
    return self;
}

- (void)initCategory
{
}

// titles

- (NSString *)nodeNote
{
    if (self.nodeShouldUseCountForNodeNote.boolValue && self.children.count)
    {
        return [NSString stringWithFormat:@"%i", (int)self.children.count];
    }
    
    return nil;
}

- (void)deepFetch
{
    [self fetch];
    
    for (id child in self.children)
    {
        if ([child respondsToSelector:@selector(fetch)])
        {
            //NSLog(@"child %@", child);
            [child deepFetch];
        }
    }
}

- (void)fetch
{
    
}

- (void)refresh
{
    if (self.deepRefreshes)
    {
        [self deepFetch];
    }
    else
    {
        [self fetch];
    }
}

- (NSArray *)nodePathArray
{
    NSMutableArray *nodePathArray = [NSMutableArray array];
    NavNode *node = self;
    
    while (node)
    {
        [nodePathArray addObject:node];
        node = node.nodeParent;
    }
    
    [nodePathArray reverse];
    
    return nodePathArray;
}

- (NSArray *)pathOfClass:(Class)aClass
{
    // returns all nodes of a given class in the path
    
    NSMutableArray *path = [NSMutableArray array];
    
    for (NavNode *node in self.nodePathArray)
    {
        if ([node isKindOfClass:aClass])
        {
            [path addObject:node];
        }
    }
    
    return path;
}


- (NSUInteger)nodeDepth
{
    NSUInteger depth = 0;
    NavNode *nodeParent = self.nodeParent;
    
    while (nodeParent)
    {
        depth ++;
        nodeParent = nodeParent.nodeParent;
    }
    
    return depth;
}


- (void)setChildren:(NSMutableArray *)children
{
    _children = children;

    for (NavNode *child in self.children)
    {
        [child setNodeParent:self];
    }
}

- (id)addChild
{
    if (self.nodeChildClass)
    {
        id child = [[self.nodeChildClass alloc] init];
        [self addChild:child];
        [self postParentChanged];
        return child;
    }
    
    return nil;
}

- (void)add
{
    [self addChild];
}

- (BOOL)justAddChild:(id)aChild
{
    if (![self.children containsObject:aChild])
    {
        [aChild setNodeParent:self];
        [self.children addObject:aChild];
        return YES;
    }
    
    return NO;
}

- (BOOL)addChild:(id)aChild
{
    if (![self.children containsObject:aChild])
    {
        [aChild setNodeParent:self];
        [self.children addObject:aChild];
        [self sortChildren];
       
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:aChild forKey:@"child"];
        
        NSNotification *note = [NSNotification notificationWithName:NavNodeAddedChildNotification
                                                             object:self
                                                           userInfo:info];
        
        [NSNotificationCenter.defaultCenter postNotification:note];
        self.nodeIsDirty = @YES;
        return YES;
    }
    else
    {
        //[self sortChildren];
        return NO;
    }
}

- (void)removeChild:(id)aChild
{
    NSInteger i = [self.children indexOfObject:aChild];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setObject:aChild forKey:@"child"];
    [info setObject:[NSNumber numberWithUnsignedInteger:i] forKey:@"index"];
    
    NSInteger nextIndex = i + 1;
    if (nextIndex < self.children.count)
    {
        id nextObject = [self.children objectAtIndex:nextIndex];
        [info setObject:nextObject forKey:@"nextObjectHint"];
    }
    
    [self.children removeObject:aChild];
    self.nodeIsDirty = @YES;

    NSNotification *note = [NSNotification notificationWithName:NavNodeRemovedChildNotification
                                                         object:self
                                                       userInfo:info];
    
    [NSNotificationCenter.defaultCenter postNotification:note];
}

- (void)mergeWithChildren:(NSArray *)newChildren
{
    [self.children mergeWith:newChildren];
    [self setChildren:self.children];
}

- (SEL)sortSelector
{
    SEL sortSelector = @selector(caseInsensitiveCompare:);
    
    if (self.children.count && ![self.children.firstObject respondsToSelector:sortSelector])
    {
        sortSelector = @selector(compare:);
    }
    
    return sortSelector;
}

- (void)sortChildren
{
    if (self.nodeShouldSortChildren.boolValue && self.children.count)
    {
        NSString *key = self.nodeSortChildrenKey ? self.nodeSortChildrenKey : @"nodeTitle";
        
        NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:key
                                                                 ascending:self.nodeSortAccending.boolValue
                                                                  selector:self.sortSelector];

        [self.children sortUsingDescriptors:[NSArray arrayWithObject:sorter]];
    }
}

- (void)sortChildrenWithKey:(NSString *)aKey
{
    if (self.nodeShouldSortChildren.boolValue)
    {
        NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:aKey
                                                                 ascending:self.nodeSortAccending.boolValue
                                                                  selector:@selector(compare:)];
        [self.children sortUsingDescriptors:[NSArray arrayWithObject:sorter]];
    }
}

- (void)removeFromParent
{
    [self.nodeParent removeChild:self];
}

- (void)setNodeParent:(NavNode *)nodeParent
{
    NavNode *oldNodeParent = _nodeParent;
    _nodeParent = nodeParent;
    
    if (![oldNodeParent isEqualTo:_nodeParent])
    {
        [self postParentChanged];
    }
    
    if (nodeParent == nil)
    {
        [self stopRefreshTimer];
    }
    else if (self.refreshInterval > 0)
    {
        [self startRefreshTimerIfNeeded];
    }
}

- (void)dealloc
{
    [self stopRefreshTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setRefreshInterval:(NSTimeInterval)refreshInterval
{
    if (_refreshInterval != refreshInterval)
    {
        _refreshInterval = refreshInterval;
        
        [self stopRefreshTimer];
        [self startRefreshTimerIfNeeded];
    }
}

- (void)startRefreshTimerIfNeeded
{
    if (!self.refreshTimer && self.refreshInterval > 0)
    {
        [self stopRefreshTimer];
        
        self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:self.refreshInterval
                                                             target:self
                                                           selector:@selector(refreshTimerEvent)
                                                           userInfo:nil
                                                            repeats:YES];
    }
}

- (void)refreshTimerEvent
{
    //NSLog(@"--- %@ refreshTimerEvent ---", NSStringFromClass(self.class));
    
    @try
    {
        [self refresh];
    }
    @catch (NSException * e)
    {
        NSLog(@"refresh exception %@", e);
        
        NSAlert *msgBox = [[NSAlert alloc] init];
        [msgBox setMessageText:e.name];
        [msgBox addButtonWithTitle: @"OK"];
        [msgBox addButtonWithTitle: @"Exit"];
        
        [msgBox beginSheetModalForWindow:NSApplication.sharedApplication.mainWindow
                           modalDelegate:self
                          didEndSelector:@selector(refreshAlertDidEnd:returnCode:contextInfo:)
                             contextInfo:nil];
    }
}

- (void)refreshAlertDidEnd:(NSAlert *)alert
            returnCode:(NSInteger)returnCode
           contextInfo:(void *)contextInfo
{
    if (returnCode == 1001)
    {
        [NSApplication.sharedApplication terminate:self];
    }
}


- (void)stopRefreshTimer
{
    if (self.refreshTimer)
    {
        [self.refreshTimer invalidate];
        self.refreshTimer = nil;
    }
}

- (NavNode *)childWithTitle:(NSString *)aTitle
{
    for (NavNode *child in self.children)
    {
        if ([[child nodeTitle] isEqualToString:aTitle])
        {
            return child;
        }
    }
    
    return nil;
}

- (NSArray *)nodeTitlePath
{
    return [self.nodePathArray map:@selector(nodeTitle)];
}

- (NSArray *)nodeMaxTitlePath:(NSArray *)pathComponents
{
    NavNode *node = self;
    NSMutableArray *nodes = [NSMutableArray array];
    
    for (NSString *title in pathComponents)
    {
        node = [node childWithTitle:title];
        
        if (node == nil)
        {
            return nodes;
        }
        
        [nodes addObject:node];
    }
    
    return nodes;
}

- (NSArray *)nodeTitlePath:(NSArray *)pathComponents
{
    NavNode *node = self;
    NSMutableArray *nodes = [NSMutableArray array];
    
    for (NSString *title in pathComponents)
    {
        node = [node childWithTitle:title];
        
        if (node == nil)
        {
            return nil;
        }
        
        [nodes addObject:node];
    }
    
    return nodes;
}

- (NSString *)nodeTitle
{
    NSString *name = NSStringFromClass([self class]);
    NSString *prefix = @"BM";
    
    if ([name hasPrefix:prefix])
    {
        name = [name substringFromIndex:[prefix length]];
        name = [name lowercaseString];
    }
    
    return name;
}

- (NSString *)nodeSubtitle
{
    return nil;
}

- (NSString *)nodeSubtitleDetailed
{
    return nil;
}


// --- icon ----------------------

- (NSImage *)nodeIconForState:(NSString *)aState
{
    NSString *className = NSStringFromClass([self class]);
    NSString *iconName = [NSString stringWithFormat:@"%@_%@", className, aState];
    //NSLog(@"iconName: %@", iconName);
    //iconName = nil;
    return [NSImage imageNamed:iconName];
}

- (NSImage *)nodeActiveIcon
{
    return [self nodeIconForState:@"active"];
}

- (NSImage *)nodeInactiveIcon
{
    return [self nodeIconForState:@"inactive"];
}

- (NSImage *)nodeDisabledIcon
{
    return [self nodeIconForState:@"disabled"];
}

- (void)postSelfChanged
{
    [self performSelector:@selector(justPostSelfChanged) withObject:nil afterDelay:0.0];
}

- (void)postParentChanged
{
    [self.nodeParent postSelfChanged];
}

- (void)postParentChainChanged
{
    [self postSelfChanged];
    [self.nodeParent postParentChainChanged];
}

- (void)justPostSelfChanged
{
    [NSNotificationCenter.defaultCenter
        postNotificationName:NavNodeChangedNotification object:self];
}

// --- remembered child path ---

- (void)nodePostSelected
{
    [NSNotificationCenter.defaultCenter postNotificationName:NavNodeSelectedNotification object:self];
}

- (void)setDoesRememberChildPath:(NSNumber *)aBoolNumber
{
    _nodeDoesRememberChildPath = aBoolNumber;
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(nodeUpdateRememberedPath:)
                                               name:NavNodeSelectedNotification
                                             object:nil];
    [self nodeReadRememberedChildPath];
}


- (NSString *)nodeRememberedPathKey
{
    NSString *path = [self.nodeTitlePath componentsJoinedByString:@"/"];
    return [NSString stringWithFormat:@"NavNodeRememberedPath-%@", path];
}

- (void)nodeReadRememberedChildPath
{
    self.nodeRememberedChildTitlePath = [NSUserDefaults.standardUserDefaults objectForKey:self.nodeRememberedPathKey];
    //[self nodePostSelected];
}

- (void)nodeWriteRememberedChildPath
{
    [[NSUserDefaults standardUserDefaults] setObject:self.nodeRememberedChildTitlePath forKey:self.nodeRememberedPathKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //[self nodePostSelected];
}

- (void)nodeUpdateRememberedPath:(NSNotification *)aNote
{
    NavNode *node = aNote.object;
    
    //NSLog(@"node.nodePathArray = %@", node.nodePathArray);
    //NSLog(@"self.nodePathArray = %@", self.nodePathArray);
    
    if ([node.nodeTitlePath beginsWithArray:self.nodeTitlePath] &&
        ![node.nodeTitlePath isEqualToArray:self.nodeTitlePath])
    {
        self.nodeRememberedChildTitlePath = node.nodeTitlePath;
        [self nodeWriteRememberedChildPath];

    }
}

// ---------------------------------------

- (NSView *)nodeView
{
    if (!_nodeView)
    {
        id viewClass = self.nodeViewClass;
        
        if (!viewClass)
        {
            viewClass = self.class.firstViewClass;
        }
        
        if (viewClass)
        {
            _nodeView = [(NSView *)[viewClass alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
            
            if ([_nodeView respondsToSelector:@selector(setNode:)])
            {
                [_nodeView performSelector:@selector(setNode:) withObject:self];
            }
        }
    }
    
    return _nodeView;
}

- (BOOL)canSearch
{
    return NO;
}

- (void)search:(NSString *)aString
{
    NSArray *parts = [aString componentsSeparatedByString:@" "];
    
    _searchResults = [NSMutableArray array];
    
    for (NavNode *child in self.children)
    {
        NSInteger remaining = parts.count;
        
        for (NSString *part in parts)
        {
            if (part.length == 0)
            {
                remaining --;
            }
            else if ([child nodeMatchesSearch:part])
            {
                remaining --;
            }
        }
        
        if (remaining == 0)
        {
            [_searchResults addObject:child];
        }
    }
}

- (BOOL)nodeMatchesSearch:(NSString *)aString
{
    if (self.nodeTitle && [self.nodeTitle containsCaseInsensitiveString:aString])
    {
        return YES;
    }
    
    if (self.nodeSubtitle && [self.nodeSubtitle containsCaseInsensitiveString:aString])
    {
        return YES;
    }
    
    return NO;
}

- (id)firstChildWithKindOfClass:(Class)aClass
{
    for (id child in self.children)
    {
        if ([child isKindOfClass:aClass])
        {
            return child;
        }
    }
    
    return nil;
}

// ----------------------

- (NSArray *)inlinedChildren
{
    NSMutableArray *inlinedChildren = [NSMutableArray array];
    
    for (NavNode *child in self.children)
    {
        [inlinedChildren addObject:child];
        [inlinedChildren addObjectsFromArray:child.children];
    }
    
    return inlinedChildren;
}

- (BOOL)nodeParentInlines
{
    if (self.nodeParent)
    {
        return self.nodeParent.shouldInlineChildren;
    }
    
    return NO;
}

- (BOOL)nodeShouldIndent
{
    NavNode *p = self.nodeParent;
    
    if (p)
    {
        p = p.nodeParent;
        
        if (p)
        {
            return p.shouldInlineChildren;
        }
    }
    
    return NO;
}

- (CGFloat)nodeSuggestedRowHeight
{
    if (self.shouldInlineChildren)
    {
        return 30;
    }
    
    return 60;
}

- (BOOL)isRead
{
    return YES;
}

// actions

- (NSArray *)actions
{
    NSMutableArray *actions = [NSMutableArray array];
    
    [actions addObjectsFromArray:self.modelActions]; // deprecated
    [actions addObjectsFromArray:self.uiActions]; // deprecated
    
    if (_navMirror)
    {
        [actions addObjectsFromArray:_navMirror.activeActionSlotNames];
    }
    
    return actions;
}

- (NSArray *)modelActions // deprecated
{
    return [NSMutableArray array];
}

- (NSArray *)uiActions // deprecated
{
    return [NSMutableArray array];
}

- (NSString *)verifyActionMessage:(NSString *)aString
{
    if (_navMirror)
    {
        NavActionSlot *actionSlot = [_navMirror actionSlotNamed:aString];
        
        if (actionSlot && actionSlot.verifyMessage)
        {
            return actionSlot.verifyMessage;
        }
    }
    
    return nil;
}

// default delete

- (void)delete
{
    [self removeFromParent];
    [self postSelfChanged];
    [self postParentChanged];
}

// dirty

- (void)notifyChainDirty
{
    if (self.nodeParent)
    {
        [self.nodeParent notifyChainDirty];
    }
}

/*
- (void)setIsDirty:(BOOL)aBool
{
    if (self.nodeIsDirty.boolValue != aBool)
    {
        self.nodeIsDirty = [NSNumber numberWithBool:aBool];
        
        if (aBool)
        {
            [self notifyChainDirty];
        }
    }
}
*/

- (BOOL)isDirtyRecursive
{
    if (self.nodeIsDirty.boolValue)
    {
        return YES;
    }
    
    for (NavNode *child in self.children)
    {
        if (child.isDirtyRecursive)
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)setCleanRecursive
{
    self.nodeIsDirty = @NO;
    
    for (NavNode *child in self.children)
    {
        [child setCleanRecursive];
    }
}

- (BOOL)onFirstRespondingInParentChainSend:(SEL)aSelector
{
    if (self.nodeParent)
    {
        if ([self.nodeParent respondsToSelector:aSelector])
        {
            [self.nodeParent performSelector:aSelector withObject:nil afterDelay:0.0];
            return YES;
        }
        
        return [self.nodeParent onFirstRespondingInParentChainSend:aSelector];
    }
    
    return NO;
}

- (id)firstInParentChainOfClass:(Class)aClass
{
    if (self.class == aClass)
    {
        return self;
    }
    
    if (self.nodeParent)
    {
        return [self.nodeParent firstInParentChainOfClass:aClass];
    }
    
    return nil;
}

- (BOOL)inParentChainHasClass:(Class)aClass
{
    return [self firstInParentChainOfClass:aClass] != nil;
}

- (NSArray *)childrenWith:(SEL)selector equalTo:anObject
{
    NSMutableArray *matches = [NSMutableArray array];
    
    for (NavNode *child in self.children.copy)
    {
        [matches addObjectsFromArray:[child childrenWith:selector equalTo:anObject]];

        if ([child respondsToSelector:selector])
        {
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            id value = [child performSelector:selector];
#pragma clang diagnostic pop
            
            if ([value isEqual:anObject])
            {
                [matches addObject:child];
            }
        }
        
    }
    
    return matches;
}

- (NavMirror *)navMirror
{
    if (!_navMirror)
    {
        _navMirror = [[NavMirror alloc] init];
        [_navMirror setNode:self];
    }
    
    return _navMirror;
}

- (void)updatedSlot:(NavSlot *)aNavSlot
{
    
}

// helper

/*
- (NSMutableArray *)nodeLeafs
{
    NSMutableArray *leafs = [NSMutableArray array];
    
    for (NavNode *child in self.children)
    {
        if (child.children.count == 0)
        {
            [leafs addObject:child];
        }
        else
        {
            [leafs addObjectsFromArray:[child nodeLeafs]];
        }
    }
    
    return leafs;
}

*/

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    [NSException raise:@"Missing method" format:nil];
}

@end
