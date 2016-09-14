//
//  Tip.swift
//  CanDo
//
//  Created by Svyat Zubyak on 9/14/16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import Foundation
import UIKit
class Tip {
    
    // MARK: Properties
    
    var title: String!
    var cover: String!
    var url: String!
    
    // MARK: Initialization
    
    init(title: String?, cover: String?, url: String?) {
        
        self.title = title ?? ""
        self.cover = cover ?? ""
        self.url = url ?? ""
       
    }
    
}
