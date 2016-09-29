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
    var createdDate: NSDate!
    var updatedDate: NSDate!
    var text: String!
    var imageURL : String!
    var notificationId: Int!
    var image: UIImage?
    
    // MARK: Initialization
    
    init(text: String?, name: String?, createdDate: String?, updatedDate: String?, imageURL: String?, notificationId: Int!) {
        
     
        self.createdDate = createdDate != nil ? stringCreateUpdateToDate(createdDate!) : NSDate()
        self.updatedDate = updatedDate != nil ? stringCreateUpdateToDate(updatedDate!) : NSDate()
        self.text = text ?? ""
        self.name = name ?? ""
        self.imageURL = imageURL ?? ""
        self.notificationId = notificationId
        
        
    }
    
    func stringCreateUpdateToDate(stringDate: String) -> NSDate {
        return NSDate(fromString:stringDate, format: .Custom("yyyy-MM-dd HH:mm:ss"))
    }

    
}
