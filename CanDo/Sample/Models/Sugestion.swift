//
//  Sugestion.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 23.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import Foundation
import UIKit
class Suggestion {
    
    // MARK: Properties
    
    var name: String!
    var items: NSArray!
    var collapsed: Bool! = false
    var addAllSelected :Bool! = false
    
    
    // MARK: Initialization
    
    init(name: String, items: NSArray, collapsed: Bool = false , addAllSelected: Bool = false) {
        self.name = name
        self.items = items
        self.collapsed = collapsed
        self.addAllSelected = addAllSelected
    }
    
}

