//
//  GameItem.swift
//  VNGGameBook
//
//  Created by frank.zheng on 2019/4/26.
//  Copyright © 2019 Vungle Inc. All rights reserved.
//

import Foundation
@objc enum GameAdState : Int {
    case undownload, downloading, downloadFailed, downloaded, loading, loaded, loadFailed, playing
}


class GameItem : NSObject, GameAdDownloaderDelegate {
    let title: String
    let subtitle: String
    let videoURL: URL
    let thumbURL: URL
    let endcardURL: URL
    let storeURL: String
    let placementId: String
    
    var videoLocalPath: URL?
    var endcardLocalPath: URL?
    
    var videoDownloader: GameAdDownloader?
    var endcardDownloader: GameAdDownloader?
    
    var isAdCached: Bool {
        get {
            return videoLocalPath != nil && endcardLocalPath != nil
        }
    }
    
    @objc dynamic var adState = GameAdState.undownload
    
    
    init(title:String, subtitle:String, videoURL:URL, thumbURL:URL, endcardURL:URL, storeURL:String, placementId:String) {
        self.title = title
        self.subtitle = subtitle
        self.videoURL = videoURL
        self.thumbURL = thumbURL
        self.endcardURL = endcardURL
        self.storeURL = storeURL
        self.placementId = placementId
        super.init()
    }
    
    class func itemFromJson(json:[String:AnyObject], withPlacementId pID:String) -> GameItem? {
        guard let title = json["title"] as? String,
            let subtitle = json["subtitle"] as? String,
            let videoURLStr = json["videoURL"] as? String, let videoURL = URL(string: videoURLStr),
            let thumbURLStr = json["thumbURL"] as? String, let thumbURL = URL(string: thumbURLStr),
            let endcardURLStr = json["endcardURL"] as? String, let endcardURL = URL(string: endcardURLStr),
            let storeURL = json["storeURL"] as? String
            else {
                return nil
        }
        
        return GameItem(title: title, subtitle: subtitle, videoURL: videoURL, thumbURL: thumbURL,
                        endcardURL: endcardURL, storeURL: storeURL, placementId: pID)
    }
    
    func download() {
        if videoLocalPath == nil {
            //download video
            videoDownloader = GameAdDownloader()
            videoDownloader?.addDelegate(self)
            videoDownloader?.download(url: videoURL)
        }
        
        if endcardLocalPath == nil {
            //download end card concurrently for now
            endcardDownloader = GameAdDownloader()
            endcardDownloader?.addDelegate(self)
            endcardDownloader?.download(url: endcardURL)
        }
    }
    
    
    func downloadDidStart(downloader: GameAdDownloader) {
        if adState != .downloading {
            adState = .downloading
        }
    }
    
    func downloadProgressDidUpdate(downloader: GameAdDownloader, progress: Progress) {
        //how to notify the progress out?
        print("download progress updated, current:\(progress.completedUnitCount) / total:\(progress.completedUnitCount)")
    }
    
    func downloadDidComplete(downloader: GameAdDownloader, localFileURL:URL?, error: Error?) {
        if downloader === videoDownloader {
            print("video downloaded")
            if localFileURL != nil && error == nil {
                self.videoLocalPath = localFileURL
            } else {
                adState = .downloadFailed
            }
        }
        
        if downloader === endcardDownloader {
            print("end card downloaded")
            if localFileURL != nil && error == nil {
                self.endcardLocalPath = localFileURL
            } else {
                adState = .downloadFailed
            }
        }
        
        //if both files are downloaded
        if isAdCached {
            adState = .downloaded
        }
    }
}
