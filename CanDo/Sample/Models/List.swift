//
//  List.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 29.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import Foundation
import UIKit

class List {
    
    // MARK: Properties
    var listId: Int!
    var name: String!
    var todos: [Todo]?
    
    
    
    // MARK: Initialization
    
    init(name: String?, listId:Int) {
        self.name = name ?? ""
        self.listId = listId
     }
    
}
