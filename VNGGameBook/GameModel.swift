//
//  GameModel.swift
//  VNGGameBook
//
//  Created by frank.zheng on 2019/4/28.
//  Copyright © 2019 Vungle Inc. All rights reserved.
//

import Foundation
import Alamofire

protocol GameModelDelegate : class {
    func onGameItemsLoaded(error: Error?)
}

class GameModel {
    static let shared = GameModel()
    weak var delegate: GameModelDelegate?
    let kAPI_BASE: URL = URL(string:"https://vungle-gamebook.firebaseapp.com/api")!
    let kAPI_GAME_ITEMS: URL
    
    var gameItems: [GameItem] = []
    
    private init() {
        kAPI_GAME_ITEMS = kAPI_BASE.appendingPathComponent("gameItems")
    }
    
    func loadGameItems() {
        AF.request(kAPI_GAME_ITEMS).validate().responseJSON { [weak self] response in
            switch response.result {
            case .success(let res):
                //print("\(res)")
                guard let jsonArray = res as? [[String:AnyObject]] else {
                    return
                }
                self?.parseResponse(jsonArray: jsonArray)
                
                self?.delegate?.onGameItemsLoaded(error: nil)
            case .failure(let error):
                print("\(error)")
                self?.delegate?.onGameItemsLoaded(error: error)
            }
        }
    }
    
    func parseResponse(jsonArray:[[String:AnyObject]]) {
        var index = 1
        for json in jsonArray {
            guard let gameItem = GameItem.itemFromJson(json: json, withPlacementId: "LOCAL\(index)") else {
                continue
            }
            gameItems.append(gameItem)
            index += 1
        }
        print("there are \(gameItems.count) items")
    }
    
    
}
