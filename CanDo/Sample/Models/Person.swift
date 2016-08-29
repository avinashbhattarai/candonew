//
//  Person.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 29.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import Foundation
import UIKit
class Person {
    
    // MARK: Properties
    
    var name: String!
    var selected: Bool! = false
    var avatar: String?
    
    
    
    // MARK: Initialization
    
    init(name: String, selected: Bool = false, avatar: String ) {
        self.name = name
        self.selected = selected
        self.avatar = avatar
       
    }
    
}
