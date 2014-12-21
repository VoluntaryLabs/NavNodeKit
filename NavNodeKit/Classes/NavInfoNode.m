//
//  NavInfoNode.m
//  Bitmessage
//
//  Created by Steve Dekorte on 4/17/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//

#import "NavInfoNode.h"

@implementation NavInfoNode

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.nodeSuggestedWidth = @300;
    }
    
    return self;
}


/*
- (NSView *)nodeView
{
    NSView *view = [super nodeView];
    return view;
}
*/

- (NSString *)nodeNote
{
    if (!_nodeNote)
    {
        return [super nodeNote];
    }
    
    return _nodeNote;
}

- (void)composeChildrenFromPropertyNames:(NSArray *)names
{
    NSMutableArray *children = [NSMutableArray array];
    
    for (NSString *name in names)
    {
        SEL sel = NSSelectorFromString(name);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSObject *value = [self performSelector:sel withObject:nil];
#pragma clang diagnostic pop
        NavInfoNode *childNode = [[NavInfoNode alloc] init];
        childNode.nodeTitle = name.capitalizedString;
        childNode.nodeSubtitle = value.description;
        [children addObject:childNode];
        [childNode setNodeParent:self];
    }
    
    [self setChildren:children];
}

/*
- (void)setContentToResourceName:(NSString *)resourceName
{
    NSString *resourcePath = [NSBundle pathForResource:resourceName];
    NSError *error;
    NSString *fileContent = [NSString stringWithContentsOfFile:resourcePath encoding:NSUTF8StringEncoding error:&error];
    self.nodeContentString = fileContent;
}
*/

- (NSString *)nodeContentString
{
    if (!_nodeContentString && _nodeResourceName)
    {
        NSString *resourcePath = [NSBundle pathForResource:_nodeResourceName];
        NSError *error;
        
        _nodeContentString = [NSString stringWithContentsOfFile:resourcePath encoding:NSUTF8StringEncoding error:&error];
    }
    
    return _nodeContentString;
}


@end
