//
//  TodoTableViewCell.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 29.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class TodoTableViewCell: UITableViewCell {

    @IBOutlet weak var dateButton: ButtonWithIndexPath!
    @IBOutlet weak var assignedPersonButton: ButtonWithIndexPath!
    @IBOutlet weak var titleTextField: TodoNameTextField!
    @IBOutlet weak var selectedButton: ButtonWithIndexPath!
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedButton.backgroundColor = UIColor.clear
        selectedButton.layer.cornerRadius = 5
        selectedButton.layer.borderWidth = 1
        selectedButton.layer.borderColor = UIColor(red: 228/255.0, green: 241/255.0, blue: 240/255.0, alpha: 1.0).cgColor
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
