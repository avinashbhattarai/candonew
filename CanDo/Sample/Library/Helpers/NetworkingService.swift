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
    
    case createUser(firstName: String, lastName: String, email: String, facebookId: String?)
    case verificateUser(code: Int, email: String)
    case setPasswordForUser(password: String, code: Int, email: String)
    case resetPasswordForUser(password: String, code: Int, email: String)
    case loginUser(password: String?, email: String?, facebookId: String?)
    case forgotPassword(email: String)
    
    case teamInfo()
    case createTeam()
    case deleteTeam()
    case leaveTeam()
    case inviteToTeam(email: String)
    case acceptInvite(teamId: Int)
    case removeFromTeam(memberId: Int)
    
    case tipsInfo()
    
    case addList(name: String)
    case addTodo(listId: Int, name: String, assign_to :Int?, date: String?, time: String?)
    case updateTodo(todoId: Int, name: String, assign_to :Int?, date: String?, time: String?, status:String?)
    case listsInfo(date: String?)
    case updateList(listId: Int, name: String)
    
    case notificationsInfo()
    case postNotification(post: String?, image: String?)
    case updateUser (avatar: String?, firstName:String?, lastName:String?)
    
    case suggestionsInfo()
    case addSuggestions(suggestions: NSArray)
    
}

let endpointClosure = { (target: NetworkingService) -> Endpoint<NetworkingService> in
    let url = target.baseURL.appendingPathComponent(target.path).absoluteString
    let endpoint: Endpoint<NetworkingService> = Endpoint<NetworkingService>(URL: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
    
   if let token: String = Helper.UserDefaults.kStandardUserDefaults.object(forKey: Helper.UserDefaults.kUserToken) as? String
   {
     let encodedToken: String = token.toBase64()
    
     return endpoint.endpointByAddingHTTPHeaderFields(["Authorization": "Bearer \(token)"])
   }
    return endpoint
    
}
private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data, options: [])
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data //fallback to original data if it cant be serialized
    }
}


let provider = MoyaProvider<NetworkingService>(endpointClosure: endpointClosure, plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])


// MARK: - TargetType Protocol Implementation
extension NetworkingService: TargetType {
  
    
     public var baseURL: URL { return URL(string: "http://api.cando.dev.letzgro.net")! }
    
