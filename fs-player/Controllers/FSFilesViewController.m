//
//  FSFilesViewController.m
//  fs-player
//
//  Created by Danylo Kostyshyn on 3/18/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import "FSFilesViewController.h"

//views
#import "FSFileTableViewCell.h"

#import "VDLPlaybackViewController.h"

@interface FSFilesViewController () <UITableViewDataSource, UITableViewDelegate, FSFileTableViewCellDelegate, VDLPlaybackViewControllerDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation FSFilesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.files count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self.files objectAtIndex:indexPath.row];

    if ([item isKindOfClass:[Folder class]]) {

        static NSString *subtitleCellIdentifier = @"subtitleTableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:subtitleCellIdentifier];
        
        id <Descriptable> item = [self.files objectAtIndex:indexPath.row];
        cell.textLabel.text = [item text];
        cell.detailTextLabel.text = [item detailText];
        cell.imageView.image = [item image];
        
        return cell;

    } else if ([item isKindOfClass:[File class]]) {
    
        static NSString *fileCellIdentifier = @"subtitleTableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:fileCellIdentifier];
        
        id <Descriptable> item = [self.files objectAtIndex:indexPath.row];
        cell.textLabel.text = [item text];
        cell.detailTextLabel.text = [item detailText];
        
        return cell;
        
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self.files objectAtIndex:indexPath.row];

    if ([item isKindOfClass:[Folder class]]) {
        Folder *folder = (Folder *)item;
        [DataFetcher filesFromURL:folder.URL folder:folder.identifier showProgressHUD:YES success:^(NSArray * _Nonnull files) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            FSFilesViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"filesViewController"];
            controller.title = folder.name;
            controller.files = files;

            [self.navigationController pushViewController:controller animated:YES];
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"%s: %@", __FUNCTION__, error.localizedDescription);
        }];
    } else if ([item isKindOfClass:[File class]]) {
        [self fileTableViewCellDidPressPlayButton:(FSFileTableViewCell *)[tableView cellForRowAtIndexPath:indexPath]];
    }
}

#pragma mark - FSFileTableViewCellDelegate

- (void)fileTableViewCellDidPressPlayButton:(FSFileTableViewCell *)cell
{
    NSUInteger index = [self.tableView indexPathForCell:cell].row;
    id item = [self.files objectAtIndex:index];

    if ([item isKindOfClass:[File class]]) {
        File *file = (File *)item;
        if ([file isPlayable]) {
            VDLPlaybackViewController *controller = [[VDLPlaybackViewController alloc] initWithNibName:@"VDLPlaybackViewController" bundle:nil];
            controller.delegate = self;

            [self.navigationController presentViewController:controller animated:YES completion:nil];
            [controller playMediaFromURL:file.URL];
        }
    }
}

- (void)fileTableViewCellDidPressDownloadButton:(FSFileTableViewCell *)cell
{
    NSUInteger index = [self.tableView indexPathForCell:cell].row;
    id item = [self.files objectAtIndex:index];
    
    if ([item isKindOfClass:[File class]]) {
        File *file = (File *)item;
        if ([file isPlayable]) {
            [DataFetcher downloadFileFromURL:file.URL success:nil failure:nil progress:^(double progress) {
                cell.progress = progress;
            }];
        }
    }
}

#pragma mar - VDLPlaybackViewControllerDelegate

- (void)playbackControllerDidFinishPlayback:(VDLPlaybackViewController *)playbackController
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
