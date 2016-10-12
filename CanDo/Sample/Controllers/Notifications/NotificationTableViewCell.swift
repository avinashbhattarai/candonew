//
//  NotificationTableViewCell.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 08.09.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    internal var aspectConstraint : NSLayoutConstraint? {
        didSet {
            
            if oldValue != nil {
                contentImageView.removeConstraint(oldValue!)
            }
            if aspectConstraint != nil {
                contentImageView.addConstraint(aspectConstraint!)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        aspectConstraint = nil
    }
    
    func setPostedImage(_ image : UIImage?) {
        
        if (image != nil) {
            let aspect = image!.size.width / image!.size.height
            
            aspectConstraint = NSLayoutConstraint(item: contentImageView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: contentImageView, attribute: NSLayoutAttribute.height, multiplier: aspect, constant: 0.0)
            
            contentImageView.image = image
        }else{
            contentImageView.image = UIImage()
        }
        
        
       
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
