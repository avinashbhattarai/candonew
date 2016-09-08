//
//  Invite.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 06.09.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import Foundation
import UIKit
class Invite {
    
    // MARK: Properties
    
    var teamId: Int!
    var ownerEmail: String!
    var ownerFirstName: String!
    var ownerLastName: String!
    
    
    // MARK: Initialization
    
    init(teamId: Int, ownerEmail: String?, ownerFirstName: String?, ownerLastName: String? ) {
        self.teamId = teamId
        self.ownerEmail = ownerEmail ?? ""
        self.ownerLastName = ownerLastName ?? ""
        self.ownerFirstName = ownerFirstName ?? ""
        
    }
    
}
