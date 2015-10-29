//
//  FilesViewController.swift
//  fs-player
//
//  Created by Danylo Kostyshyn on 10/29/15.
//  Copyright © 2015 kostyshyn. All rights reserved.
//

import UIKit

class FilesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, VDLPlaybackViewControllerDelegate {

    @IBOutlet private weak var tableView: UITableView!
    
    var files: [Descriptable]!
    
    // MARK: -
    
    private func playVideoFromURL(URL: NSURL) {
        let controller = VDLPlaybackViewController(nibName: "VDLPlaybackViewController", bundle:nil)
        controller.delegate = self;
        
        navigationController?.presentViewController(controller, animated: true, completion: nil)
        controller.playMediaFromURL(URL)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        let item = files[indexPath.row]
        if let folder = item as? Folder {
            cell = tableView.dequeueReusableCellWithIdentifier("subtitleTableViewCell")
            cell.textLabel?.text = folder.text()
            cell.detailTextLabel?.text = folder.detailText()
            cell.imageView?.image = folder.image()
        }
        else if let file = item as? File {
            cell = tableView.dequeueReusableCellWithIdentifier("subtitleTableViewCell")
            cell.textLabel?.text = file.text()
            cell.detailTextLabel?.text = file.detailText()
        }
        return cell
    }

    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = files[indexPath.row]
        if let folder = item as? Folder {
            DataFetcher.files(fromURL: folder.URL, folder: folder.identifier, success: { (files) -> () in
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("filesViewController") as! FilesViewController
                controller.title = folder.name
                controller.files = files
                self.navigationController?.pushViewController(controller, animated: true)
            }, failure: { (error) -> () in
                NSLog("%@", error)
            })
        }
        else if let file = item as? File where file.isPlayable {
            playVideoFromURL(file.URL)
        }
    }

    // MARK: - FileTableViewCellDelegate
    
    func fileTableViewCellDidPressDownloadButton(cell: FileTableViewCell) {
        let index = tableView.indexPathForCell(cell)!.row;
        let item = files[index]
        
        guard let file  = item as? File where file.isPlayable else { return }
        DataFetcher.downloadFile(fromURL: file.URL, success: nil, failure: nil, progress: { (progress) -> () in
            cell.progress = progress
        })
    }
    
    func fileTableViewCellDidPressPlayButton(cell: FileTableViewCell) {
        let index = tableView.indexPathForCell(cell)!.row;
        let item = files[index]
        
        guard let file  = item as? File where file.isPlayable else { return }
        playVideoFromURL(file.URL)
    }

    // MARK: - VDLPlaybackViewControllerDelegate
    
    func playbackControllerDidFinishPlayback(playbackController: VDLPlaybackViewController!) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

}
