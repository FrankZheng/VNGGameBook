//
//  GameItemCell.swift
//  VNGGameBook
//
//  Created by frank.zheng on 2019/4/26.
//  Copyright © 2019 Vungle Inc. All rights reserved.
//

import UIKit

class GameItemCell: UITableViewCell {
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let thumbImageView = UIImageView()
    
    var gameItem: GameItem? {
        didSet {
            updateViews()
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
    }
    
    
    func updateViews() {
        
        titleLabel.text = gameItem?.title
        titleLabel.font = UIFont.systemFont(ofSize: 24.0)
        
        let image = UIImage(named: (gameItem?.thumbURL.path)!)
        thumbImageView.image = image
        
        subtitleLabel.text = gameItem?.subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14.0)
        subtitleLabel.numberOfLines = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let thumbHeight: CGFloat = 200
        let padding: CGFloat = 16
        
        let widthWithPadding = bounds.width - (2*padding)
        
        // Size
        let titleSize = titleLabel.sizeThatFits(CGSize(width: widthWithPadding, height: .infinity))
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
