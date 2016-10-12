//
//  TodoListSectionTextField.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 29.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class TodoListSectionTextField: UITextField {
    
    var indexPath: IndexPath?
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.font = UIFont(name: "MuseoSansRounded-500", size: 24)
        self.tintColor = Helper.Colors.RGBCOLOR(81, green: 85, blue: 102)
        self.textColor = Helper.Colors.RGBCOLOR(81, green: 85, blue: 102)
       
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