     public var path: String {
        switch self {
        
        case .createUser(_, _, _, _):
            return "/user/register"
        case .verificateUser(_, _):
            return "/user/verification"
        case .setPasswordForUser(_, _,_):
            return "/user/set-password"
        case .resetPasswordForUser(_, _,_):
            return "/user/reset"
        case .loginUser(_, _, _):
            return "/user/login"
        case .updateUser(_,_,_):
            return "/user"
        case .forgotPassword(_):
            return "/user/forgot"
        
        case .teamInfo():
            return "/team"
        case .createTeam():
            return "/team"
        case .deleteTeam():
            return "/team"
        case .leaveTeam():
            return "/team/leave"
        case .inviteToTeam(_):
            return "/team/member"
        case .acceptInvite(_):
            return "/team/accept"
        case .removeFromTeam(let memberId):
            return "/team/member/\(memberId)"
            
        case .tipsInfo():
            return "/tips"
            
        case .addList(_):
            return "/lists"
        case .addTodo(_,_,_,_,_):
            return "/todo"
        case .updateTodo(let todoId,_,_,_,_,_):
            return "/todo/\(todoId)"
        case .listsInfo(let date):
            if (date != nil) {
                 return "/lists/\(date!)"
            }else{
                return "/lists"
            }
        case .updateList(let listId,_):
            return "/lists/\(listId)"
            
        case .notificationsInfo():
            return "/notifications"
        case .postNotification(_,_):
            return "/notifications"

        case .suggestionsInfo():
            return "/suggestions"
        case .addSuggestions(_):
            return "/suggestions/create-todos"
    
        }
    }
    public var method: Moya.Method {
        switch self {
        case .createUser:
            return .POST
        case .verificateUser:
            return .POST
        case .setPasswordForUser:
            return .POST
        case .resetPasswordForUser:
            return .POST
        case .loginUser:
            return .POST
        case .forgotPassword:
            return .POST
        case .teamInfo:
            return .GET
        case .createTeam:
            return .POST
        case .deleteTeam:
            return .DELETE
        case .inviteToTeam:
            return .POST
        case .acceptInvite:
            return .POST
        case .removeFromTeam:
            return .DELETE
        case .leaveTeam:
            return .GET
        case .tipsInfo:
            return .GET
        case .addList:
            return .POST
        case .addTodo:
            return .POST
        case .updateTodo:
            return .PUT
        case .listsInfo:
            return .GET
        case .updateList:
            return .PUT
        case .notificationsInfo:
            return .GET
        case .postNotification:
            return .POST
        case .updateUser:
            return .PUT
        case .suggestionsInfo:
            return .GET
        case .addSuggestions:
            return .POST
        }
    }
    public var parameters: [String: Any]? {
        switch self {
        case .createUser(let firstName, let lastName, let email, let facebookId):
            var params: [String : AnyObject] = [:]
            params["first_name"] = firstName as AnyObject?
            params["last_name"] = lastName as AnyObject?
            params["email"] = email as AnyObject?
            params["facebook_id"] = facebookId as AnyObject?
            return params
            
        case .verificateUser(let code, let email):
            return ["code": code as AnyObject, "email": email as AnyObject]
            
        case .setPasswordForUser(let password, let code, let email):
            return ["password": password as AnyObject, "code": code as AnyObject, "email": email as AnyObject]
            
        case .resetPasswordForUser(let password, let code, let email):
            return ["password": password as AnyObject, "code": code as AnyObject, "email": email as AnyObject]
            
        case .loginUser(let password, let email, let facebookId):
            var params: [String : AnyObject] = [:]
            params["email"] = email as AnyObject?
            params["password"] = password as AnyObject?
            params["facebook_id"] = facebookId as AnyObject?
            return params
            
        case .forgotPassword(let email):
            return ["email": email as AnyObject]
            
        case .teamInfo():
            return nil
        case .createTeam():
            return nil
        case .deleteTeam():
            return nil
        case .leaveTeam():
            return nil
        case .inviteToTeam(let email):
            return ["email": email as AnyObject]
        case .acceptInvite(let teamId):
            return ["team_id": teamId as AnyObject]
        case .removeFromTeam(let memberId):
            return ["id": memberId as AnyObject]
            
        case .tipsInfo():
            return nil
            
        case .addList(let name):
            return ["name": name as AnyObject]
        case .addTodo(let listId, let name, let assign_to, let date, let time):
            var params: [String : AnyObject] = [:]
            params["list_id"] = listId as AnyObject?
            params["name"] = name as AnyObject?
            params["assign_to"] = assign_to as AnyObject?
            params["date"] = date as AnyObject?
            params["time"] = time as AnyObject?
            return params
        case .updateTodo(let todoId, let name, let assign_to, let date, let time, let status):
            var params: [String : AnyObject] = [:]
            params["id"] = todoId as AnyObject?
            params["name"] = name as AnyObject?
            params["assign_to"] = assign_to as AnyObject?
            params["date"] = date as AnyObject?
            params["time"] = time as AnyObject?
            params["status"] = status as AnyObject?
            return params

        case .listsInfo(_):
            return nil
        case .suggestionsInfo(_):
            return nil

        case .updateList(let listId, let name):
            return ["listId": listId as AnyObject, "name": name as AnyObject]
            
        case .notificationsInfo():
            return nil
            
        case .postNotification(let post, let image):
            var params: [String : AnyObject] = [:]
            params["post"] = post as AnyObject?
            params["image"] = image as AnyObject?
            return params
            
        case .updateUser(let avatar, let firstName, let lastName):
            var params: [String : AnyObject] = [:]
            params["avatar"] = avatar as AnyObject?
            params["firts_name"] = firstName as AnyObject?
            params["last_name"] = lastName as AnyObject?
            return params

        case .addSuggestions(let suggestions):
            return ["suggestions": suggestions]
        }
    }
    
