//
//  Student.swift
//  onthemap
//
//  Created by IM Development on 7/26/17.
//  Copyright © 2017 IM Development. All rights reserved.
//

import Foundation

struct Student{
    
    var objectID: String?
    var firstName: String?
    var lastName: String?
    var latitude: Double?
    var longitude: Double?
    var mapString: String?
    var uniqueKey: String?
    var mediaURL: String?
    var updatedAt: Date?
    
    init(studentInfo: [String: AnyObject]) {
        
        if let id = studentInfo["objectId"] as? String { objectID = id }
        if let first = studentInfo["firstName"] as? String { firstName = first }
        if let last = studentInfo["lastName"] as? String { lastName = last }
        if let lat = studentInfo["latitude"] as? Double { latitude = lat }
        if let long = studentInfo["longitude"] as? Double { longitude = long }
        if let map = studentInfo["mapString"] as? String { mapString = map }
        if let key = studentInfo["uniqueKey"] as? String { uniqueKey = key }
        if let media = studentInfo["mediaURL"] as? String { mediaURL = media  }
        if let updated = studentInfo["updatedAt"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let formattedDate = dateFormatter.date(from: updated){
                updatedAt = formattedDate
            }
        }
    }
    
    static func parseStudents(data: Data) -> [Student] {
        
        var students = [Student]()
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:AnyObject]
            
            if let results = jsonResult["results"] as? [[String: AnyObject]] {
                
                for student in results {
                    
                    let newStudent = Student(studentInfo: student)
                    students.append(newStudent)
                    
                }
            }
            
        } catch let err {
            print(err)
        }
        return students
    }
    
    static func parseCurrentStudent(data: Data) {
        
        do {
            
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:AnyObject]
            
            if let user = jsonResult["user"], let firstName = user["first_name"], let lastName = user["last_name"], let key = AuthService.instance.accountKey{
                
                let currentStudent = Student(studentInfo: ["firstName": firstName as AnyObject,"lastName": lastName as AnyObject, "uniqueKey": key as AnyObject])
                
                AuthService.instance.currentStudent = currentStudent
                
                if let currentStudentFromServer = DataService.instance.students.filter({ $0.uniqueKey == key }).first {
                    
                    AuthService.instance.currentStudent?.objectID = currentStudentFromServer.objectID
                }
            }
            
        } catch let err {
            print(err)
        }
        
    }
}
