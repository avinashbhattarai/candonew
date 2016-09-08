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
    
    var firstName: String!
    var lastName: String!
    var date: NSDate!
    var text: String!
    var image : UIImage!
    
    // MARK: Initialization
    
    init(text: String?, firstName: String?, lastName: String?, date: NSDate?, image: UIImage?) {
        
     
        self.date = date ?? NSDate()
        self.text = text ?? ""
        self.lastName = lastName ?? ""
        self.firstName = firstName ?? ""
        self.image = image
        
        
    }
    
}
