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
    var updated: NSDate!
    var createdAt: NSDate!
    var date: NSDate!
    var time: String!
    var status: Int!
    var todoId: Int!
    var assignedPerson :Person!
    
    
    var finished: Bool! = false
    
    
    // MARK: Initialization
    
    init(name: String, list: List, finished: Bool = false) {
        self.name = name
        self.list = list
        self.finished = finished
    }
    
}
