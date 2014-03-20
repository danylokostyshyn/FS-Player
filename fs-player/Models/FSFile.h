//
//  FSFile.h
//  fs-player
//
//  Created by Danylo Kostyshyn on 3/18/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FSDescriptionProtocol.h"

typedef enum {
    FSFileTypeUndefined,
    FSFileTypeVideo,
    FSFileTypeAudio
} FSFileType;

@interface FSFile : NSObject <FSDescriptionProtocol>
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *size;
@property (nonatomic) FSFileType type;
- (BOOL)isPlayable;
@end
