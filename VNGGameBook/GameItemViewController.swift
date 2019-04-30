//
//  GameItemViewController.swift
//  VNGGameBook
//
//  Created by frank.zheng on 2019/4/26.
//  Copyright © 2019 Vungle Inc. All rights reserved.
//

import UIKit
import AVKit

class GameItemViewController: UITableViewController, SDKDelegate {
    var gameItems = [GameItem]()
    let GameItemCellReuseIdentifier = "GameItemCell"
    //used to cache the cell height
    //here use the row index as the key, need clear cache when reload data
    var cellHeightCache = [Int:CGFloat]()
    
    let sdkManager : SDKManagerProtocol = SDKManager.shared()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.estimatedRowHeight = 300
        tableView.register(GameItemCell.classForCoder(), forCellReuseIdentifier: GameItemCellReuseIdentifier)
        self.title = "Game Book"
        
        //register delegate
        sdkManager.add(self)
        
    }
    
    func loadAd(forGameItem item:GameItem?) {
        guard let item = item else {
            return
        }
        let pID = item.placementId
        if !sdkManager.isReady(pID) {
            print("start to load \(pID)")
            sdkManager.loadAd(pID)
            item.adState = GameAdState.loading
        } else {
            print("ad \(pID) already loaded")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return gameItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GameItemCellReuseIdentifier, for: indexPath) as! GameItemCell
        let gameItem = gameItems[indexPath.row]
        cell.gameItem = gameItem
        
        //start to load ad
        loadAd(forGameItem: gameItem)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        if let cachedHeight = cellHeightCache[row] {
            return cachedHeight
        } else {
            let gameItem = gameItems[row]
            let height = GameItemCell.height(for: gameItem)
            print("calculate row height for \(gameItem.title), \(height)")
            cellHeightCache[row] = height
            return height
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //2 Create an AVPlayerViewController and present it when the user taps
        let gameItem = gameItems[indexPath.row]
        
        #if false
        let videoURL = gameItem.url
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        present(playerViewController, animated: true) {
            player.play()
        }
        #elseif false
        let videoViewController = GameVideoViewController(gameItem: gameItem)
        present(videoViewController, animated: true) {
            videoViewController.play()
        }
        #else
        if(sdkManager.isReady(gameItem.placementId)) {
            sdkManager.playAd(gameItem.placementId, viewController: self)
        }
        
        #endif
    }
    
    func findGameItem(byPlacementId pID:String) -> GameItem? {
        let items = gameItems.filter { (gameItem) -> Bool in
            return gameItem.placementId == pID
        }
        return items.count > 0 ? items[0] : nil
    }
    
    // MARK: SDKDelegate methods
    func onAdLoaded(_ placementId: String, error: Error?) {
        let gameItem = findGameItem(byPlacementId: placementId)
        gameItem?.adState = error == nil ? GameAdState.loaded : GameAdState.loadFailed
    }
    
    func onAdDidPlay(_ placementId: String) {
        let gameItem = findGameItem(byPlacementId: placementId)
        gameItem?.adState = GameAdState.playing
    }
    
    func onAdDidClose(_ placementId: String) {
        let gameItem = findGameItem(byPlacementId: placementId)
        gameItem?.adState = GameAdState.unload
        
        loadAd(forGameItem: gameItem)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
