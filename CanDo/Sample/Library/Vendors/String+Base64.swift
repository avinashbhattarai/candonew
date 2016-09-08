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
        let data = NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions(rawValue: 0))
        return String(data: data!, encoding: NSUTF8StringEncoding)!
    }
    
    func toBase64() -> String
    {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
        return data!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    }
}