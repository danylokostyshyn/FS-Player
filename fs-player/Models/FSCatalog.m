//
//  FSCatalog.m
//  fs-player
//
//  Created by Danylo Kostyshyn on 3/19/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import "FSCatalog.h"

@implementation FSCatalog

#pragma mark - FSDescriptionProtocol

- (NSString *)text
{
    return self.name;
}

- (NSString *)detailText
{
    return self.category;
}

- (UIImage *)image
{
    return nil;
}

- (NSURL *)imageURL
{
    return self.thumbnailURL;
}

@end
