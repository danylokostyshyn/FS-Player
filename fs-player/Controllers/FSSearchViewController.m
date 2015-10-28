//
//  FSSearchViewController.m
//  fs-player
//
//  Created by Danylo Kostyshyn on 3/18/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import "FSSearchViewController.h"

//views
#import "FSSearchResultsTableViewCell.h"

//controller
#import "FSFilesViewController.h"

@interface FSSearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSTimer *searchTimer;
@property (nonatomic, strong) UIBarButtonItem *loginBarButtonItem;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) NSArray *favorites;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@end

@implementation FSSearchViewController

- (UIBarButtonItem *)loginBarButtonItem
{
    if (!_loginBarButtonItem) {
        NSString *buttonTitle = nil;
        if ([Settings isLoggedIn]) {
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

- (UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    if (!_longPressGestureRecognizer) {
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    }
    return _longPressGestureRecognizer;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = self.loginBarButtonItem;
    
    self.definesPresentationContext = YES;
    [self configureSearchBar];

    [self.tableView addGestureRecognizer:self.longPressGestureRecognizer];

    [self reloadFavorites];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)reloadTableView
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                  withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)reloadFavorites
{
    if ([Settings isLoggedIn]) {
        [DataFetcher favoritesWithSuccess:^(NSArray<Catalog *> * _Nonnull items) {
            self.favorites = items;
            [self reloadTableView];
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"%s: %@", __FUNCTION__, error);
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

- (void)performSearch
{
    NSString *pattern = self.searchController.searchBar.text;
    if ([pattern length] > 0) {
        
        [DataFetcher searchForText:pattern showProgressHUD:YES success:^(NSArray<Catalog *> * _Nonnull items) {
            self.searchResults = items;
            [self reloadTableView];
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"%s: %@", __FUNCTION__, error.localizedDescription);            
        }];
    }
}

- (void)performLoginWithUsername:(NSString *)username password:(NSString *)password
{
    [DataFetcher loginUsingUsername:username password:password success:^{
        self.loginBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = self.loginBarButtonItem;
        
        [self reloadFavorites];
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"%s: %@", __FUNCTION__, error.localizedDescription);
    }];
}

- (void)performLogout
{
    [Settings deleteAllCookies];
    
    self.favorites = nil;
    [self reloadTableView];
    
    self.loginBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = self.loginBarButtonItem;
}


- (void)loginBarButtonPressed:(id)sender
{
    UIAlertController *alertController = nil;
    if ([Settings isLoggedIn]) {
        alertController = [UIAlertController alertControllerWithTitle:@"Log out from fs.ua ?"
                                                              message:nil
                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel handler:nil]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Log out"
                                                            style:UIAlertActionStyleDefault
          handler:^(UIAlertAction * _Nonnull action) {
              [self performLogout];
          }]];
    } else {
        alertController = [UIAlertController alertControllerWithTitle:@"Log in to fs.ua"
                                                              message:nil
                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        __block UITextField *loginTextField = nil;
        __block UITextField *paswordTextField = nil;
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Login";
            loginTextField = textField;
        }];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Password";
            textField.secureTextEntry = YES;
            paswordTextField = textField;
        }];
                
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel handler:nil]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Log in"
                                                            style:UIAlertActionStyleDefault
          handler:^(UIAlertAction * _Nonnull action) {
              [self performLoginWithUsername:loginTextField.text
                                    password:paswordTextField.text];
          }]];
    }
    [self presentViewController:alertController animated:YES completion:nil];
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
    id <Descriptable> item = nil;

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
    id <Descriptable> selectedItem;

    if (self.searchController.active) {
        selectedItem = [self.searchResults objectAtIndex:indexPath.row];
    } else if (tableView == self.tableView) {
        selectedItem = [self.favorites objectAtIndex:indexPath.row];
    } else return;

    [DataFetcher filesFromURL:[selectedItem URL] folder:nil showProgressHUD:YES success:^(NSArray * _Nonnull files) {
        [self performSegueWithIdentifier:@"filesSegue"
                                  sender:@{@"selectedItem":selectedItem, @"files":files}];
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"%s: %@", __FUNCTION__, error.localizedDescription);
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"filesSegue"]) {

        id <Descriptable> selectedItem = [sender objectForKey:@"selectedItem"];
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

#pragma mark - 

- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
        
        id <Descriptable> item = nil;
        if (self.searchController.active) {
            item = [self.searchResults objectAtIndex:indexPath.row];
        } else {
            item = [self.favorites objectAtIndex:indexPath.row];
        }

        if ([item isKindOfClass:[Catalog class]]) {
            Catalog *catalog = (Catalog *)item;
            if (catalog.identifier.length == 0) {
                return;
            }
            
            void (^reloadFavoritesBlock)() = ^void() { [self reloadFavorites]; };

            void (^addToFavoritesHandler)(UIAlertAction * _Nonnull) = ^void(UIAlertAction * _Nonnull action) {
                [DataFetcher addToFavoritesWithIdentifier:catalog.identifier success:reloadFavoritesBlock failure:nil];
            };
            
            void (^removeFromFavoritesHandler)(UIAlertAction * _Nonnull) = ^void(UIAlertAction * _Nonnull action) {
                [DataFetcher removeFromFavoritesWithIdentifier:catalog.identifier success:reloadFavoritesBlock failure:nil];
            };

            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[catalog text]
                                                                                     message:nil
                                                                              preferredStyle:UIAlertControllerStyleActionSheet];
            // Create add or remove action
            UIAlertAction *mainAction = nil;
            if ([catalog isFavorite]) {
                mainAction = [UIAlertAction actionWithTitle:@"Remove favorite"
                                                      style:UIAlertActionStyleDestructive
                                                    handler:removeFromFavoritesHandler];

            } else {
                mainAction = [UIAlertAction actionWithTitle:@"Add to favorite"
                                                      style:UIAlertActionStyleDefault
                                                    handler:addToFavoritesHandler];
            }
            [alertController addAction:mainAction];

            // Add cancel action
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:nil];
            [alertController addAction:cancelAction];
            
            if (alertController.popoverPresentationController) {
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                alertController.popoverPresentationController.sourceView = cell;
                alertController.popoverPresentationController.sourceRect = [cell convertRect:cell.frame fromView:self.tableView];
            }
            
            [self.navigationController presentViewController:alertController animated:YES completion:nil];
        }
    }
}

@end
