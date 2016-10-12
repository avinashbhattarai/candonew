//
//  Notification.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 08.09.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import Foundation
import UIKit
class Notification {
    
    // MARK: Properties
    
   // var memberId: Int!
   // var userId: Int!
    
    var name: String!
    var createdDate: Date!
    var updatedDate: Date!
    var text: String!
    var imageURL : String!
    var notificationId: Int!
    var image: UIImage?
    var avatar:String!
    
    // MARK: Initialization
    
    init(text: String?, name: String?, createdDate: String?, updatedDate: String?, imageURL: String?, notificationId: Int!, avatar:String?) {
        
     
        self.createdDate = createdDate != nil ? stringCreateUpdateToDate(createdDate!) : Date()
        self.updatedDate = updatedDate != nil ? stringCreateUpdateToDate(updatedDate!) : Date()
        self.text = text ?? ""
        self.name = name ?? ""
        self.imageURL = imageURL ?? ""
        self.notificationId = notificationId
        self.avatar = avatar ?? ""
        
        
    }
    
    func stringCreateUpdateToDate(_ stringDate: String) -> Date {
        return Date(fromString: stringDate, format: .custom("yyyy-MM-dd HH:mm:ss"))
    }

    
}
