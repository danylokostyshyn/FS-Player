//
//  FSSearchViewController.m
//  fs-player
//
//  Created by Danylo Kostyshyn on 3/18/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import "FSSearchViewController.h"

//models
#import "FSDataFetcher.h"
#import "FSDescriptionProtocol.h"

//views
#import "FSSearchResultsTableViewCell.h"

//controller
#import "FSFilesViewController.h"

@interface FSSearchViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) FSSearchResultsTableViewCell *cell;
@property (nonatomic, strong) UIBarButtonItem *loginBarButtonItem;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) NSArray *favorites;
@end

@implementation FSSearchViewController

- (UIBarButtonItem *)loginBarButtonItem
{
    if (!_loginBarButtonItem) {
        NSString *buttonTitle = nil;
        if ([FSSettings isLoggedIn]) {
            buttonTitle = @"Logout";
        } else {
            buttonTitle = @"Login";
        }
        _loginBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:buttonTitle
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(loginBarButtonPressed:)];
    }
    return _loginBarButtonItem;
}

- (FSSearchResultsTableViewCell *)cell
{
    if (!_cell) {
        _cell = [[[NSBundle mainBundle] loadNibNamed:@"FSSearchResultsTableViewCell" owner:self options:nil] lastObject];
    }
    return _cell;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
    self.navigationItem.leftBarButtonItem = self.loginBarButtonItem;
    
    if ([FSSettings isLoggedIn]) {
        [FSDataFetcher favoritesWithSuccess:^(NSArray *items) {
            self.favorites = items;
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            
        }];
    }
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

- (void)loginBarButtonPressed:(id)sender
{
    if ([FSSettings isLoggedIn]) {
        UIAlertView *loginAlertView = [[UIAlertView alloc] initWithTitle:@"Log out from fs.ua ?"
                                                                 message:nil
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel"
                                                       otherButtonTitles:@"Log out", nil];
        [loginAlertView show];
    } else {
        UIAlertView *loginAlertView = [[UIAlertView alloc] initWithTitle:@"Log in to fs.ua"
                                                                 message:nil
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel"
                                                       otherButtonTitles:@"Log in", nil];
        loginAlertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        [loginAlertView show];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
    } else if (tableView == self.tableView) {
        return [self.favorites count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id <FSDescriptionProtocol> item = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        item = [self.searchResults objectAtIndex:indexPath.row];
    } else if (tableView == self.tableView) {
        item = [self.favorites objectAtIndex:indexPath.row];
    } else return nil;

    static NSString *identifier = @"FSSearchResultsTableViewCell";
    FSSearchResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = self.cell;
        self.cell = nil;
    }

    cell.titleLabel.text = [item text];
    cell.categoryLabel.text = [item detailText];
    [cell.thumbnailImageView setImageWithURL:[item imageURL]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id <FSDescriptionProtocol> item = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        item = [self.searchResults objectAtIndex:indexPath.row];
    } else if (tableView == self.tableView) {
        item = [self.favorites objectAtIndex:indexPath.row];
    } else return;
    
    [FSDataFetcher filesFromURL:[item URL] folder:0 showProgressHUD:YES success:^(NSArray *files) {
        FSFilesViewController *controller = [FSFilesViewController controller];
        controller.title = [item text];
        controller.files = files;
        [self.navigationController pushViewController:controller animated:YES];
    } failure:^(NSError *error) {

    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView ||
        tableView == self.tableView) {
        return self.cell.bounds.size.height;
    }
    return 0.f;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchResults = nil;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self performSearch:searchBar.text];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if ([FSSettings isLoggedIn]) {
            self.favorites = nil;
            [self.tableView reloadData];
            [FSSettings deleteAllCookies];
            self.loginBarButtonItem = nil;
            self.navigationItem.leftBarButtonItem = self.loginBarButtonItem;
        } else {
            NSString *username = ((UITextField *)[alertView textFieldAtIndex:0]).text;
            NSString *password = ((UITextField *)[alertView textFieldAtIndex:1]).text;

            [FSDataFetcher loginUsingUsername:username password:password success:^{
                self.loginBarButtonItem = nil;
                self.navigationItem.leftBarButtonItem = self.loginBarButtonItem;
                
                [FSDataFetcher favoritesWithSuccess:^(NSArray *items) {
                    self.favorites = items;
                    [self.tableView reloadData];
                } failure:^(NSError *error) {
                    
                }];

            } failure:^(NSError *error) {
                
            }];
        }
    }
}

@end
