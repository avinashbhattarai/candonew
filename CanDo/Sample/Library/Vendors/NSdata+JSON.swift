//
//  NSdata+JSON.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 26.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import Foundation
extension NSData {
    func nsdataToJSON() -> AnyObject? {
        do {
            return try NSJSONSerialization.JSONObjectWithData(self, options: .MutableContainers)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil
    }
    func toBase64() -> String{
        return self.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
    }
}
