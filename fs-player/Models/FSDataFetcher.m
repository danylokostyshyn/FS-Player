//
//  FSDataFetcher.m
//  fs-player
//
//  Created by Danylo Kostyshyn on 3/18/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import "FSDataFetcher.h"

//models
#import <AFNetworking.h>
#import "FSHTTPRequestOperation.h"
#import "TFHpple.h"
#import "FSSettings.h"

#import "FSCatalog.h"
#import "FSFolder.h"
#import "FSFile.h"

@implementation FSDataFetcher

static NSString *kAPIBaseUrlString = @"http://brb.to";

+ (void)searchForText:(NSString *)searchText
      showProgressHUD:(BOOL)showProgressHUD
              success:(void(^)(NSArray *items))successBlock
              failure:(void(^)(NSError *error))errorBlock
{
    NSString *encodedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *parameters = [NSString stringWithFormat:@"search.aspx?search=%@", encodedSearchText];
    NSString *path = [kAPIBaseUrlString stringByAppendingPathComponent:parameters];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    FSHTTPRequestOperation *operation = [[FSHTTPRequestOperation alloc] initWithRequest:request];
    operation.showProgressHUD = YES;
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:responseObject];
        NSMutableArray *items = [NSMutableArray array];
        NSArray *elements = [doc searchWithXPathQuery:@"//div[@class='b-search-page__results']/a"];
        for (TFHppleElement *element in elements) {
            FSCatalog *catalog = [[FSCatalog alloc] init];
            NSString *pathComponent =  [[element attributes] objectForKey:@"href"];
            catalog.URL = [[NSURL alloc] initWithScheme:@"http" host:@"brb.to" path:pathComponent];
            catalog.name = [[[element searchWithXPathQuery:@"//@title"] lastObject] text];
            NSString *imgSrc = [[[element searchWithXPathQuery:@"//img/@src"] lastObject] text];
            catalog.thumbnailURL = [NSURL URLWithString:imgSrc];
            catalog.category = [[[element searchWithXPathQuery:@"//span[@class='b-search-page__results-item-subsection']"] lastObject] text];
            [items addObject:catalog];
        }
        if (successBlock) successBlock(items);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (errorBlock) errorBlock(error);
    }];
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}

