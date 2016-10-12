//
//  NSdata+JSON.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 26.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import Foundation
extension Data {
    func nsdataToJSON() -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: .mutableContainers)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil
    }
    func toBase64() -> String{
        return self.base64EncodedString(options: NSData.Base64EncodingOptions())
    }
}
