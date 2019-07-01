//
//  GameItemCell.swift
//  VNGGameBook
//
//  Created by frank.zheng on 2019/4/26.
//  Copyright © 2019 Vungle Inc. All rights reserved.
//

import UIKit
import Kingfisher

class GameItemCell: UITableViewCell {
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let thumbImageView = UIImageView()
    let adStateLabel = UILabel()
    
    let kAdState = "adState"
    
    private var kvoCtx = 0
    
    var _gameItem: GameItem?
    
    var gameItem: GameItem? {
        set {
            
            //remove kvo from old item
            unregisterKVO(_gameItem)
            
            _gameItem = newValue
            
            //register kvo for newValue
            registerKVO(_gameItem)
            
            updateViews()
        }
        
        get {
            return _gameItem
        }
        
    }
    
    deinit {
        unregisterKVO(_gameItem)
    }
    
    func registerKVO(_ item:GameItem?) {
        item?.addObserver(self, forKeyPath: kAdState, options:[.new, .old], context: &kvoCtx)
        
    }
    
    func unregisterKVO(_ item:GameItem?) {
        item?.removeObserver(self, forKeyPath: kAdState)
    }
    
    func updateAdStateText() {
        var stateStr = ""
        if gameItem?.adState == GameAdState.loading {
            stateStr = "loading"
        } else if gameItem?.adState == GameAdState.loaded {
            stateStr = "ready"
        } else if gameItem?.adState == GameAdState.loadFailed {
            stateStr = "failed"
        }
        adStateLabel.text = stateStr
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoCtx && keyPath == kAdState {
            updateAdStateText()
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    func addSubViews() {
        thumbImageView.contentMode = .scaleAspectFill
        thumbImageView.clipsToBounds = true
        thumbImageView.layer.cornerRadius = 4.0
        
        addSubview(titleLabel)
        addSubview(thumbImageView)
        addSubview(subtitleLabel)
        addSubview(adStateLabel)
    }
    
    
    func updateViews() {
        
        titleLabel.text = gameItem?.title
        titleLabel.font = UIFont.systemFont(ofSize: 24.0)
        titleLabel.numberOfLines = 1
        
        thumbImageView.kf.setImage(with: gameItem?.thumbURL)
        
        subtitleLabel.text = gameItem?.subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14.0)
        subtitleLabel.numberOfLines = 0
        
        adStateLabel.font = UIFont.systemFont(ofSize: 12.0)
        adStateLabel.textColor = UIColor.gray
        adStateLabel.numberOfLines = 1
        adStateLabel.textAlignment = .right
        updateAdStateText()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let thumbHeight: CGFloat = 200
        let padding: CGFloat = 16
        
        let widthWithPadding = bounds.width - (2*padding)
        
        let stateWidth:CGFloat = 42
        let stateHeight:CGFloat = 30
        adStateLabel.frame = CGRect(x: bounds.width - padding - stateWidth, y: padding,
                                     width: stateWidth, height: stateHeight)
        
        // Size
        let titleSize = titleLabel.sizeThatFits(CGSize(width: widthWithPadding - padding - stateWidth, height: .infinity))
        titleLabel.bounds = CGRect(x: 0, y: 0, width: titleSize.width, height: titleSize.height)
        
        let subtitleSize = subtitleLabel.sizeThatFits(CGSize(width: widthWithPadding, height: .infinity))
        subtitleLabel.bounds = CGRect(x: 0, y: 0, width: subtitleSize.width, height: subtitleSize.height)
        
        thumbImageView.bounds = CGRect(x: 0, y: 0, width: widthWithPadding, height: thumbHeight)
        
        // Center
        titleLabel.center = CGPoint(x: titleLabel.bounds.width/2.0 + padding, y: padding + titleLabel.bounds.height/2.0)
        
        let imageYCenter = titleLabel.frame.origin.y + titleSize.height + padding + thumbHeight/2.0
        thumbImageView.center = CGPoint(x: bounds.width/2.0, y: imageYCenter)
        
        let subtitleYCenter = thumbImageView.frame.origin.y + thumbImageView.bounds.height + padding + subtitleSize.height/2.0
        subtitleLabel.center = CGPoint(x: subtitleLabel.bounds.width/2.0 + padding, y: subtitleYCenter)
    }
    
    class func height(for gameItem: GameItem) -> CGFloat {
        let thumbHeight: CGFloat = 200
        let padding: CGFloat = 16
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24.0)
        label.text = gameItem.title
        let titleHeight = label.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 32, height: .infinity)).height
        
        label.text = gameItem.subtitle
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.numberOfLines = 0
        let subtitleHeight = label.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 32, height: .infinity)).height
        
        return padding + titleHeight + padding + thumbHeight + padding + subtitleHeight + padding
    }

}