+ (void)filesFromURL:(NSURL *)URL
              folder:(NSUInteger)folderIdentifier
     showProgressHUD:(BOOL)showProgressHUD
             success:(void(^)(NSArray *files))successBlock
             failure:(void(^)(NSError *error))errorBlock
{
    NSString *parameters = [NSString stringWithFormat:@"?ajax&folder=%lu", (unsigned long)folderIdentifier];
    NSString *path = [[URL absoluteString] stringByAppendingString:parameters];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    FSHTTPRequestOperation *operation = [[FSHTTPRequestOperation alloc] initWithRequest:request];
    operation.showProgressHUD = YES;
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:responseObject];

        NSMutableArray *files = [NSMutableArray array];
        TFHppleElement *ulTag = [[doc searchWithXPathQuery:@"//*[starts-with(@class,'filelist')]"] lastObject];
        for (TFHppleElement *liTag in [ulTag children]) {
            NSString *classValue = [[liTag attributes] objectForKey:@"class"];
            if ([classValue hasPrefix:@"folder"]) {
                FSFolder *folder = [[FSFolder alloc] init];
                folder.URL = URL;

                // only root folders contains 'header' tag
                BOOL isRootFolder = [[liTag childrenWithClassName:@"header"] count];

                NSString *identifier = nil;
                if (isRootFolder) {
                    identifier = [[(TFHppleElement *)[[liTag searchWithXPathQuery:@"//div/a[1]"] lastObject] attributes] objectForKey:@"name"];
                } else {
                    identifier = [[(TFHppleElement *)[[liTag searchWithXPathQuery:@"//div[2]/a[1]"] lastObject] attributes] objectForKey:@"name"];
                }
                identifier = [identifier stringByReplacingOccurrencesOfString:@"fl" withString:@""];
                folder.identifier = [identifier integerValue];

                if (isRootFolder) {
                    folder.name = [((TFHppleElement *)[[liTag searchWithXPathQuery:@"//div/a/b"] lastObject]) text];
                } else {
                    folder.name = [((TFHppleElement *)[[liTag searchWithXPathQuery:@"//div[2]/a[1]"] lastObject]) text];
                }

                if (isRootFolder) {
                    folder.videoQuality = FSVideoQualityUndefined;
                } else {
                    NSString *qualityString = [[((TFHppleElement *)[[liTag searchWithXPathQuery:@"//div[1]"] lastObject]) attributes] objectForKey:@"class"];
                    if ([qualityString rangeOfString:@"m-hd"].location != NSNotFound) {
                        folder.videoQuality = FSVideoQualityHD;
                    } else if ([qualityString rangeOfString:@"m-sd"].location != NSNotFound) {
                        folder.videoQuality = FSVideoQualitySD;
                    } else {
                        folder.videoQuality = FSVideoQualityUndefined;
                    }
                }
                
                if (isRootFolder) {
                    folder.language = FSVideoLanguageUndefined;
                } else {
                    NSString *languageString = [[((TFHppleElement *)[[liTag searchWithXPathQuery:@"//div[2]/a[1]"] lastObject]) attributes] objectForKey:@"class"];
                    if ([languageString rangeOfString:@"m-en"].location != NSNotFound) {
                        folder.language = FSVideoLanguageEN;
                    } else if ([languageString rangeOfString:@"m-ru"].location != NSNotFound) {
                        folder.language = FSVideoLanguageRU;
                    } else if ([languageString rangeOfString:@"m-ua"].location != NSNotFound) {
                        folder.language = FSVideoLanguageUA;
                    } else {
                        folder.language = FSVideoLanguageUndefined;
                    }
                }
                
                folder.size = [((TFHppleElement *)[[liTag childrenWithClassName:@"material-details"] lastObject]) text];
                folder.dateString = [((TFHppleElement *)[[liTag childrenWithClassName:@"material-date"] lastObject]) text];
                folder.details = [((TFHppleElement *)[[liTag childrenWithClassName:@"material-details"] firstObject]) text];

                [files addObject:folder];
             }
             else if (classValue && [classValue rangeOfString:@"file"].location != NSNotFound) {
                 FSFile *file = [[FSFile alloc] init];
                 file.name = [((TFHppleElement *)[[liTag searchWithXPathQuery:@"//span/span"] lastObject]) text];
                 file.size = [((TFHppleElement *)[[liTag searchWithXPathQuery:@"//a/span"] lastObject]) text];
                 
                 NSString *typeString = [[liTag attributes] objectForKey:@"class"];
                    if ([typeString rangeOfString:@"m-file-new_type_video"].location != NSNotFound) {
                        file.type = FSFileTypeVideo;
                    } else if ([typeString rangeOfString:@"m-file-new_type_audio"].location != NSNotFound) {
                        file.type = FSFileTypeAudio;
                    } else {
                        file.type = FSFileTypeUndefined;
                    }
                 
                 
                 NSString *pathComponent = [((TFHppleElement *)[[liTag searchWithXPathQuery:@"//a"] lastObject]) objectForKey:@"href"];
                 NSURL *fileURL = [[NSURL alloc] initWithScheme:@"http" host:@"brb.to" path:pathComponent];
                 file.URL = fileURL;

                 [files addObject:file];
             }
        }

        if (successBlock) successBlock(files);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (errorBlock) errorBlock(error);
    }];
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}

+ (void)loginUsingUsername:(NSString *)username
                  password:(NSString *)password
                   success:(void(^)())successBlock
                   failure:(void(^)(NSError *error))errorBlock
{
    NSString *path = [kAPIBaseUrlString stringByAppendingPathComponent:@"login.aspx"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    request.HTTPMethod = @"POST";
    NSString *bodyText = [NSString stringWithFormat:@"login=%@&passwd=%@&remember=on", username, password];
    request.HTTPBody = [bodyText dataUsingEncoding:NSUTF8StringEncoding];

    FSHTTPRequestOperation *operation = [[FSHTTPRequestOperation alloc] initWithRequest:request];
    operation.showProgressHUD = YES;
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) successBlock();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (errorBlock) errorBlock(error);
    }];

    [[NSOperationQueue mainQueue] addOperation:operation];
}

