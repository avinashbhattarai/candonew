//
//  AssignTodoUndelineButton.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 01.09.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class AssignTodoUndelineButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        
        var r: CGRect = contentRect;
        
        r.size = CGSize(width: 108, height: 2);
        
        r.origin.x = 0;
        
        r.origin.y = contentRect.size.height;
        
        return r;
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect
    {
        var r: CGRect = contentRect;
        
        r.origin.x = 0;
        // r.size.height=25;
        // r.size.width = 200;
        
        return r;
    }


}
