//
//  GameItem.swift
//  VNGGameBook
//
//  Created by frank.zheng on 2019/4/26.
//  Copyright © 2019 Vungle Inc. All rights reserved.
//

import Foundation


class GameItem : NSObject {
    let title: String
    let subtitle: String
    let url: URL
    let thumbURL: URL
    
    init(title:String, subtitle:String, url:URL, thumbURL:URL) {
        self.title = title
        self.subtitle = subtitle
        self.url = url
        self.thumbURL = thumbURL
        super.init()
    }
    
    class func localGames() -> [GameItem] {
        var games = [GameItem]()
        
        let titles = ["Kick the Buddy", "Guitar - Chords, Tabs & Games", "Tank Stars", "Pick Me Up™",
                      "Spill It!", "Pinatamasters", "Idle Farming Empire"]
        let subtitles = ["Explode, destroy, fire, shoot, freeze, send the power of the Gods and don't even think about stopping! You now have a virtually limitless arsenal: rockets, grenades, automatic rifles, torture instruments… and even a NUCLEAR BOMB!",
                         "Playing the guitar has never been easier with #1 guitar playing app! Learn chords and create music right on you device!",
                         "Tanks at your fingertips. Choose a weapon – a simple missile to an atomic bomb – and find the right shooting angle and destroy your opponents. Make the right shot quickly or you’ll die!",
                         "Have you ever wanted to be a ride share driver? Pick up and drop off customers to earn money and level up. Explore the world and discover new monuments.",
                         "Drop balls to knock over glasses and spill everything! Use your brain and think outside of the box to complete all levels. Unlock skins, themes, and new stuff along the way.",
                         "Fight colorful and crazy pinatas! Travel all over the world. Purchase and upgrade various weapons to become stronger. Smash those cute pinatas, and get all the coins they have!",
                         "Grow and automate the most profitable farming empire of all time! Make smart investments into a wide variety of whacky crops and animals and you'll earn millions in no time. Can you build the most profitable farming business in the universe?"]
        let names = ["KillTheBuddy", "guitar", "TankStars", "PickMeUp", "SpillIt", "Pinatamasters", "IdleFarmingEmpire"]
        
        for(index, name) in names.enumerated() {
            let title = titles[index]
            let subtitle = subtitles[index]
            let urlPath = Bundle.main.path(forResource: name, ofType: "mp4")!
            let url = URL(fileURLWithPath: urlPath)
            let thumbURLPath = Bundle.main.path(forResource: name, ofType: "png")!
            let thumbURL = URL(fileURLWithPath: thumbURLPath)
            
            let game = GameItem(title: title, subtitle: subtitle, url: url, thumbURL: thumbURL)
            games.append(game)
        }
        return games
    }
    
}
