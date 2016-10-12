//
//  UIButton+UnderlineText.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 04.09.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    func setUnderlineTitle(_ title: String?) {
        self.setTitle(title, for: UIControlState())
        self.setAttributedTitle(self.attributedString(), for: UIControlState())
    }
    
    fileprivate func attributedString() -> NSAttributedString? {
        let attributes = [
            NSFontAttributeName : UIFont(name: "MuseoSansRounded-300", size: 18)!,
            NSForegroundColorAttributeName : UIColor.white,
            NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue
        ] as [String : Any]
        let attributedString = NSAttributedString(string: self.currentTitle!, attributes: attributes)
        return attributedString
    }
}
