//
//  GameAdDownloader.swift
//  VNGGameBook
//
//  Created by frank.zheng on 2019/5/6.
//  Copyright © 2019 Vungle Inc. All rights reserved.
//

import Foundation
import Alamofire

protocol GameAdDownloaderDelegate : class {
    func downloadDidStart(downloader: GameAdDownloader)
    func downloadProgressDidUpdate(downloader: GameAdDownloader, progress: Progress)
    func downloadDidComplete(downloader: GameAdDownloader, localFileURL:URL?, error: Error?)
}

class GameAdDownloader {
    var delegates = WeakArray<GameAdDownloaderDelegate>()
    var downloadProgress: Progress?
    var url: URL?
    
    init() {
        
    }
    
    func addDelegate(_ delegate:GameAdDownloaderDelegate) {
        delegates.add(delegate)
    }
    
    func removeDelegate(_ delegate:GameAdDownloaderDelegate) {
        delegates.remove(delegate)
    }
    
    func download(url: URL) {
        //start to download file and use delegate to notify the status out
        self.url = url
        guard let cacheFolderURL = GameAdCache.shared.cacheFolderURL
            else {
                return
        }
        
        let destination: DownloadRequest.Destination = { _, _ in
            let filename = url.lastPathComponent
            let fileURL = cacheFolderURL.appendingPathComponent(filename)
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        AF.download(url, to:destination)
            .downloadProgress { progress in
                //notify progress
                self.downloadProgress = progress
                self.delegates.excute { delegate in
                    delegate?.downloadProgressDidUpdate(downloader: self, progress: progress)
                }
            }
            .response { response in
                //notify complete
                self.delegates.excute { delegate in
                    delegate?.downloadDidComplete(downloader: self,
                                                  localFileURL: response.fileURL,
                                                  error: response.error)
                    
                }
        }
        
        self.delegates.excute { delegate in
            delegate?.downloadDidStart(downloader: self)
        }
        
    }
    
}