+ (void)favoritesWithSuccess:(void(^)(NSArray *items))successBlock
                   failure:(void(^)(NSError *error))errorBlock
{
    NSString *parameters = [NSString stringWithFormat:@"myfavourites.aspx"];
    NSString *path = [kAPIBaseUrlString stringByAppendingPathComponent:parameters];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    FSHTTPRequestOperation *operation = [[FSHTTPRequestOperation alloc] initWithRequest:request];
    operation.showProgressHUD = YES;
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *items = [NSMutableArray array];
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:responseObject];
        NSArray *categoryElements = [doc searchWithXPathQuery:@"//div[@class='b-tabpanels']/div[starts-with(@class,'b-category')]"];
        for (TFHppleElement *categoryElement in categoryElements) {
            NSString *categoryName = [[[categoryElement searchWithXPathQuery:@"//span[@class='section-title']/b"] lastObject] text];
            
            NSArray *postersElements = [categoryElement searchWithXPathQuery:@"//div[starts-with(@class, 'b-posters')]"];
            for (TFHppleElement *postersElement in postersElements) {
                
                NSArray *posterElements = [postersElement searchWithXPathQuery:@"//div[starts-with(@class, 'b-poster')]"];
                for (TFHppleElement *posterElement in posterElements) {
                    TFHppleElement *aTag = [[posterElement childrenWithTagName:@"a"] firstObject];
                    if (aTag) {
                        FSCatalog *catalog = [[FSCatalog alloc] init];
                        catalog.category = categoryName;
                        catalog.name = [[[aTag searchWithXPathQuery:@"//b/span"] lastObject] text];
                        
                        NSString *path = [[aTag attributes] objectForKey:@"href"];
                        path = [kAPIBaseUrlString stringByAppendingPathComponent:path];
                        catalog.URL = [NSURL URLWithString:path];

                        NSString *imageURLString = [[aTag attributes] objectForKey:@"style"];
                        imageURLString = [imageURLString stringByReplacingOccurrencesOfString:@"background-image: url('" withString:@""];
                        imageURLString = [imageURLString stringByReplacingOccurrencesOfString:@"')" withString:@""];
                        catalog.thumbnailURL = [NSURL URLWithString:imageURLString];
                        
                        catalog.favorite = YES;
                        
                        [items addObject:catalog];
                    }
                }
            }
        }
        
        if (successBlock) successBlock(items);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (errorBlock) errorBlock(error);
    }];
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}

+ (void)addToOrRemoveFromFavoritesItemWithIdentifier:(NSString *)identifier
                                       statusMessage:(NSString *)statusMessage
                                             success:(void(^)())successBlock
                                             failure:(void(^)(NSError *error))errorBlock
{
    NSString *path = [kAPIBaseUrlString stringByAppendingPathComponent:@"addto/favorites"];
    path = [path stringByAppendingPathComponent:identifier];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    request.HTTPMethod = @"GET";
    
    FSHTTPRequestOperation *operation = [[FSHTTPRequestOperation alloc] initWithRequest:request];
    operation.statusMessage = statusMessage;
    operation.showProgressHUD = YES;
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) successBlock();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (errorBlock) errorBlock(error);
    }];
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}

+ (void)addToFavoritesItemWithIdentifier:(NSString *)identifier
                                 success:(void(^)())successBlock
                                 failure:(void(^)(NSError *error))errorBlock
{
    [FSDataFetcher addToOrRemoveFromFavoritesItemWithIdentifier:identifier
                                                  statusMessage:NSLocalizedString(@"Adding to favorites..", nil)
                                                        success:successBlock
                                                        failure:errorBlock];
}


+ (void)removeFromFavoritesItemWithIdentifier:(NSString *)identifier
                                      success:(void(^)())successBlock
                                      failure:(void(^)(NSError *error))errorBlock
{
    [FSDataFetcher addToOrRemoveFromFavoritesItemWithIdentifier:identifier
                                                  statusMessage:NSLocalizedString(@"Removing from favorites..", nil)
                                                        success:successBlock
                                                        failure:errorBlock];
}

+ (void)downloadFileFromURL:(NSURL *)fileURL
                    success:(void(^)(NSString *filePath))successBlock
                    failure:(void(^)(NSError *error))errorBlock
           progressDelegate:(id <FSProgressDelegate>)progressDelegate;
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fileURL];
    request.HTTPMethod = @"GET";
    
    NSString *fileName = [[[fileURL pathComponents] lastObject] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *downloadsDirectory = [FSSettings downloadsDirectory];
    NSString *filePath = [downloadsDirectory stringByAppendingPathComponent:fileName];
    
    FSHTTPRequestOperation *operation = [[FSHTTPRequestOperation alloc] initWithRequest:request];
    operation.statusMessage = NSLocalizedString(@"Downloading..", nil);
    operation.showProgressHUD = YES;
    operation.outputStream = [[NSOutputStream alloc] initToFileAtPath:filePath append:YES];

    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//        NSLog(@"%d %d %d", bytesRead, totalBytesRead, totalBytesExpectedToRead);
        CGFloat progress = (double)totalBytesRead / (double)totalBytesExpectedToRead;
        [progressDelegate progressDidChange:progress];
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) successBlock(filePath);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (errorBlock) errorBlock(error);
    }];
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}


@end
