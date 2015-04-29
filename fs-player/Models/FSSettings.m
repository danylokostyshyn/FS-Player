//
//  FSSettings.m
//  fs-player
//
//  Created by Danylo Kostyshyn on 3/20/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import "FSSettings.h"

#import "FSDataFetcher.h"

@implementation FSSettings

+ (BOOL)isLoggedIn
{
    NSURL *siteURL = [NSURL URLWithString:FS_API_ENDPOINT];
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
    NSURL *siteURL = [NSURL URLWithString:FS_API_ENDPOINT];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:siteURL];
    for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

+ (NSString *)downloadsDirectory
{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *downloadsPath = [documentsPath stringByAppendingPathComponent:@"Downloads"];

    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:downloadsPath isDirectory:&isDirectory] && !isDirectory) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:downloadsPath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:&error];
        if (error) { NSLog(@"%@", error); }
    }

    return downloadsPath;
}

+ (NSString *)fileDescriptionAtPath:(NSString *)filePath
{
    NSError *error;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
    if (error) {
        NSLog(@"%@", error);
        return nil;
    }
    
    NSNumber *size = [attributes objectForKey:NSFileSize];
    NSString *sizeString = [NSByteCountFormatter stringFromByteCount:[size longLongValue]
                                                          countStyle:NSByteCountFormatterCountStyleFile];
    
    NSDate *modificationDate = [attributes objectForKey:NSFileModificationDate];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm, MMM dd, yyyy";
    NSString *modificationDateString = [dateFormatter stringFromDate:modificationDate];

    return [NSString stringWithFormat:@"%@, %@", sizeString, modificationDateString];
}

@end
