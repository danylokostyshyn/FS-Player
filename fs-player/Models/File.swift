//
//  File.swift
//  fs-player
//
//  Created by Danylo Kostyshyn on 10/27/15.
//  Copyright © 2015 kostyshyn. All rights reserved.
//

import Foundation
import UIKit

@objc enum FileType: Int {
    case Undefined
    case Video
    case Audio
}

@objc class File: NSObject, Descriptable {
    
    var URL: NSURL!
    var name: String!
    var size: String!
    var type: FileType = .Undefined
    
    var isPlayable: Bool {
        get {
            switch (type) {
            case .Video, .Audio:
                return true
            default:
                return false
            }
        }
    }
    
    // MARK: - Descriptable    
    
    func text() -> String {
        return name
    }
        
    func detailText() -> String {
        return size
    }

}