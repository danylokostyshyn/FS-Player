//
//  FSDescriptionProtocol.h
//  fs-player
//
//  Created by Danylo Kostyshyn on 3/18/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSDescriptionProtocol <NSObject>
- (NSString *)text;
- (NSString *)detailText;
@optional
- (NSURL *)URL;
- (UIImage *)image;
- (NSURL *)imageURL;
@end
