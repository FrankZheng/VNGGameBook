//
//  WebServer.swift
//  VNGGameBook
//
//  Created by frank.zheng on 2019/4/25.
//  Copyright © 2019 Vungle Inc. All rights reserved.
//

import Foundation

class WebServer {
    
    static let shared = WebServer()
    
    private init() {
        
    }
    
    func start() {
        let webServer = GCDWebServer()
        
        webServer.addDefaultHandler(forMethod:"GET", request: GCDWebServerRequest.self, processBlock: {request in
            return GCDWebServerDataResponse(html:"<html><body><p>Hello World</p></body></html>")
        })
        
        #if false
        webServer.addHandler(forMethod: "GET", path: "/games", request: GCDWebServerRequest.self) { request in
            let games = [
                ["title":"", "description":"", "videoURL":"", "postBundle":""],
                ["title":"", "description":"", "videoURL":"", "postBundle":""],
                ["title":"", "description":"", "videoURL":"", "postBundle":""],
            ]
            return GCDWebServerDataResponse(jsonObject: games)
        }
        #endif
        
        webServer.start(withPort:8080, bonjourName: "GCD Web Server")
        
        print("Visit \(webServer.serverURL!) in your web browser")
        
    }
    
}
