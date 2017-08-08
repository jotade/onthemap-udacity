//
//  StudentDataSource.swift
//  onthemap
//
//  Created by IM Development on 8/8/17.
//  Copyright © 2017 IM Development. All rights reserved.
//

import Foundation

class StudentDataSource {
    var studentData = [Student]()
    static let sharedInstance = StudentDataSource()
    private init() {}
}
