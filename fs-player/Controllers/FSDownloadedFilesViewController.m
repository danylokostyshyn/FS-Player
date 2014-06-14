//
//  FSDownloadedFilesViewController.m
//  fs-player
//
//  Created by Danylo Kostyshyn on 6/16/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import "FSDownloadedFilesViewController.h"

#import "FSSettings.h"

// controllers
#import "VDLPlaybackViewController.h"

@interface FSDownloadedFilesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *files;
@end

@implementation FSDownloadedFilesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (NSArray *)files
{
    if (!_files) {
        NSString *downloadsDirectory = [FSSettings downloadsDirectory];
        NSURL *downloadsDirectoryURL = [NSURL fileURLWithPath:downloadsDirectory isDirectory:YES];

        NSError *error;
        _files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:downloadsDirectoryURL
                                               includingPropertiesForKeys:nil
                                                                  options:0
                                                                    error:&error];
        
        if (error) { NSLog(@"%@", error); }
    }

    return _files;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Downloads", nil);
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateData];
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
    static NSString *identifier = @"downloadedFilesTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    NSURL *fileURL = [self.files objectAtIndex:indexPath.row];
    cell.textLabel.text = [[fileURL pathComponents] lastObject];
    cell.detailTextLabel.text = [FSSettings fileDescriptionAtPath:[fileURL path]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *fileURL = [self.files objectAtIndex:indexPath.row];
    
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
    if (error) { NSLog(@"%@", error); }

    self.files = nil;
    
    [tableView deleteRowsAtIndexPaths:@[indexPath]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VDLPlaybackViewController *controller = [[VDLPlaybackViewController alloc] initWithNibName:@"VDLPlaybackViewController" bundle:nil];
    NSURL *fileURL = [self.files objectAtIndex:indexPath.row];
    [controller playMediaFromURL:fileURL];

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

#pragma mark - Actions

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    [self.tableView setEditing:editing animated:animated];
}

- (void)updateData
{
    self.files = nil;
    [self.tableView reloadData];
}

@end
