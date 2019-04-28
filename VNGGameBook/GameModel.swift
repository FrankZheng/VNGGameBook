//
//  GameModel.swift
//  VNGGameBook
//
//  Created by frank.zheng on 2019/4/28.
//  Copyright © 2019 Vungle Inc. All rights reserved.
//

import Foundation

class GameModel {
    static let shared = GameModel()
    
    let gameItems = GameItem.localGames()
    
    private init() {
        
    }
    
    
}
