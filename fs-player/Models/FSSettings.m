//
//  FSSettings.m
//  fs-player
//
//  Created by Danylo Kostyshyn on 3/20/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import "FSSettings.h"

@implementation FSSettings

+ (BOOL)isLoggedIn
{
    NSURL *siteURL = [NSURL URLWithString:@"http://brb.to/"];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:siteURL];
    int authCookiesCount = 0;
    
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:@"fs_hash"] ||
            [cookie.name isEqualToString:@"fs_pass"])
            authCookiesCount+=1;
    }
    
    if (authCookiesCount == 2) {
        return YES;
    }
    
    return NO;
}

+ (void)deleteAllCookies
{
    NSURL *siteURL = [NSURL URLWithString:@"http://brb.to/"];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:siteURL];
    for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

@end
