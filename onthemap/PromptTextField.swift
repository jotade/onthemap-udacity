//
//  PromptTextField.swift
//  onthemap
//
//  Created by IM Development on 7/30/17.
//  Copyright © 2017 IM Development. All rights reserved.
//

import UIKit

class PromptTextField: UITextField, UITextFieldDelegate {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.delegate = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.text == "Enter a Link to Share Here" || textField.text == "Enter Your Location Here" {
            
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.resignFirstResponder()
        return true
    }
}
