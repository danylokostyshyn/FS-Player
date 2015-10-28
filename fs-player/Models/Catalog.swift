//
//  Catalog.swift
//  fs-player
//
//  Created by Danylo Kostyshyn on 10/27/15.
//  Copyright © 2015 kostyshyn. All rights reserved.
//

import Foundation

class Catalog: NSObject, Descriptable {

    var URL: NSURL!
    var identifier: String!
    var name: String!
    var thumbnailURL: NSURL!
    var category: String!
    var isFavorite = false
    
    // MARK: - Descriptable

    func text() -> String {
        return name
    }
    
    func detailText() -> String {
        return category
    }
    
    func imageURL() -> NSURL? {
        return thumbnailURL
    }

}
