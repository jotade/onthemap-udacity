//
//  DataService.swift
//  onthemap
//
//  Created by IM Development on 7/24/17.
//  Copyright © 2017 IM Development. All rights reserved.
//

import Foundation

class DataService {
    
    static let instance = DataService()
    var isUpdate: Bool = false
    
    private init(){}
    
    static func retrieveStudents(completion: @escaping (_ success:Bool)->()){
        
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                completion(false)
                return
            }
            
            do{
                let result = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:AnyObject]
                
                if let error = result["error"] as? String{
                    print("Error: \(error)")
                    completion(false)
                    return
                }
                
            } catch let err {
                print(err.localizedDescription)
                completion(false)
                return
            }

            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
            StudentDataSource.sharedInstance.studentData = Student.parseStudents(data: data!)
            completion(true)
            AuthService.publicUserData(key: AuthService.instance.accountKey!)
        }
        task.resume()
    }
    
    static func postStudentLocation(student:Student?, isUpdate update: Bool, completion: @escaping (_ success: Bool)->()){
        var url = "https://parse.udacity.com/parse/classes/StudentLocation"
        if update{
            url.append("/\(student!.objectID!)")
        }
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = update ? "PUT":"POST"
        
        
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let student = student,let key = student.uniqueKey, let firstName = student.firstName, let lastName = student.lastName, let mapString = student.mapString, let mediaURL = student.mediaURL, let latitude = student.latitude, let longitude = student.longitude{
            request.httpBody = "{\"uniqueKey\": \"\(key)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: String.Encoding.utf8)
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                print(error!.localizedDescription)
                completion(false)
                return
            }
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
            do{
                let result = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:AnyObject]
                
                if let updated = result["createdAt"] as? String ?? result["updatedAt"] as? String {
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    if let formattedDate = dateFormatter.date(from: updated){
                        AuthService.instance.currentStudent?.updatedAt = formattedDate
                    }
                    if let id = result["objectId"] as? String{
                        AuthService.instance.currentStudent?.objectID = id
                    }
                    completion(true)
                }else{
                    completion(false)
                }
                
            } catch let err {
                print(err.localizedDescription)
                completion(false)
            }
        }
        task.resume()
    }
}
