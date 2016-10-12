//
//  DateUnderlineButton.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 01.09.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class DateUnderlineButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        
        var r: CGRect = contentRect;
        
        r.size = CGSize(width: 42, height: 2);
        
        r.origin.x = contentRect.size.width-42;
        
        r.origin.y = contentRect.size.height;
        
        return r;
    }


}
