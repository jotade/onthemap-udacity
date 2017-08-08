//
//  AuthService.swift
//  onthemap
//
//  Created by IM Development on 7/24/17.
//  Copyright © 2017 IM Development. All rights reserved.
//

import Foundation

class AuthService {
    
    static let instance = AuthService()
    
    var currentStudent:Student?
    var accountKey: String?
    var sessionTokenID: String?
    
    private init(){}
    
    static func login(email:String, password: String, completion: @escaping(_ success:Bool)->()){
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                completion(false)
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            
            let user = try? JSONSerialization.jsonObject(with: newData!, options: []) as! [String:AnyObject]
            if let session = user?["session"] as? [String: AnyObject], let id = session["id"] as? String, let account = user?["account"] as? [String: AnyObject], let key = account["key"] as? String{
                
                AuthService.instance.sessionTokenID = id
                AuthService.instance.accountKey = key
                completion(true)
            }else{
                completion(false)
            }
        }
        task.resume()
    }
    
    static func logout(completion: @escaping(_ success:Bool, _ data: NSString)->()){
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            let dataString = NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!
            completion(true, dataString)
        }
        task.resume()
    }
    
    static func publicUserData(key:String){
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/users/\(key)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            if error != nil {
                
                print(error!.localizedDescription)
                return
            }
            
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            Student.parseCurrentStudent(data: newData!)
        }
        task.resume()
    }
}
