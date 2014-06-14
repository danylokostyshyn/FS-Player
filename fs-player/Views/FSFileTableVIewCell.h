//
//  FSFileTableViewCell.h
//  fs-player
//
//  Created by Danylo Kostyshyn on 6/16/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSFileTableViewCell;
@protocol FSFileTableViewCellDelegate <NSObject>
- (void)fileTableViewCellDidPressPlayButton:(FSFileTableViewCell *)cell;
- (void)fileTableViewCellDidPressDownloadButton:(FSFileTableViewCell *)cell;
@end

@protocol FSProgressDelegate <NSObject>
- (void)progressDidChange:(CGFloat)progress;
@end

@interface FSFileTableViewCell : UITableViewCell <FSProgressDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) id <FSFileTableViewCellDelegate> delegate;
@end
