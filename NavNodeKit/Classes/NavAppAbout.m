//
//  NavAppAbout.m
//  NavNodeKit
//
//  Created by Steve Dekorte on 10/28/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//

#import "NavAppAbout.h"

@implementation NavAppAbout

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.nodeTitle = @"About";
        //self.nodeSubtitle = self.versionString;
        self.shouldSortChildren = NO;
        self.nodeSuggestedWidth = 150;
        [self mergeWithChildren:self.aboutNodes];
    }
    
    return self;
}

+ (id)nodeRoot // just here for a method signature
{
    return nil;
}

- (id)nodeAbout // just here for a method signature
{
    return nil;
}

/*
- (NSString *)versionString
{
    NSDictionary *info = [NSBundle bundleForClass:[self class]].infoDictionary;
    NSString *versionString = [info objectForKey:@"CFBundleVersion"];
    return [NSString stringWithFormat:@"version %@", versionString];
}
*/

- (NSArray *)aboutNodes
{
    NSArray *allBundles = [NSBundle.allBundles arrayByAddingObjectsFromArray:NSBundle.allFrameworks];
    NSMutableArray *results = [NSMutableArray array];
    
    for (NSBundle *bundle in allBundles)
    {
        //printf("%s\n", bundle.bundleIdentifier.UTF8String);
        
        NSString *bundleClassName = [bundle.bundleIdentifier componentsSeparatedByString:@"."].lastObject;

        /*
        if ([bundleClassName isEqualToString:@"BitmessageKit"])
        {
            NSLog(@"on bm");
        }
        */
        
        Class bundleClass = NSClassFromString(bundleClassName);
        
        if (bundleClass && [bundleClass respondsToSelector:@selector(nodeRoot)])
        {
            id bundleNode = [bundleClass nodeRoot];
            
            if ([bundleNode respondsToSelector:@selector(nodeAbout)])
            {
                [results addObject:[bundleNode nodeAbout]];
            }
        }
    }
    
    return results;
}

@end
