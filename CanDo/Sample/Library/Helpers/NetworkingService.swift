//
//  NetworkingService.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 25.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import Foundation
import Moya



public enum NetworkingService {
    case CreateUser(firstName: String, lastName: String, email: String)
    case VerificateUser(code: Int, email: String)
    case SetPasswordForUser(password: String, code: Int, email: String)
    case LoginUser(password: String, email: String)
    case ForgotPassword(email: String)
}

let endpointClosure = { (target: NetworkingService) -> Endpoint<NetworkingService> in
    let url = target.baseURL.URLByAppendingPathComponent(target.path).absoluteString
    let endpoint: Endpoint<NetworkingService> = Endpoint<NetworkingService>(URL: url, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
    return endpoint //.endpointByAddingHTTPHeaderFields(["APP_NAME": "MY_AWESOME_APP"])
}
private func JSONResponseDataFormatter(data: NSData) -> NSData {
    do {
        let dataAsJSON = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        let prettyData =  try NSJSONSerialization.dataWithJSONObject(dataAsJSON, options: .PrettyPrinted)
        return prettyData
    } catch {
        return data //fallback to original data if it cant be serialized
    }
}


let provider = MoyaProvider<NetworkingService>(endpointClosure: endpointClosure, plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])


// MARK: - TargetType Protocol Implementation
extension NetworkingService: TargetType {
    public var baseURL: NSURL { return NSURL(string: "http://api.cando.dev.letzgro.net")! }
    public var path: String {
        switch self {
        
        case .CreateUser(_, _, _):
            return "/user/register"
        case .VerificateUser(_, _):
            return "/user/verification"
        case .SetPasswordForUser(_, _,_):
            return "/user/set-password"
        case .LoginUser(_, _):
            return "/user/login"
        case .ForgotPassword(_):
            return "/user/forgot"
        }
    }
    public var method: Moya.Method {
        switch self {
        case .CreateUser:
            return .POST
        case .VerificateUser:
            return .POST
        case .SetPasswordForUser:
            return .POST
        case .LoginUser:
            return .POST
        case .ForgotPassword:
            return .POST
        }
    }
    public var parameters: [String: AnyObject]? {
        switch self {
        case .CreateUser(let firstName, let lastName, let email):
            return ["first_name": firstName, "last_name": lastName, "email": email]
            
        case .VerificateUser(let code, let email):
            return ["code": code, "email": email]
            
        case .SetPasswordForUser(let password, let code, let email):
            return ["password": password, "code": code, "email": email]
            
        case .LoginUser(let password, let email):
            return ["password": password, "email": email]
            
        case .ForgotPassword(let email):
            return ["email": email]
            
        }
    }
    public var sampleData: NSData {
        switch self {
        case .CreateUser(let firstName, let lastName, let email):
            return "{\"first_name\": \"\(firstName)\", \"last_name\": \"\(lastName)\", \"email\": \"\(email)\"}".UTF8EncodedData
            
        case .VerificateUser(let code, let email):
            return "{\"code\": \"\(code)\", \"email\": \"\(email)\"}".UTF8EncodedData
            
        case .SetPasswordForUser(let code, let email, let password ):
            return "{\"code\": \"\(code)\", \"email\": \"\(email)\", \"password\":\"\(password)\"}".UTF8EncodedData
            
        case .LoginUser(let password, let email):
            return "{\"password\": \"\(password)\", \"email\": \"\(email)\"}".UTF8EncodedData
        case .ForgotPassword(let email):
             return "{\"email\": \"\(email)\"}".UTF8EncodedData
        }
    }
    public var multipartBody: [MultipartFormData]? {
        // Optional
        return nil
    }
}

// MARK: - Helpers
private extension String {
    var URLEscapedString: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
    var UTF8EncodedData: NSData {
        return self.dataUsingEncoding(NSUTF8StringEncoding)!
    }
}