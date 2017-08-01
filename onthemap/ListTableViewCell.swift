//
//  ListTableViewCell.swift
//  onthemap
//
//  Created by IM Development on 7/30/17.
//  Copyright © 2017 IM Development. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    func configureCell(student: Student){
        
        if let firstName = student.firstName, let lastName = student.lastName {
            
            nameLabel.text = firstName + " " + lastName
        }
    }
}
