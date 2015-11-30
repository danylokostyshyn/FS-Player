//
//  SearchViewController.swift
//  fs-player
//
//  Created by Danylo Kostyshyn on 10/29/15.
//  Copyright © 2015 kostyshyn. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    @IBOutlet private weak var tableView: UITableView!

    private var searchResults = [Descriptable]()
    private var favorites = [Catalog]()

    lazy private var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController:nil)
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.searchBarStyle = .Minimal
        return searchController
    }()

    private var searchTimer: NSTimer!

    lazy private var loginBarButtonItem: UIBarButtonItem! = {
        return UIBarButtonItem(title: Settings.isLoggedIn() ? "Logout" : "Login",
            style: .Plain, target: self, action: "loginBarButtonPressed:")
    }()
    
    lazy private var longPressGestureRecognizer: UILongPressGestureRecognizer = {
        return UILongPressGestureRecognizer(target: self, action: "longPress:")
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = loginBarButtonItem
        
        definesPresentationContext = true
        configureSearchBar()
        
        tableView.addGestureRecognizer(longPressGestureRecognizer)
        
        reloadFavorites()
    }

    // MARK: - Private Methods
    
    private func reloadTableView() {
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
    }
    
    private func reloadFavorites() {
        if Settings.isLoggedIn() {
            DataFetcher.favorites(withSuccess: { (items) -> () in
                self.favorites = items
                self.reloadTableView()
            }, failure: { (error) -> () in
                NSLog("\(error)")
            })
        }
    }
    
    private func configureSearchBar() {

        let searchBar = self.searchController.searchBar
        searchBar.translatesAutoresizingMaskIntoConstraints = false
    
        let searchBarContainer = UIView(frame: navigationController!.navigationBar.bounds)
        searchBarContainer.addSubview(searchBar)
    
        let views = ["searchBar" : searchBar]
        searchBarContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[searchBar]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        searchBarContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[searchBar]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        navigationItem.titleView = searchBarContainer
    }
    
    func performSearch()  {
        guard let pattern = searchController.searchBar.text else { return }
        if pattern.characters.count > 0 {
            DataFetcher.search(forText: pattern, success: { (items) -> () in
                self.searchResults = items
                self.reloadTableView()
            }, failure: { (error) -> () in
                NSLog("\(error)")
            })
        }
    }
    
    private func performLogin(username: String, password: String) {
        DataFetcher.login(usingUsername: username, password: password, success: { () -> () in
            self.loginBarButtonItem = nil
            self.navigationItem.leftBarButtonItem = self.loginBarButtonItem
            self.reloadFavorites()
        }, failure: { (error) -> () in
            NSLog("\(error)")
        })
    }
    
    private func performLogout() {
        Settings.deleteAllCookies()
        
        favorites.removeAll()
        reloadTableView()
        
        loginBarButtonItem = nil
        navigationItem.leftBarButtonItem = loginBarButtonItem
    }
    
    func loginBarButtonPressed(sender: AnyObject) {

        var alertController: UIAlertController!
        if Settings.isLoggedIn() {
            alertController = UIAlertController(title: "Log out from fs.ua ?", message: nil, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Log out", style: .Default, handler: { (action) -> Void in
                self.performLogout()
            }))
        } else {
            alertController = UIAlertController(title: "Log in to fs.ua", message: nil, preferredStyle: .Alert)
            
            var loginTextField: UITextField!
            var paswordTextField: UITextField!
            
            alertController.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                textField.placeholder = "Login"
                loginTextField = textField
            })
            
            alertController.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                textField.placeholder = "Password"
                textField.secureTextEntry = true
                paswordTextField = textField
            })

            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Log in", style: .Default, handler: { (action) -> Void in
                if let username = loginTextField.text, let password = paswordTextField.text {
                    self.performLogin(username, password: password)
                }
            }))
            
            loginTextField.text = "danylok"
            paswordTextField.text = "XhCLKsuNxWW74p"
        }
        presentViewController(alertController, animated: true, completion: nil)
    }

    // MARK: - UITableViewDataSource
    
    private func itemAtIndexPath(indexPath: NSIndexPath) -> Descriptable {
        if searchController.active {
            return searchResults[indexPath.row]
        } else {
            return favorites[indexPath.row]
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return searchResults.count
        } else {
            return favorites.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item: Descriptable = itemAtIndexPath(indexPath)

        let cellIdentifier = "searchResultsTableViewCell"
        let cell = tableView .dequeueReusableCellWithIdentifier(cellIdentifier) as! SearchResultsTableViewCell
        cell.titleLabel.text = item.text()
        cell.categoryLabel.text = item.detailText()
        
        if let imageURL = item.imageURL?() {
            cell.thumbnailImageView.setImageWithURL(imageURL)
        }
        
        return cell
    }
    
    // MAKR: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item: Descriptable = itemAtIndexPath(indexPath)
        
        DataFetcher.files(fromURL: item.URL, folder: nil, success: { (files) -> () in
            self.performSegueWithIdentifier("filesSegue", sender: ["selectedItem":item, "files":files])
        }, failure: { (error) -> () in
            NSLog("\(error)")
        })
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "filesSegue":
            guard
                let dict = sender as? [String: AnyObject],
                let item = dict["selectedItem"] as? Descriptable,
                let files = dict["files"] as? [Descriptable]
            else { break }

            let controller = segue.destinationViewController as! FilesViewController
            controller.title = item.text()
            controller.files = files
        default: break
        }
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        searchTimer?.invalidate()
        searchTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self,
            selector: "performSearch", userInfo: nil, repeats: false)
        
    }

    // MARK: - UISearchBarDelegate

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchResults.removeAll()
        searchController.active = false
        reloadTableView()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if  searchText.characters.count == 0 {
            searchResults.removeAll()
            reloadTableView()
        }
    }

    // MARK: -
    
    func longPress(gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Began:
            let point = gestureRecognizer.locationInView(tableView)
            let indexPath = tableView.indexPathForRowAtPoint(point)!
            let item: Descriptable = itemAtIndexPath(indexPath)
            
            guard let catalog = item as? Catalog else { return }
            if catalog.identifier.characters.count == 0 {
                return
            }

            let reloadFavoritesBlock: () -> () = { self.reloadFavorites() }

            let addToFavoritesHandler: (UIAlertAction) -> () = { _ in
                DataFetcher.addToFavorites(withIdentifier: catalog.identifier, success: reloadFavoritesBlock, failure: nil)
            }
            let removeFromFavoritesHandler: (UIAlertAction) -> () = { _ in
                DataFetcher.removeFromFavorites(withIdentifier: catalog.identifier, success: reloadFavoritesBlock, failure: nil)
            }
            
            let alertController = UIAlertController(title: catalog.text(), message: nil, preferredStyle: .ActionSheet)
            var mainAction: UIAlertAction!
            if catalog.isFavorite {
                mainAction = UIAlertAction(title: "Remove from favorites", style: .Destructive, handler: removeFromFavoritesHandler)
            } else {
                mainAction = UIAlertAction(title: "Add to favorites", style: .Default, handler: addToFavoritesHandler)
            }
            alertController.addAction(mainAction)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            
            if let popoverController = alertController.popoverPresentationController {
                let cell = tableView.cellForRowAtIndexPath(indexPath)!
                popoverController.sourceView = cell
                popoverController.sourceRect = cell.convertRect(cell.frame, fromView: tableView)
            }
            
            navigationController?.presentViewController(alertController, animated: true, completion: nil)
        default: break
        }
    }
    
}