    public var sampleData: Data {
        switch self {
        case .createUser(let firstName, let lastName, let email, let facebookId):
            return "{\"first_name\": \"\(firstName)\", \"last_name\": \"\(lastName)\", \"email\": \"\(email)\", \"facebook_id\": \"\(facebookId)\"}".UTF8EncodedData
            
        case .verificateUser(let code, let email):
            return "{\"code\": \"\(code)\", \"email\": \"\(email)\"}".UTF8EncodedData
            
        case .setPasswordForUser(let code, let email, let password ):
            return "{\"code\": \"\(code)\", \"email\": \"\(email)\", \"password\":\"\(password)\"}".UTF8EncodedData
            
        case .resetPasswordForUser(let code, let email, let password ):
            return "{\"code\": \"\(code)\", \"email\": \"\(email)\", \"password\":\"\(password)\"}".UTF8EncodedData
            
        case .loginUser(let password, let email, let facebookId):
            return "{\"password\": \"\(password)\", \"email\": \"\(email)\", \"facebook_id\": \"\(facebookId)\"}".UTF8EncodedData
        case .forgotPassword(let email):
             return "{\"email\": \"\(email)\"}".UTF8EncodedData
            
        case .teamInfo():
            return "Half measures are as bad as nothing at all.".UTF8EncodedData
        case .createTeam():
            return "Half measures are as bad as nothing at all.".UTF8EncodedData
        case .deleteTeam():
            return "Half measures are as bad as nothing at all.".UTF8EncodedData
        case .leaveTeam():
            return "Half measures are as bad as nothing at all.".UTF8EncodedData
        case .inviteToTeam(let email):
            return "{\"email\": \"\(email)\"}".UTF8EncodedData
        case .acceptInvite(let teamId):
            return "{\"team_id\": \"\(teamId)\"}".UTF8EncodedData
        case .removeFromTeam(let memberId):
            return "{\"id\": \"\(memberId)\"}".UTF8EncodedData

        case .tipsInfo():
            return "Half measures are as bad as nothing at all.".UTF8EncodedData
            
        case .addList(let name):
            return "{\"name\": \"\(name)\"}".UTF8EncodedData
        case .addTodo(let listId, let name, let assign_to, let date, let time):
            return "{\"list_id\": \"\(listId)\", \"name\": \"\(name)\", \"assign_to\": \"\(assign_to)\", \"date\": \"\(date)\", \"time\": \"\(time)\"}".UTF8EncodedData
        case .updateTodo(let todoId, let name, let assign_to, let date, let time, let status):
            return "{\"id\": \"\(todoId)\", \"name\": \"\(name)\", \"assign_to\": \"\(assign_to)\", \"date\": \"\(date)\", \"time\": \"\(time)\", \"status\": \"\(status)\"}".UTF8EncodedData
        case .listsInfo(_):
            return "Half measures are as bad as nothing at all.".UTF8EncodedData
        case .updateList(let listId,let name):
            return "{\"list_id\": \"\(listId)\",\"name\": \"\(name)\"}".UTF8EncodedData
        case .notificationsInfo():
            return "Half measures are as bad as nothing at all.".UTF8EncodedData
        case .postNotification(let post, let image):
            return "{\"post\": \"\(post)\",\"image\": \"\(image)\"}".UTF8EncodedData
        case .updateUser(let avatar, let firstName, let lastName):
            return "{\"avatar\": \"\(avatar)\",\"first_name\": \"\(firstName)\",\"last_name\": \"\(lastName)\"}".UTF8EncodedData
        case .suggestionsInfo(_):
            return "Half measures are as bad as nothing at all.".UTF8EncodedData
        case .addSuggestions(let suggestions):
            return "{\"suggestions\": \"\(suggestions)\"}".UTF8EncodedData
        }
        
    }
    
    public var task: Task{
        return .request
    }

    
    public var multipartBody: [MultipartFormData]? {
        // Optional
        return nil
    }
}

// MARK: - Helpers
private extension String {
    var URLEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }
    var UTF8EncodedData: Data {
        return self.data(using: String.Encoding.utf8)!
    }
}
