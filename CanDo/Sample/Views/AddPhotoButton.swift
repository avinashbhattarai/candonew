//
//  AddPhotoButton.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 26.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class AddPhotoButton: UIButton {
    
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        
        var r: CGRect = contentRect;
        
        r.size = CGSize(width: 34, height: 34);
        
        r.origin.x = 0;
        
        r.origin.y = (contentRect.size.height - r.size.height) / 2.0;
        
        return r;
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect
    {
        var r: CGRect = contentRect;
        
        r.origin.x = 50;
        // r.size.height=25;
        r.size.width = 200;
        
        return r;
    }


    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
