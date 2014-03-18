//
//  FSFolder.h
//  fs-player
//
//  Created by Danylo Kostyshyn on 3/18/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FSDescriptionProtocol.h"

typedef enum {
    FSVideoQualityUndefined,
    FSVideoQualitySD,
    FSVideoQualityHD
} FSVideoQuality;

typedef enum {
    FSVideoLanguageUndefined,
    FSVideoLanguageEN,
    FSVideoLanguageRU,
    FSVideoLanguageUA
} FSVideoLanguage;

@interface FSFolder : NSObject <FSDescriptionProtocol>
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSUInteger identifier;
@property (nonatomic, strong) NSString *size;
@property (nonatomic, strong) NSString *dateString;
@property (nonatomic, strong) NSString *details;
@property (nonatomic) FSVideoLanguage language;
@property (nonatomic) FSVideoQuality videoQuality;
@end
