//
//  SuggestionsItem.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 23.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import Foundation
import UIKit
class SuggestionsItem {
    
    // MARK: Properties
    
    var name: String!
    var suggestionItemId: Int!
    var suggestion: Suggestion!
    var selected: Bool!
    
    
    // MARK: Initialization
    
    init(name: String?,suggestionItemId: Int,suggestion: Suggestion, selected: Bool = false) {
        self.name = name ?? ""
        self.suggestionItemId = suggestionItemId
        self.suggestion = suggestion
        self.selected = selected
    }
    
}
