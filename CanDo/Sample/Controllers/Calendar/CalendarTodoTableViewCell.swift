//
//  CalendarTodoTableViewCell.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 12.09.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class CalendarTodoTableViewCell: UITableViewCell {

    @IBOutlet weak var timeButton: ButtonWithIndexPath!
    @IBOutlet weak var todoName: TodoNameTextField!
    @IBOutlet weak var assignPersonButton: ButtonWithIndexPath!
    @IBOutlet weak var dateButton: ButtonWithIndexPath!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
