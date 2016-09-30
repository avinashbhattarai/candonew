//
//  Member.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 06.09.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import Foundation
import UIKit
class Member {
    
    // MARK: Properties
    
    var memberId: Int!
    var userId: Int!
    var status: String!
    var firstName: String!
    var lastName: String!
    var email: String!
    var facebook: Bool!
    var owner : Bool!
    var avatar: String!
    
    // MARK: Initialization
    
    init(memberId: Int,userId: Int, email: String?, firstName: String?, lastName: String?, status: String?, facebook :Bool, owner:Bool, avatar:String?) {
        
        self.memberId = memberId
        self.userId = userId
        self.avatar = avatar ?? ""
        self.status = status ?? ""
        self.email = email ?? ""
        self.lastName = lastName ?? ""
        self.firstName = firstName ?? ""
        
        self.facebook = facebook
        self.owner = owner
        
    }
    
}
