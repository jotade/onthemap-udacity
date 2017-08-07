//
//  LoginTextField.swift
//  onthemap
//
//  Created by IM Development on 8/6/17.
//  Copyright © 2017 IM Development. All rights reserved.
//

import UIKit

class LoginTextField: UITextField, UITextFieldDelegate {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.resignFirstResponder()
        return true
    }
}

