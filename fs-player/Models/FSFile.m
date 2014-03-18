//
//  FSFile.m
//  fs-player
//
//  Created by Danylo Kostyshyn on 3/18/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import "FSFile.h"

@implementation FSFile

- (BOOL)isPlayable
{
    if (self.type == FSFileTypeVideo || self.type == FSFileTypeAudio) {
        return YES;
    }
    return NO;
}

#pragma mark - FSDescriptionProtocol

- (NSString *)text
{
    return self.name;
}

- (NSString *)detailText
{
    return self.size;
}

- (UIImage *)image
{
    return nil;
}

@end
