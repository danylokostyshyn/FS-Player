//
//  FSCatalog.h
//  fs-player
//
//  Created by Danylo Kostyshyn on 3/19/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FSDescriptionProtocol.h"

@interface FSCatalog : NSObject <FSDescriptionProtocol>
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSURL *thumbnailURL;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, getter = isFavorite) BOOL favorite;
@end
