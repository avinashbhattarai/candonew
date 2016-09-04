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
    
    func setUnderlineTitle(title: String?) {
        self.setTitle(title, forState: .Normal)
        self.setAttributedTitle(self.attributedString(), forState: .Normal)
    }
    
    private func attributedString() -> NSAttributedString? {
        let attributes = [
            NSFontAttributeName : UIFont(name: "MuseoSansRounded-300", size: 18)!,
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue
        ]
        let attributedString = NSAttributedString(string: self.currentTitle!, attributes: attributes)
        return attributedString
    }
}