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
    var suggestionId: Int!
    var collapsed: Bool! = false
    var suggestionItems: [SuggestionsItem]?
    
    
    // MARK: Initialization
    
    init(name: String?, suggestionId: Int, collapsed: Bool = false ) {
        self.name = name ?? ""
        self.suggestionId = suggestionId
        self.collapsed = collapsed
    }
    
}

