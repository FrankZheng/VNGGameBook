//
//  GameVideoViewController.swift
//  VNGGameBook
//
//  Created by frank.zheng on 2019/4/28.
//  Copyright © 2019 Vungle Inc. All rights reserved.
//

import UIKit
import AVKit

class GameVideoViewController: UIViewController {
    var playerItem : AVPlayerItem?
    var player: AVPlayer?
    var gameItem: GameItem?
    
    init(gameItem: GameItem) {
        self.gameItem = gameItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    func play() {
        player?.play()
    }
    
    @objc func playerDidFinished(notification: Notification) {
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let item = gameItem {
            playerItem = AVPlayerItem(url:item.videoURL)
            player = AVPlayer(playerItem: playerItem)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.view.bounds
            self.view.layer.addSublayer(playerLayer)
            
            
            //register the notification when video play completed
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.playerDidFinished(notification:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: playerItem)
            }
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
