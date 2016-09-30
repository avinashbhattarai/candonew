//
//  Constants.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 25.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import Foundation
struct Helper {
    struct NotificationKey {
        static let Welcome = "kWelcomeNotif"
    }
    
    struct SegueKey {
        static let kToLoginViewController = "toLoginViewController"
        static let kToCodeViewController = "toCodeViewController"
        static let kToDashboardViewController = "toDashboardViewController"
        static let kToSuggestionsViewController = "toSuggestionsViewController"
        static let kToTodoViewController = "toTodoViewController"
        static let kToSetPasswordViewController = "toSetPasswordViewController"
        static let kToSetNewPasswordViewController = "toSetNewPasswordViewController"
        static let kToSelectTodoDateViewController = "toSelectTodoDateViewController"
        static let kToAssignTodoViewController = "toAssignTodoViewController"
        static let kToAccountSettingsViewController = "toAccountSettingsViewController"
        static let kToTipDetailsViewController = "toTipDetailsViewController"
        
        
      }
    
    
    struct ErrorKey {
        static let kSomethingWentWrong = "Something went wrong. Please try again later"
        
        
        
        
    }
    struct AccountStatusKey {
        static let kSigned = "Signed"
        static let kInvited = "Invited"
        
        
        
        
    }
    struct TodoStatusKey {
        static let kActive = "Active"
        static let kOverdue = "Overdue"
        static let kDone = "Done"
    }
    struct PlaceholderImage {
        static let kAvatar = "Unknown"
    }
    struct UploadImageSize {
        static let kUploadSize = 1400000
    }




    struct Colors {
        static func RGBCOLOR(red: Int, green: Int, blue: Int) -> UIColor {
            return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1)
        }
    }
    
    struct UserDefaults {
        static let kStandardUserDefaults = NSUserDefaults.standardUserDefaults()
        static let kUserFirstName = "user_first_name"
        static let kUserId = "user_id"
        static let kUserLastName = "user_last_name"
        static let kUserEmail = "user_email"
        static let kUserSecretCode = "user_secret_code"
        static let kUserToken = "user_token"
        static let kUserAvatar = "user_avatar"
        }
    

}