//
//  FileTableViewCell.swift
//  fs-player
//
//  Created by Danylo Kostyshyn on 10/29/15.
//  Copyright © 2015 kostyshyn. All rights reserved.
//

import UIKit

@objc protocol FileTableViewCellDelegate: NSObjectProtocol {
    func fileTableViewCellDidPressPlayButton(cell: FileTableViewCell) -> ()
    func fileTableViewCellDidPressDownloadButton(cell: FileTableViewCell) -> ()
}

class FileTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    
    @IBOutlet private weak var playButton: ProgressButton!
    @IBOutlet private weak var downloadButton: ProgressButton!

    weak var delegate: FileTableViewCellDelegate?
    
    var progress: Double = 0.0 {
        didSet {
            downloadButton.progress = progress
        }
    }
    
    // MARK: - Actions
    
    @IBAction func playButtonPressed(sender: AnyObject) {
        self.delegate?.fileTableViewCellDidPressPlayButton(self)
    }
    
    @IBAction func downloadButtonPressed(sender: AnyObject) {
        self.delegate?.fileTableViewCellDidPressDownloadButton(self)
    }

}
