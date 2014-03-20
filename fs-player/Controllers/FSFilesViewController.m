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

@interface FSFilesViewController ()
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
    // Do any additional setup after loading the view.
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
    static NSString *identifier = @"FSFilesTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    id <FSDescriptionProtocol> item = [self.files objectAtIndex:indexPath.row];
    cell.textLabel.text = [item text];
    cell.detailTextLabel.text = [item detailText];
    cell.imageView.image = [item image];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self.files objectAtIndex:indexPath.row];
    if ([item isKindOfClass:[FSFolder class]]) {
        FSFolder *folder = (FSFolder *)item;
        [FSDataFetcher filesFromURL:folder.URL folder:folder.identifier showProgressHUD:YES success:^(NSArray *files) {
            FSFilesViewController *controller = [FSFilesViewController controller];
            controller.title = folder.name;
            controller.files = files;
            [self.navigationController pushViewController:controller animated:YES];
        } failure:^(NSError *error) {
            
        }];
    } else if ([item isKindOfClass:[FSFile class]]) {
        FSFile *file = (FSFile *)item;
        
        if ([file isPlayable]) {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"vlc://"]]) {
                NSString *vlcScheme = [[file.URL absoluteString] stringByReplacingOccurrencesOfString:@"http://" withString:@"vlc://"];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:vlcScheme]];
            } else {
                // download VLC player from AppStore
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/id650377962"]];
            }
        } else {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

@end
