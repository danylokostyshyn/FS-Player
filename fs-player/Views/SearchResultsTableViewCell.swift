//
//  SearchResultsTableViewCell.swift
//  fs-player
//
//  Created by Danylo Kostyshyn on 10/29/15.
//  Copyright © 2015 kostyshyn. All rights reserved.
//

import UIKit

class SearchResultsTableViewCell: UITableViewCell {

    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    
    override func prepareForReuse() {
        thumbnailImageView.image = nil;
    }
        
}
