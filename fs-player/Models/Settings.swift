//
//  Settings.swift
//  fs-player
//
//  Created by Danylo Kostyshyn on 10/27/15.
//  Copyright © 2015 kostyshyn. All rights reserved.
//

import Foundation

@objc class Settings: NSObject {

    class func isLoggedIn() -> Bool {
        let siteURL = NSURL(string: APIEndPoint)!
        guard let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(siteURL) else { return false }
        var authCookiesCount = 0

        for cookie in cookies {
            switch cookie.name {
            case "fs_hash", "fs_pass":
                authCookiesCount += 1
            default: break
            }
        }

        return (authCookiesCount == 2)
    }
    
    class func deleteAllCookies() {
        let siteURL = NSURL(string: APIEndPoint)!
        guard let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(siteURL) else { return }
        for cookie in cookies {
            NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
        }
    }
    
    class func downloadsDirectory() -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        let downloadsPath = (documentsPath as NSString).stringByAppendingPathComponent("Downloads")
        var isDirectory: ObjCBool = false
        
        if !NSFileManager.defaultManager().fileExistsAtPath(downloadsPath, isDirectory: &isDirectory) && !isDirectory {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(downloadsPath,
                    withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print("\(error)")
            }
        }
        
        return downloadsPath
    }
    
    class func fileDescription(atPath filePath: String) -> String? {
        var attributesOrNil: [String: AnyObject]?
        do {
            attributesOrNil = try NSFileManager.defaultManager().attributesOfItemAtPath(filePath)
        } catch let error as NSError {
            print("\(error)")
        }
        
        guard
            let attributes = attributesOrNil,
            let size = attributes[NSFileSize],
            let modificationDate = attributes[NSFileModificationDate] as? NSDate
            else { return nil }

        let sizeString = NSByteCountFormatter.stringFromByteCount(size.longLongValue, countStyle: .File)

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm, MMM dd, yyyy"
        let modificationDateString = dateFormatter.stringFromDate(modificationDate)
        
        return "\(sizeString), \(modificationDateString)"
    }
    
}