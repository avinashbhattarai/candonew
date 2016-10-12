//
//  PersonTableViewCell.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 04.09.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class PersonTableViewCell: UITableViewCell {

    @IBOutlet weak var personAvatar: UIImageView!
    @IBOutlet weak var personTitle: UILabel!
    @IBOutlet weak var selectButton: ButtonWithIndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
