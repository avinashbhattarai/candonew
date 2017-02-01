//
//  ScreenTypeHelper.swift
//  CanDo
//
//  Created by Svyat Zubyak on 1/26/17.
//  Copyright © 2017 Svyat Zubyak MacBook. All rights reserved.
//

import Foundation
extension UIScreen {
    
    var isPhone4: Bool {
        return self.nativeBounds.size.height == 960;
    }
    
    var isPhone5: Bool {
        return self.nativeBounds.size.height == 1136;
    }
    
    var isPhone6: Bool {
        return self.nativeBounds.size.height == 1334;
    }
    
    var isPhone6Plus: Bool {
        return self.nativeBounds.size.height == 2208;
    }
    
}
