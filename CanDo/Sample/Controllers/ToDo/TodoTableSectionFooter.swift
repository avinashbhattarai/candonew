//
//  TodoTableSectionFooter.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 01.09.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class TodoTableSectionFooter: UITableViewHeaderFooterView {

    @IBOutlet weak var addNewTodoButton: UIButton!
    @IBOutlet weak var addTodoButton: AddPhotoButton!
    @IBOutlet weak var addTodoView: UIView!
    @IBOutlet weak var selectedBtton: UIButton!
    @IBOutlet weak var titleTextField: AddTodoTitleTextField!
    @IBOutlet weak var dateButton: DateUnderlineButton!
    @IBOutlet weak var assignTodoButton: AssignTodoUndelineButton!
    @IBOutlet weak var undelineImage: UIImageView!
    var newTodo:Todo?
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
