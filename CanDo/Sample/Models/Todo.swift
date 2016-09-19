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
    var updatedAt: NSDate?
    var createdAt: NSDate?
    var date: NSDate?
    var time: NSDate!
    var status: String!
    var todoId: Int!
    var assignedTo: Person!
    
    
    var footer: TodoTableSectionFooter?
    
    //debug
  //  var assignedPerson :Person!
  //  var finished: Bool! = false
    
    
    // MARK: Initialization
    //debug
    /*
    init(name: String, list: List, finished: Bool = false) {
        self.name = name
        self.list = list
        self.finished = finished
    }
 */
    
    
    
  
    
    // MARK: Initialization
    
    init(name: String?, list: List, updatedAt: String?, createdAt: String?, date: String?, time: String?, status: String?, todoId: Int, assignedTo: Person) {
        
      
        self.name = name ?? ""
        self.list = list
        self.updatedAt = updatedAt != nil ? stringCreateUpdateToDate(updatedAt!) : nil
        self.createdAt = createdAt != nil ? stringCreateUpdateToDate(createdAt!) : nil
        self.date = date != nil ? stringDateToDate(date!) : nil
        self.time = time != nil ? stringTimeToDate(time!)  : nil
        self.status = status ?? Helper.TodoStatusKey.kActive
        self.todoId = todoId
        self.assignedTo = assignedTo
        
        
        
    }
    
    
    func stringCreateUpdateToDate(stringDate: String) -> NSDate {
        return NSDate(fromString:stringDate, format: .Custom("yyyy-MM-dd HH:mm:ss"))
    }
    func stringDateToDate(stringDate: String) -> NSDate {
        return NSDate(fromString:stringDate, format: .Custom("yyyy-MM-dd"))
    }
    func stringTimeToDate(stringDate: String) -> NSDate {
        return NSDate(fromString:stringDate, format: .Custom("HH:mm:ss"))
    }

    
    
}
