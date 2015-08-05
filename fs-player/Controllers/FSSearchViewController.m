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

@interface FSSearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating, UIAlertViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSTimer *searchTimer;
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

- (UISearchController *)searchController
{
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.searchResultsUpdater = self;
        _searchController.hidesNavigationBarDuringPresentation = NO;
        _searchController.dimsBackgroundDuringPresentation = NO;
        _searchController.searchBar.delegate = self;
        _searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    }
    return _searchController;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.definesPresentationContext = YES;
    
    self.navigationItem.leftBarButtonItem = self.loginBarButtonItem;
    [self configureSearchBar];

    if ([FSSettings isLoggedIn]) {
        [FSDataFetcher favoritesWithSuccess:^(NSArray *items) {
            self.favorites = items;
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)configureSearchBar
{
    UISearchBar *searchBar = self.searchController.searchBar;
    searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *searchBarContainer = [[UIView alloc] initWithFrame:self.navigationController.navigationBar.bounds];
    [searchBarContainer addSubview:searchBar];

    NSDictionary *views = @{@"searchBar" : searchBar};
    [searchBarContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[searchBar]-0-|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:views]];

    [searchBarContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[searchBar]-0-|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:views]];
    self.navigationItem.titleView = searchBarContainer;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)performSearch
{
    NSString *pattern = self.searchController.searchBar.text;
    if ([pattern length] > 0) {
        [FSDataFetcher searchForText:pattern showProgressHUD:YES success:^(NSArray *items) {
            self.searchResults = items;
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            
        }];
    }
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
    if (self.searchController.active) {
        return [self.searchResults count];
    } else if (tableView == self.tableView) {
        return [self.favorites count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id <FSDescriptionProtocol> item = nil;

    if (self.searchController.active) {
        item = [self.searchResults objectAtIndex:indexPath.row];
    } else if (tableView == self.tableView) {
        item = [self.favorites objectAtIndex:indexPath.row];
    } else return nil;

    static NSString *identifier = @"searchResultsTableViewCell";
    FSSearchResultsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];

    cell.titleLabel.text = [item text];
    cell.categoryLabel.text = [item detailText];
    [cell.thumbnailImageView setImageWithURL:[item imageURL]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id <FSDescriptionProtocol> selectedItem;

    if (self.searchController.active) {
        selectedItem = [self.searchResults objectAtIndex:indexPath.row];
    } else if (tableView == self.tableView) {
        selectedItem = [self.favorites objectAtIndex:indexPath.row];
    } else return;
    
    [FSDataFetcher filesFromURL:[selectedItem URL] folder:0 showProgressHUD:YES success:^(NSArray *files) {
        [self performSegueWithIdentifier:@"filesSegue"
                                  sender:@{@"selectedItem":selectedItem, @"files":files}];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"filesSegue"]) {

        id <FSDescriptionProtocol> selectedItem = [sender objectForKey:@"selectedItem"];
        NSArray *files = [sender objectForKey:@"files"];
        
        FSFilesViewController *controller = segue.destinationViewController;
        controller.title = [selectedItem text];
        controller.files = files;
    }
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [self.searchTimer invalidate];
    [self.tableView reloadData];
    self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                        target:self
                                                      selector:@selector(performSearch)
                                                      userInfo:nil
                                                       repeats:NO];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchResults = nil;
 }

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0) {
        self.searchResults = nil;
    }
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
