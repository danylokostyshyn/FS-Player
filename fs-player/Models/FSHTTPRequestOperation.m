//
//  FSHTTPRequestOperation.m
//  fs-player
//
//  Created by Danylo Kostyshyn on 3/18/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import "FSHTTPRequestOperation.h"

//models
#import <AFNetworkActivityIndicatorManager.h>

//views
#import <SVProgressHUD.h>

@implementation FSHTTPRequestOperation

- (NSURLRequest *)connection:(NSURLConnection *)connection
             willSendRequest:(NSURLRequest *)request
            redirectResponse:(NSURLResponse *)response
{
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
    if (self.showProgressHUD) {
        if (self.statusMessage) {
            [SVProgressHUD showWithStatus:self.statusMessage
                                 maskType:SVProgressHUDMaskTypeBlack];
        } else {
            [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading", nil)
                                 maskType:SVProgressHUDMaskTypeBlack];
        }
    }
    return [super connection:connection willSendRequest:request redirectResponse:response];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    if (self.showProgressHUD) {
        [SVProgressHUD dismiss];
    }
    [super connectionDidFinishLoading:connection];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    if (self.showProgressHUD) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"No Internet Connection", nil)];
    }
    [super connection:connection didFailWithError:error];
}

@end
