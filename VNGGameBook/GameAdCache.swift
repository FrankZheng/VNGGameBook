//
//  GameAdCache.swift
//  VNGGameBook
//
//  Created by frank.zheng on 2019/5/6.
//  Copyright © 2019 Vungle Inc. All rights reserved.
//

import Foundation

class GameAdCache {
    static let shared = GameAdCache()
    
    var cacheFolderURL: URL?
    
    private init() {
        
    }
    
    func setup() -> Bool {
        //create cached folder if not exists
        let fm = FileManager.default
        let documentsURL = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        cacheFolderURL = documentsURL.appendingPathComponent("ad-cache")
        do {
            try fm.createDirectory(at: cacheFolderURL!, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create folder for ad cache\(error)")
            return false
        }
        return true
    }
    
    func getLocalPath(url: URL) -> URL? {
        return nil
    }
    
    
}
