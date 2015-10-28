//
//  Descriptable.swift
//  fs-player
//
//  Created by Danylo Kostyshyn on 10/27/15.
//  Copyright © 2015 kostyshyn. All rights reserved.
//

import Foundation
import UIKit

@objc protocol Descriptable: NSObjectProtocol {
    
    var URL: NSURL! { get set }
    
    func text() -> String
    func detailText() -> String

    optional func imageURL() -> NSURL?
    optional func image() -> UIImage?

}
