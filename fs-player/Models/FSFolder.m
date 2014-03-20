//
//  FSFolder.m
//  fs-player
//
//  Created by Danylo Kostyshyn on 3/18/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import "FSFolder.h"

@implementation FSFolder

#pragma mark - FSDescriptionProtocol

- (NSString *)text
{
    NSString *qualityString = nil;
    if (self.videoQuality == FSVideoQualitySD) { qualityString = @"SD"; }
    else if (self.videoQuality == FSVideoQualityHD) { qualityString = @"HD"; }
    
    if (qualityString) {
        return [NSString stringWithFormat:@"[%@] %@", qualityString, self.name];
    }
    return self.name;
}

- (NSString *)detailText
{
    return [NSString stringWithFormat:@"%@, %@, %@", self.size, self.details, self.dateString];
}

- (UIImage *)image
{
    switch (self.language) {
        case FSVideoLanguageUndefined: return [UIImage imageNamed:@"icon-folder-general"];
        case FSVideoLanguageEN: return [UIImage imageNamed:@"icon-flag-us"];
        case FSVideoLanguageRU: return [UIImage imageNamed:@"icon-flag-ru"];
        case FSVideoLanguageUA: return [UIImage imageNamed:@"icon-flag-ua"];
        default: return [UIImage imageNamed:@"icon-folder-general"];
    }
}

- (UIImage *)imageURL
{
    return nil;
}

@end
