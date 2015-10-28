//
//  DataFetcher.swift
//  fs-player
//
//  Created by Danylo Kostyshyn on 10/27/15.
//  Copyright © 2015 kostyshyn. All rights reserved.
//

import Foundation

let APIEndPoint = "http://fs.to"

@objc class DataFetcher: NSObject {
    
    class HTTPRequestOperation: AFHTTPRequestOperation {
        
        var statusMessage: String?
        var showProgressHUD = false
        
        override func connection(connection: NSURLConnection, willSendRequest request: NSURLRequest, redirectResponse response: NSURLResponse?) -> NSURLRequest? {
            AFNetworkActivityIndicatorManager.sharedManager().incrementActivityCount()
            if showProgressHUD {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let message = self.statusMessage {
                        SVProgressHUD.showWithStatus(message, maskType: .Black)
                    } else {
                        SVProgressHUD.showWithStatus(NSLocalizedString("Loading", comment: ""), maskType: .Black)
                    }
                })
            }
            return super.connection(connection, willSendRequest: request, redirectResponse: response)
            
        }
        
        override func connectionDidFinishLoading(connection: NSURLConnection) {
            AFNetworkActivityIndicatorManager.sharedManager().decrementActivityCount()
            if showProgressHUD {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.dismiss()
                })
            }
            super.connectionDidFinishLoading(connection)
        }
        
        override func connection(connection: NSURLConnection, didFailWithError error: NSError) {
            AFNetworkActivityIndicatorManager.sharedManager().decrementActivityCount()
            if showProgressHUD {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.showErrorWithStatus(NSLocalizedString("No Internet Connection", comment: ""))
                })
            }
            super.connection(connection, didFailWithError: error)
        }
        
    }
    
    class func search(forText searchText: String, showProgressHUD: Bool = true, success: (([Catalog]) -> ())?, failure: ((NSError) -> ())? ) {
        let encodedSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let parameters = "search.aspx?search=\(encodedSearchText)"
        let path = (APIEndPoint as NSString).stringByAppendingPathComponent(parameters)
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        
        let operation = HTTPRequestOperation(request: request)
        operation.showProgressHUD = true
        operation.responseSerializer = AFHTTPResponseSerializer()
        operation.setCompletionBlockWithSuccess({ (operation, responseObject) -> Void in
            var items = [Catalog]()
            defer {
                if success != nil { success!(items) }
            }

            guard let responseData = responseObject as? NSData else { return }
            let doc = TFHpple(HTMLData: responseData)
            
            var XPathQuery = "//div[@class='b-search-page__results']/a"
            guard let elements = doc.searchWithXPathQuery(XPathQuery) as? [TFHppleElement] else { return }
            for element in elements {
                guard let path = element.attributes?["href"] as? String else { continue }
        
                let catalog = Catalog()
                
                var identifier = path.componentsSeparatedByString("/").last!
                identifier = identifier.componentsSeparatedByString("-").first!
                catalog.identifier = identifier
                
                let URLString = (APIEndPoint as NSString).stringByAppendingPathComponent(path)
                catalog.URL = NSURL(string: URLString)
                
                if let name = (element.searchWithXPathQuery("//@title").last as? TFHppleElement)?.text() {
                    catalog.name = name
                }
                
                if let imgSrc = (element.searchWithXPathQuery("//img/@src").last as? TFHppleElement)?.text() {
                    catalog.thumbnailURL = NSURL(string: imgSrc)
                }
                
                XPathQuery = "//span[@class='b-search-page__results-item-subsection']"
                if let category = (element.searchWithXPathQuery(XPathQuery).last
                    as? TFHppleElement)?.text() {
                    catalog.category = category
                }
                
                items.append(catalog)
            }
        }, failure: { (operation, error) -> Void in
            if failure != nil { failure!(error) }
        })
        NSOperationQueue.mainQueue().addOperation(operation)
    }
    
    class func files(fromURL URL: NSURL, folder: String?, showProgressHUD: Bool = true, success: (([AnyObject]) -> ())?, failure: ((NSError) -> ())? ) {
        let folderIdentifier = folder ?? "0"
        let parameters = "?ajax&folder=\(folderIdentifier)"
        let path = URL.absoluteString.stringByAppendingString(parameters)
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        
        let operation = HTTPRequestOperation(request: request)
        operation.showProgressHUD = true
        operation.responseSerializer = AFHTTPResponseSerializer()
        operation.setCompletionBlockWithSuccess({ (operation, responseObject) -> Void in
            var items = [AnyObject]()
            defer {
                if success != nil { success!(items) }
            }
            
            guard let responseData = responseObject as? NSData else { return }
            let doc = TFHpple(HTMLData: responseData)
            
            let XPathQuery = "//*[starts-with(@class,'filelist')]"
            guard let ulTag = doc.searchWithXPathQuery(XPathQuery).last as? TFHppleElement else { return }
            for liTag in ulTag.children {
                guard let classValue = liTag.attributes["class"] as? String else { continue }
                if classValue.hasPrefix("folder") {
                    let folder = Folder()
                    folder.URL = URL
                    
                    // only root folders contains 'header' tag
                    let isRootFolder = liTag.childrenWithClassName("header").count > 0

                    // identifier
                    var identifier: String!
                    if (isRootFolder) {
                        identifier = (liTag.searchWithXPathQuery("//div/a[1]").last as! TFHppleElement).attributes["name"] as! String
                    } else {
                        identifier = (liTag.searchWithXPathQuery("//div[2]/a[1]").last as! TFHppleElement).attributes["name"] as! String
                    }
                    identifier = identifier.stringByReplacingOccurrencesOfString("fl", withString: "")
                    folder.identifier = identifier;
                    
                    // name
                    if (isRootFolder) {
                        folder.name = (liTag.searchWithXPathQuery("//div/a/b").last as! TFHppleElement).text()
                    } else {
                        folder.name = (liTag.searchWithXPathQuery("//div[2]/a[1]").last as! TFHppleElement).text()
                    }

                    // quality
                    if (isRootFolder) {
                        folder.videoQuality = VideoQuality.Undefined
                    } else {
                        let qualityString = (liTag.searchWithXPathQuery("//div[1]").last as! TFHppleElement).attributes["class"] as! String
                        if ((qualityString as NSString).rangeOfString("m-hd").location != NSNotFound) {
                            folder.videoQuality = VideoQuality.HD
                        } else if ((qualityString as NSString).rangeOfString("m-sd").location != NSNotFound) {
                            folder.videoQuality = VideoQuality.SD
                        } else {
                            folder.videoQuality = VideoQuality.Undefined
                        }
                    }
                    
                    // language
                    if (isRootFolder) {
                        folder.language = VideoLanguage.Undefined
                    } else {
                        let languageString = (liTag.searchWithXPathQuery("//div[2]/a[1]").last as! TFHppleElement).attributes["class"] as! String
                        if ((languageString as NSString).rangeOfString("m-en").location != NSNotFound) {
                            folder.language = VideoLanguage.EN
                        } else if ((languageString as NSString).rangeOfString("m-ru").location != NSNotFound) {
                            folder.language = VideoLanguage.RU
                        } else if ((languageString as NSString).rangeOfString("m-ua").location != NSNotFound) {
                            folder.language = VideoLanguage.UA
                        } else {
                            folder.language = VideoLanguage.Undefined
                        }
                    }
                    
                    folder.details = (liTag.childrenWithClassName("material-details").first as! TFHppleElement).text()
                    folder.size = (liTag.childrenWithClassName("material-details").last as! TFHppleElement).text()
                    folder.dateString = (liTag.childrenWithClassName("material-date").last as! TFHppleElement).text()

                    items.append(folder)
                } else if (classValue as NSString).rangeOfString("file").location != NSNotFound {
                    let file = File()
                    
                    file.name = (liTag.searchWithXPathQuery("//span/span").last as! TFHppleElement).text()
                    file.size = (liTag.searchWithXPathQuery("//a/span").last as! TFHppleElement).text()
                    
                    let typeString = liTag.attributes["class"] as! String
                    if ((typeString as NSString).rangeOfString("m-file-new_type_video").location != NSNotFound) {
                        file.type = FileType.Video
                    } else if ((typeString as NSString).rangeOfString("m-file-new_type_audio").location != NSNotFound) {
                        file.type = FileType.Audio
                    } else {
                        file.type = FileType.Undefined
                    }

                    let pathComponent = (liTag.searchWithXPathQuery("//a").last as! TFHppleElement)["href"] as! String
                    let fileURL = NSURL(scheme: "http", host: "brb.to", path: pathComponent)
                    file.URL = fileURL
                    
                    items.append(file)
                }
            }
        }, failure: { (operation, error) -> Void in
            if failure != nil { failure!(error) }
        })
        NSOperationQueue.mainQueue().addOperation(operation)
    }
    
    class func login(usingUsername username: String, password: String, success: (() -> ())?, failure: ((NSError) -> ())? ) {
        let path = (APIEndPoint as NSString).stringByAppendingPathComponent("login.aspx")
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        request.HTTPMethod = "POST"
        
        let bodyText = "login=\(username)&passwd=\(password)&remember=on"
        request.HTTPBody = bodyText.dataUsingEncoding(NSUTF8StringEncoding)
        
        let operation = HTTPRequestOperation(request: request)
        operation.showProgressHUD = true
        operation.responseSerializer = AFHTTPResponseSerializer()
        operation.setCompletionBlockWithSuccess({ (operation, responseObject) -> Void in
            if success != nil { success!() }
        }, failure: { (operation, error) -> Void in
            if failure != nil { failure!(error) }
        })
        NSOperationQueue.mainQueue().addOperation(operation)
    }
    
    class func favorites(withSuccess success: (([Catalog]) -> ())?, failure: ((NSError) -> ())? ) {
        let parameters = "myfavourites.aspx"
        let path = (APIEndPoint as NSString).stringByAppendingPathComponent(parameters)
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        
        let operation = HTTPRequestOperation(request: request)
        operation.showProgressHUD = true
        operation.responseSerializer = AFHTTPResponseSerializer()
        operation.setCompletionBlockWithSuccess({ (operation, responseObject) -> Void in
            var items = [Catalog]()
            defer {
                if success != nil { success!(items) }
            }
            
            guard let responseData = responseObject as? NSData else { return }
            let doc = TFHpple(HTMLData: responseData)

            var XPathQuery = "//div[@class='b-tabpanels']/div[starts-with(@class,'b-category')]"
            guard let categoryElements = doc.searchWithXPathQuery(XPathQuery) as? [TFHppleElement] else { return }
            for categoryElement in categoryElements {
                XPathQuery = "//span[@class='section-title']/b"
                let categoryName = (categoryElement.searchWithXPathQuery(XPathQuery).last as? TFHppleElement)?.text()
                
                XPathQuery = "//div[starts-with(@class, 'b-posters')]"
                guard let postersElements = categoryElement.searchWithXPathQuery(XPathQuery) as? [TFHppleElement] else { continue }
                for postersElement in postersElements {
                    
                    XPathQuery = "//div[starts-with(@class, 'b-poster')]"
                    guard let posterElements = postersElement.searchWithXPathQuery(XPathQuery) as? [TFHppleElement] else { continue }
                    for posterElement in posterElements {

                        guard let aTag = posterElement.childrenWithTagName("a").first as? TFHppleElement else { continue }
                        let catalog = Catalog()
                        catalog.category = categoryName
                        
                        if let name = (aTag.searchWithXPathQuery("//b/span").last as? TFHppleElement)?.text() {
                            catalog.name = name
                        }
                        
                        var path = aTag.attributes["href"] as! String
                        
                        var identifier = path.componentsSeparatedByString("/").last!
                        identifier = identifier.componentsSeparatedByString("-").first!
                        catalog.identifier = identifier
                        
                        path = (APIEndPoint as NSString).stringByAppendingPathComponent(path)
                        catalog.URL = NSURL(string: path)
                        
                        var imageURLString = aTag.attributes["style"] as! String
                        imageURLString = imageURLString.stringByReplacingOccurrencesOfString("background-image: url('", withString: "")
                        imageURLString = imageURLString.stringByReplacingOccurrencesOfString("')", withString: "")
                        catalog.thumbnailURL = NSURL(string: imageURLString)
                        
                        catalog.isFavorite = true

                        items.append(catalog)
                    }
                }
            }
        }, failure: { (operation, error) -> Void in
            if failure != nil { failure!(error) }
        })
        NSOperationQueue.mainQueue().addOperation(operation)
    }

    private class func addOrRemoveFromFavorites(itemWithIdentifier identifier: String, statusMessage: String, success: (() -> ())?, failure: ((NSError) -> ())? ) {
        var path = (APIEndPoint as NSString).stringByAppendingPathComponent("addto/favorites")
        path = (path as NSString).stringByAppendingPathComponent(identifier)
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        
        let operation = HTTPRequestOperation(request: request)
        operation.showProgressHUD = true
        operation.statusMessage = statusMessage
        operation.responseSerializer = AFHTTPResponseSerializer()
        operation.setCompletionBlockWithSuccess({ (operation, responseObject) -> Void in
            if success != nil { success!() }
        }, failure: { (operation, error) -> Void in
            if failure != nil { failure!(error) }
        })
        NSOperationQueue.mainQueue().addOperation(operation)
    }
    
    class func addToFavorites(withIdentifier identifier: String, success: (() -> ())?, failure: ((NSError) -> ())? ) {
        DataFetcher.addOrRemoveFromFavorites(itemWithIdentifier: identifier,
            statusMessage: NSLocalizedString("Adding to favorites..", comment: ""),
            success: success, failure: failure)
    }
    
    class func removeFromFavorites(withIdentifier identifier: String, success: (() -> ())?, failure: ((NSError) -> ())? ) {
        DataFetcher.addOrRemoveFromFavorites(itemWithIdentifier: identifier,
            statusMessage: NSLocalizedString("Removing from favorites..", comment: ""),
            success: success, failure: failure)
    }

    class func downloadFile(fromURL fileURL: NSURL, success: ((String) -> ())?, failure: ((NSError) -> ())?, progress: ((Double) -> ())? ) {
        let request = NSMutableURLRequest(URL: fileURL)
        request.HTTPMethod = "GET"
        
        guard let fileName = fileURL.pathComponents?.last?.stringByRemovingPercentEncoding else { return }
        let downloadsDirectory = Settings.downloadsDirectory()
        let filePath = (downloadsDirectory as NSString).stringByAppendingPathComponent(fileName)

        let operation = HTTPRequestOperation(request: request)
        operation.statusMessage = NSLocalizedString("Downloading..", comment: "")
        operation.showProgressHUD = true
        operation.outputStream = NSOutputStream(toFileAtPath: filePath, append: true)
        
//        var previousPrintedProgressValue = -1.0
        operation.setDownloadProgressBlock { (bytesRead, totalBytesRead, totalBytesExpectedToRead) -> Void in
            let progressValue = Double(totalBytesRead) / Double(totalBytesExpectedToRead)
            
//            if progressValue != previousPrintedProgressValue {
//                previousPrintedProgressValue = progressValue
//                let tbrString = NSByteCountFormatter.stringFromByteCount(Int64(totalBytesRead), countStyle: .File)
//                let tberString = NSByteCountFormatter.stringFromByteCount(Int64(totalBytesExpectedToRead), countStyle: .File)
//                NSLog("%.1f%% (%@ / %@)", progressValue * 100, tbrString, tberString)
//            }
            
            if progress != nil { progress!(progressValue) }
        }
        
        operation.setCompletionBlockWithSuccess({ (operation, responseObject) -> Void in
            if success != nil { success!(filePath) }
        }, failure: { (operation, error) -> Void in
            if failure != nil { failure!(error) }
        })
        NSOperationQueue.mainQueue().addOperation(operation)
    }

}
