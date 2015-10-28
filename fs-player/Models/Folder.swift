//
//  Folder.swift
//  fs-player
//
//  Created by Danylo Kostyshyn on 10/27/15.
//  Copyright © 2015 kostyshyn. All rights reserved.
//

import Foundation
import UIKit

@objc enum VideoQuality: Int {
    case Undefined
    case SD
    case HD
}

@objc enum VideoLanguage: Int {
    case Undefined
    case EN
    case RU
    case UA
}

@objc class Folder: NSObject, Descriptable {
    
    var URL: NSURL!    
    var name: String!
    var identifier: String!
    var size: String!
    var dateString: String!
    var details: String!
    var language: VideoLanguage = .Undefined
    var videoQuality: VideoQuality = .Undefined
    
    // MARK: - Descriptable

    func text() -> String {
        var qualityString: String?
        switch (videoQuality) {
        case .SD: qualityString = "SD"
        case .HD: qualityString = "HD"
        default: break
        }
        
        if let _ = qualityString {
            return "[\(qualityString!)] \(name)"
        } else {
            return name
        }
    }
    
    func detailText() -> String {
        return "\(size), \(details) \(dateString)"
    }
        
    func image() -> UIImage? {
        switch (language) {
        case .EN:
            return UIImage(imageLiteral: "icon-flag-us")
        case .RU:
            return UIImage(imageLiteral: "icon-flag-ru")
        case .UA:
            return UIImage(imageLiteral: "icon-flag-ua")
        default:
            return UIImage(imageLiteral: "icon-folder-general")
        }
    }
    
}