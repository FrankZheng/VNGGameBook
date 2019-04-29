//
//  WebServer.swift
//  VNGGameBook
//
//  Created by frank.zheng on 2019/4/25.
//  Copyright © 2019 Vungle Inc. All rights reserved.
//

import Foundation

extension String {
    func stringByReplacingWithVariables(_ variables:[String:String?]) -> String {
        var res: String = self
        for key in variables.keys {
            if let value = variables[key] {
                res = res.replacingOccurrences(of: key, with: value!)
            }
        }
        return res
    }
}

class WebServer {
    
    static let shared = WebServer()
    
    var serverURL:URL?
    
    let gameModel = GameModel.shared
    
    let staticFolder = "static"
    
    private init() {
        
    }
    
    func start() {
        let webServer = GCDWebServer()
        
        // -> /config
        webServer.addHandler(forMethod: "POST", path: "/config", request: GCDWebServerRequest.self) { request in
            return self.sdkConfigResponse(request)!
        }
        
        // -> /ads
        webServer.addHandler(forMethod: "POST", path: "/ads", request: GCDWebServerDataRequest.self) { request in
            return self.adsResponse(request as! GCDWebServerDataRequest)!
        }
        
        webServer.addHandler(forMethod: "POST", path: "/ok", request: GCDWebServerRequest.self) { _ in
            return self.okResponse()!
        }
        
        //host static files
        let appBundlePath = Bundle.main.bundlePath
        webServer.addGETHandler(forBasePath: "/\(staticFolder)/",
                                directoryPath: appBundlePath,
                                indexFilename: "",
                                cacheAge: 0,
                                allowRangeRequests: true)
        
        //start web server
        webServer.start(withPort:8091, bonjourName: nil)
        serverURL = webServer.serverURL
    }
    
    func serverURL(withPath path:String) -> URL? {
        return serverURL?.appendingPathComponent(path)
    }
    
    func staticURL(withPath path:String) -> URL? {
        return serverURL?.appendingPathComponent(staticFolder).appendingPathComponent(path)
    }
    
    func okResponse() -> GCDWebServerResponse? {
        let response: [String:Any] = [
            "msg": "ok",
            "code": 200
        ]
        return GCDWebServerDataResponse(jsonObject: response)
    }
    
    func sdkConfigResponse(_ request: GCDWebServerRequest) -> GCDWebServerResponse? {
        guard let configPath = Bundle.main.path(forResource: "config", ofType: "json") else {
            return nil
        }
        guard let configStr = try? String(contentsOf: URL(fileURLWithPath: configPath), encoding: .utf8) else {
            return nil
        }
        let variables = [
            "${newURL}": self.serverURL(withPath: "ok")?.absoluteString,
            "${adsURL}": self.serverURL(withPath: "ads")?.absoluteString,
            "${reportURL}":self.serverURL(withPath: "ok")?.absoluteString,
        ]
        let replacedStr = configStr.stringByReplacingWithVariables(variables)
        guard let data = replacedStr.data(using: .utf8) else {
            return nil
        }
        guard var json  = try? JSONSerialization.jsonObject(with:data, options: .mutableContainers) as? [String:AnyObject] else {
            return nil
        }
        guard var placements: [[String:AnyObject]] = json["placements"] as? [[String:AnyObject]] else {
            return nil
        }
        let local: [String:AnyObject] = placements[1]
        for gameItem in gameModel.gameItems {
            var copied = local
            copied["reference_id"] = gameItem.placementId as AnyObject
            placements.append(copied)
        }
        json["placements"] = placements as AnyObject
        return GCDWebServerDataResponse(jsonObject: json)
    }
    
    
    func adsResponse(_ request: GCDWebServerDataRequest) -> GCDWebServerResponse? {
        guard let path = Bundle.main.path(forResource: "ads", ofType: "json") else {
            return nil
        }
        //get the reference id from the request
        guard let json = request.jsonObject as? [String:AnyObject] else {
            return nil
        }
        guard let placements = json["request"]?["placements"] as? [String] else {
            return nil
        }
        let placementId = placements[0]
        //todo: add error handling here
        let gameItem : GameItem = gameModel.gameItems.filter { (item:GameItem) -> Bool in
            return item.placementId == placementId
        }[0]
        let variables = [
            "${placementId}": placementId,
            "${expiry}": String(getNotExpiredTime()),
            "${videoURL}": staticURL(withPath: gameItem.url.lastPathComponent)?.absoluteString,
            "${postBundle}": staticURL(withPath: gameItem.endcardURL.lastPathComponent)?.absoluteString,
            "${storeURL}": gameItem.storeURL
        ]
        guard let str = try? String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8) else {
            return nil
        }
        let replacedStr = str.stringByReplacingWithVariables(variables)
        let data = replacedStr.data(using: .utf8)
        do {
            let response  = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
            return GCDWebServerDataResponse(jsonObject: response)
        } catch {
            print("Failed to encode json \(error)")
            return nil
        }
    }
    
    func getNotExpiredTime() -> Int {
        let daySeconds = TimeInterval(3600.0 * 24)
        let now = NSDate()
        let expiredDate = now.addingTimeInterval(daySeconds)
        return Int(expiredDate.timeIntervalSince1970)
    }
}
