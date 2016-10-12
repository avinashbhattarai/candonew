//
//  FacebookSignupButton.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 17.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class FacebookSignupButton: UIButton {
    
     override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
    
    var r: CGRect = contentRect;
    
    r.size = CGSize(width: 12, height: 24);
    
    r.origin.x = 15;
    
    r.origin.y = (contentRect.size.height - r.size.height) / 2.0;
    
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
