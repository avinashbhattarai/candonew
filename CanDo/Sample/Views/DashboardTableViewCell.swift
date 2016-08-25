//
//  DashboardTableViewCell.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 18.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class DashboardTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView?.frame = CGRect(x: 40, y: (imageView?.frame.origin.y)!, width: (imageView?.frame.size.width)!, height: (imageView?.frame.size.height)!)
        self.textLabel?.frame = CGRect(x: 104, y: (textLabel?.frame.origin.y)!, width: (textLabel?.frame.size.width)!, height: (textLabel?.frame.size.height)!)
        self.accessoryView?.frame = CGRect(x: (accessoryView?.frame.origin.x)!-20, y: (accessoryView?.frame.origin.y)!, width: (accessoryView?.frame.size.width)!, height: (accessoryView?.frame.size.height)!)
        self.textLabel?.font = UIFont(name:"MuseoSansRounded-700", size: 26)
        self.textLabel?.textColor = UIColor.whiteColor()
        self.imageView?.contentMode = .Center

    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
