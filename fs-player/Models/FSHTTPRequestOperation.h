//
//  FSHTTPRequestOperation.h
//  fs-player
//
//  Created by Danylo Kostyshyn on 3/18/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import "AFHTTPRequestOperation.h"

@interface FSHTTPRequestOperation : AFHTTPRequestOperation
@property (nonatomic) BOOL showProgressHUD;
@property (strong, nonatomic) NSString *statusMessage;
@end
