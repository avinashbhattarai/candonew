//
//  UIViewController+HideKeyboard.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 19.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import Foundation
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func isUserLogined() -> Bool {
        guard (Helper.UserDefaults.kStandardUserDefaults.value(forKey: Helper.UserDefaults.kUserToken) != nil) &&
            (Helper.UserDefaults.kStandardUserDefaults.value(forKey: Helper.UserDefaults.kUserId) != nil)
            else {
                return false
        }

      return true
    }
}
