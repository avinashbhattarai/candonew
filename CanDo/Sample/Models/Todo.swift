//
//  Todo.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 29.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import Foundation
import UIKit
class Todo {
    
    // MARK: Properties
    
    var name: String!
    var list: List!
    var finished: Bool! = false
    var assignedPerson :Person?
    var date: NSDate?
    
    
    
    // MARK: Initialization
    
    init(name: String, list: List, finished: Bool = false , assignedPerson: Person, date:NSDate ) {
        self.name = name
        self.list = list
        self.finished = finished
        self.assignedPerson = assignedPerson
        self.date = date
    }
    
}
