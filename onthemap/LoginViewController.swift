//
//  LoginViewController.swift
//  onthemap
//
//  Created by IM Development on 7/26/17.
//  Copyright © 2017 IM Development. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var activityIndicator:UIView!
    
    @IBAction func loginAction(_ sender: UIButton) {
        
        activityIndicator = Utils.showActivityIndicatory(uiView: self.view)
        
        guard let email = emailTextField.text, emailTextField.text != "", let password = passwordTextField.text, passwordTextField.text != "" else {
            
            Utils.showAlert(with: "Error", message: "Please enter an email and a password to continue!", viewController: self, isDefault: true, actions: nil)
            self.activityIndicator.removeFromSuperview()
            return
        }
        
        if Utils.isValidEmail(testStr: email){
            
            AuthService.login(email: email, password: password) { success, error in
                
                if success{
                    
                    DispatchQueue.main.async {
                        
                        self.activityIndicator.removeFromSuperview()
                        self.performSegue(withIdentifier: "login", sender: nil)
                    }
                    
                }else{
                    
                    DispatchQueue.main.async {
                        self.activityIndicator.removeFromSuperview()
                        Utils.showAlert(with: "Error", message: error!, viewController: self, isDefault: true, actions: nil)
                    }
                }
            }
            
        }else{
            
            Utils.showAlert(with: "Error", message: "Please enter a valid email", viewController: self, isDefault: true, actions: nil)
            self.activityIndicator.removeFromSuperview()
        }
        
    }
}
