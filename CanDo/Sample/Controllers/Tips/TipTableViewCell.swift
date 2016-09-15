//
//  TipTableViewCell.swift
//  CanDo
//
//  Created by Svyat Zubyak on 9/14/16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class TipTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var readMoreButton: ButtonWithIndexPath!
    
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
    
    func setPostedImage(image : UIImage?) {
        
        if (image != nil) {
            let aspect = image!.size.width / image!.size.height
            
            aspectConstraint = NSLayoutConstraint(item: coverImageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: coverImageView, attribute: NSLayoutAttribute.Height, multiplier: aspect, constant: 0.0)
            
            coverImageView.image = image
        }else{
            coverImageView.image = UIImage()
        }
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
