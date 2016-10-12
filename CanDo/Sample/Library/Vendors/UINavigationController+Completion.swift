//
//  UINavigationController+Completion.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 31.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import Foundation
extension UINavigationController {
    
    func pushViewController(_ viewController: UIViewController,
                            animated: Bool, completion: @escaping (Void) -> Void) {
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
}
