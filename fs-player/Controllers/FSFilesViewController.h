//
//  FSFilesViewController.h
//  fs-player
//
//  Created by Danylo Kostyshyn on 3/18/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import "FSViewController.h"

@interface FSFilesViewController : FSViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *files;
@end
