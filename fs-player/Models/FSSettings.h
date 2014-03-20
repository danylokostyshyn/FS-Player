//
//  FSSettings.h
//  fs-player
//
//  Created by Danylo Kostyshyn on 3/20/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSSettings : NSObject

+ (BOOL)isLoggedIn;
+ (void)deleteAllCookies;

@end
