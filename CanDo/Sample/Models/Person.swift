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
    var personId : Int!
    var avatar: String!
    //debug
    var selected: Bool!
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
    
    
    init(name: String?, personId: Int, selected: Bool = false, avatar:String? ) {
        self.name = name ?? "Anyone"
        self.name = name == "" ? "Anyone" : self.name
        self.personId = personId
        self.selected = selected
        self.avatar = avatar ?? ""
        
        
    }

    
    
}
