//
//  String+Base64.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 06.09.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import Foundation
import UIKit

extension String
{
    func fromBase64() -> String
    {
        let data = Data(base64Encoded: self, options: NSData.Base64DecodingOptions(rawValue: 0))
        return String(data: data!, encoding: String.Encoding.utf8)!
    }
    
    func toBase64() -> String
    {
        let data = self.data(using: String.Encoding.utf8)
        return data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    }
}
