//
//  FSDataFetcher.h
//  fs-player
//
//  Created by Danylo Kostyshyn on 3/18/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FSFileTableViewCell.h"

@interface FSDataFetcher : NSObject

+ (void)searchForText:(NSString *)searchText
      showProgressHUD:(BOOL)showProgressHUD
              success:(void(^)(NSArray *items))successBlock // array of FSCatalog
              failure:(void(^)(NSError *error))errorBlock;

+ (void)filesFromURL:(NSURL *)URL
              folder:(NSUInteger)folder
     showProgressHUD:(BOOL)showProgressHUD
             success:(void(^)(NSArray *files))successBlock // array of FSFolder and FSFile
             failure:(void(^)(NSError *error))errorBlock;

+ (void)loginUsingUsername:(NSString *)username
                  password:(NSString *)password
                   success:(void(^)())successBlock
                   failure:(void(^)(NSError *error))errorBlock;

+ (void)favoritesWithSuccess:(void(^)(NSArray *items))successBlock // array of FSCatalog
                     failure:(void(^)(NSError *error))errorBlock;

+ (void)addToFavoritesItemWithIdentifier:(NSString *)identifier
                                 success:(void(^)())successBlock
                                 failure:(void(^)(NSError *error))errorBlock;

+ (void)removeFromFavoritesItemWithIdentifier:(NSString *)identifier
                                      success:(void(^)())successBlock
                                      failure:(void(^)(NSError *error))errorBlock;

+ (void)downloadFileFromURL:(NSURL *)fileURL
                    success:(void(^)(NSString *filePath))successBlock
                    failure:(void(^)(NSError *error))errorBlock
                   progressDelegate:(id <FSProgressDelegate>)progressDelegate;

@end
