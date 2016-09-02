//
//  TodoTableViewCell.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 29.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class TodoTableViewCell: UITableViewCell {

    @IBOutlet weak var dateButton: SelectSuggestionButton!
    @IBOutlet weak var assignedPersonButton: UIButton!
    @IBOutlet weak var titleTextField: TodoNameTextField!
    @IBOutlet weak var selectedButton: SelectSuggestionButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedButton.backgroundColor = UIColor.clearColor()
        self.selectedButton.layer.cornerRadius = 5
        self.selectedButton.layer.borderWidth = 1
        self.selectedButton.layer.borderColor = UIColor(red: 228/255.0, green: 241/255.0, blue: 240/255.0, alpha: 1.0).CGColor
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
