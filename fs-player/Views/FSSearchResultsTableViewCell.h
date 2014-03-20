//
//  FSSearchResultsTableViewCell.h
//  fs-player
//
//  Created by Danylo Kostyshyn on 3/18/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AFNetworking/UIImageView+AFNetworking.h>

@interface FSSearchResultsTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *categoryLabel;
@end
