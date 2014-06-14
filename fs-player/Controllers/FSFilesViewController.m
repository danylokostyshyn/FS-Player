//
//  FSFilesViewController.m
//  fs-player
//
//  Created by Danylo Kostyshyn on 3/18/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import "FSFilesViewController.h"

//models
#import "FSDataFetcher.h"
#import "FSFile.h"
#import "FSFolder.h"

//views
#import "FSFileTableViewCell.h"

@interface FSFilesViewController () <UITableViewDataSource, UITableViewDelegate, FSFileTableViewCellDelegate>
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
    return [self.files count];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self.files objectAtIndex:indexPath.row];

    if ([item isKindOfClass:[FSFolder class]]) {

        static NSString *subtitleCellIdentifier = @"subtitleTableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:subtitleCellIdentifier];
        
        id <FSDescriptionProtocol> item = [self.files objectAtIndex:indexPath.row];
        cell.textLabel.text = [item text];
        cell.detailTextLabel.text = [item detailText];
        cell.imageView.image = [item image];
        
        return cell;

    } else if ([item isKindOfClass:[FSFile class]]) {
    
        static NSString *fileCellIdentifier = @"fileTableViewCell";
        FSFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:fileCellIdentifier];
        cell.delegate = self;
        
        id <FSDescriptionProtocol> item = [self.files objectAtIndex:indexPath.row];
        cell.titleLabel.text = [item text];
        cell.sizeLabel.text = [item detailText];
        
        return cell;
        
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self.files objectAtIndex:indexPath.row];

    if ([item isKindOfClass:[FSFolder class]]) {

        FSFolder *folder = (FSFolder *)item;
        [FSDataFetcher filesFromURL:folder.URL folder:folder.identifier showProgressHUD:YES success:^(NSArray *files) {
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            FSFilesViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"filesViewController"];
            controller.title = folder.name;
            controller.files = files;

            [self.navigationController pushViewController:controller animated:YES];

        } failure:^(NSError *error) {
            
        }];
        
    }
}

#pragma mark - FSFileTableViewCellDelegate

- (void)fileTableViewCellDidPressPlayButton:(FSFileTableViewCell *)cell
{
    NSUInteger index = [self.tableView indexPathForCell:cell].row;
    id item = [self.files objectAtIndex:index];
    
    if ([item isKindOfClass:[FSFile class]]) {
        FSFile *file = (FSFile *)item;
        if ([file isPlayable]) {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"vlc://"]]) {
                NSString *vlcScheme = [[file.URL absoluteString] stringByReplacingOccurrencesOfString:@"http://" withString:@"vlc://"];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:vlcScheme]];
            } else {
                // download VLC player from AppStore
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/id650377962"]];
            }
        }
    }
}

- (void)fileTableViewCellDidPressDownloadButton:(FSFileTableViewCell *)cell
{
    NSUInteger index = [self.tableView indexPathForCell:cell].row;
    id item = [self.files objectAtIndex:index];
    
    if ([item isKindOfClass:[FSFile class]]) {
        FSFile *file = (FSFile *)item;
        if ([file isPlayable]) {
            [FSDataFetcher downloadFileFromURL:file.URL success:nil failure:nil progressDelegate:cell];
        }
    }
}

@end
