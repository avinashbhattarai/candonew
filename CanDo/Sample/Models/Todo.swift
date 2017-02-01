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
    var updatedAt: Date?
    var createdAt: Date?
    var date: Date?
    var time: Date!
    var status: String!
    var todoId: Int!
    var assignedTo: Person!
    
    
    var footer: TodoTableSectionFooter?
    

    
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
    
    
    func stringCreateUpdateToDate(_ stringDate: String) -> Date {
        return Date(fromString: stringDate, format: .custom("yyyy-MM-dd HH:mm:ss"))
    }
    func stringDateToDate(_ stringDate: String) -> Date {
        return Date(fromString: stringDate, format: .custom("yyyy-MM-dd"))
    }
    func stringTimeToDate(_ stringDate: String) -> Date {
        return Date(fromString: stringDate, format: .custom("HH:mm:ss"))
    }

    
    
}
