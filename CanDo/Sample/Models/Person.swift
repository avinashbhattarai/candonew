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
    var personId : Int
    
    //debug
   // var selected: Bool! = false
   // var avatar: String?
    
    
    
    // MARK: Initialization
    //debug
    /*
    init(name: String, selected: Bool = false, avatar: String ) {
        self.name = name
        self.selected = selected
        self.avatar = avatar
        
        personId = 0
    }
 */
    
    
    init(name: String?, personId: Int ) {
        self.name = name ?? "Anyone"
        print("self.name1 \(self.name)  name1 \(name) ")
        self.name = name == "" ? "Anyone" : self.name
        print("self.name2 \(self.name)  name2 \(name) ")
        self.personId = personId
        
        
    }

    
    
}
