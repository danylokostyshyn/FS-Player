//
//  FSFileTableViewCell.m
//  fs-player
//
//  Created by Danylo Kostyshyn on 6/16/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import "FSFileTableVIewCell.h"

//views
#import "FSProgressButton.h"

@interface FSFileTableViewCell ()
@property (weak, nonatomic) IBOutlet FSProgressButton *playButton;
@property (weak, nonatomic) IBOutlet FSProgressButton *downloadButton;
@end

@implementation FSFileTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)setProgress:(double)progress
{
    _progress = progress;
    self.downloadButton.progress = _progress;
}

- (void)awakeFromNib
{
    [self configure];
}

- (void)configure
{
//    self.downloadButton.progress = 0.5f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Actions

- (IBAction)playButtonPressed:(id)sender
{
    [self.delegate fileTableViewCellDidPressPlayButton:self];
}

- (IBAction)downloadButtonPressed:(id)sender
{
    [self.delegate fileTableViewCellDidPressDownloadButton:self];
}

@end
