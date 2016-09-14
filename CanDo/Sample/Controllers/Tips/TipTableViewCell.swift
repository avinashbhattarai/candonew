//
//  TipTableViewCell.swift
//  CanDo
//
//  Created by Svyat Zubyak on 9/14/16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
import SDWebImage
class TipTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var readMoreButton: UIButton!
 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    internal var aspectConstraint : NSLayoutConstraint? {
        didSet {
            
            if oldValue != nil {
                coverImageView.removeConstraint(oldValue!)
            }
            if aspectConstraint != nil {
                coverImageView.addConstraint(aspectConstraint!)
                
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        aspectConstraint = nil
    }
    
    func setPostedImage(imageURL : NSURL?) {
        
        
    
            
            
            SDWebImageManager.sharedManager().downloadImageWithURL(imageURL, options: [], progress: {(receivedSize: Int, expectedSize: Int) -> Void in
                // progression tracking code
                
                }, completed: {(image: UIImage?, error: NSError!, cacheType: SDImageCacheType, finished: Bool!, imageURL: NSURL!) -> Void in
                    // progression tracking code
                    
                    if (image != nil) {
                        let aspect = image!.size.width / image!.size.height
                        
                        self.aspectConstraint = NSLayoutConstraint(item: self.coverImageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.coverImageView, attribute: NSLayoutAttribute.Height, multiplier: aspect, constant: 0.0)
                        
                        self.coverImageView.image = image
                      
                      //  self.coverImageHeight.constant = image!.size.height
                        
                        
                        
                        
                    }else{
                        self.coverImageView.image = UIImage()
                    }

                    
            })
            
            
            
            
        }
        
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
