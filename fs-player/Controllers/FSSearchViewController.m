//
//  FSSearchViewController.m
//  fs-player
//
//  Created by Danylo Kostyshyn on 3/18/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import "FSSearchViewController.h"

#import "FSDataFetcher.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

#import "FSSearchResultsTableViewCell.h"

#import "FSFilesViewController.h"

@interface FSSearchViewController ()
@property (nonatomic, strong) NSTimer *searchTimer;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) FSSearchResultsTableViewCell *cell;
@end

@implementation FSSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (FSSearchResultsTableViewCell *)cell
{
    if (!_cell) {
        _cell = [[[NSBundle mainBundle] loadNibNamed:@"FSSearchResultsTableViewCell" owner:self options:nil] lastObject];
    }
    return _cell;
}

//- (NSTimer *)searchTimer
//{
//    if (!_searchTimer) {
//        
//    }
//}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.searchDisplayController.searchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)performSearch:(NSString *)searchString
{
    [FSDataFetcher searchForText:searchString showProgressHUD:YES success:^(NSArray *items) {
        self.searchResults = items;
        [self.searchDisplayController.searchResultsTableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        static NSString *identifier = @"FSSearchResultsTableViewCell";
        FSSearchResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = self.cell;
            self.cell = nil;
        }
        
        NSDictionary *item = [self.searchResults objectAtIndex:indexPath.row];
        
        cell.titleLabel.text = [item objectForKey:@"title"];
        cell.categoryLabel.text = [item objectForKey:@"category"];
        [cell.thumbnailImageView setImageWithURL:[item objectForKey:@"imageURL"]];
        
        return cell;
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSDictionary *item = [self.searchResults objectAtIndex:indexPath.row];
        
        [FSDataFetcher filesFromURL:[item objectForKey:@"URL"] folder:0 showProgressHUD:YES success:^(NSArray *files) {
            FSFilesViewController *controller = [FSFilesViewController controller];
            controller.title = [item objectForKey:@"title"];
            controller.files = files;
            [self.navigationController pushViewController:controller animated:YES];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        } failure:^(NSError *error) {
            
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.cell.bounds.size.height;
    }
    return 0.f;
}

#pragma mark - UISearchBarDelegate

- (void)performSearchWithTextFromSearchBar
{
    [self performSearch:self.searchDisplayController.searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchResults = nil;
    [self.searchTimer invalidate];
    self.searchTimer = nil;
    
    if ([searchBar.text length] > 0) {
        self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                            target:self
                                                          selector:@selector(performSearchWithTextFromSearchBar)
                                                          userInfo:nil
                                                           repeats:NO];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchTimer invalidate];
    self.searchTimer = nil;

    [self performSearch:searchBar.text];
}

#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return YES;
}

@end
