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
        
        activityIndicator = AlertUtils.showActivityIndicatory(uiView: self.view)

        guard let email = emailTextField.text, emailTextField.text != "", let password = passwordTextField.text, passwordTextField.text != "" else {
            
            AlertUtils.showAlert(with: "Error", message: "Please enter an email and a password to continue!", viewController: self, isDefault: true, actions: nil)
            self.activityIndicator.removeFromSuperview()
            return
        }
        
        
        AuthService.login(email: email, password: password) { success in

            if success{
                
                DispatchQueue.main.async {
                    
                    self.activityIndicator.removeFromSuperview()
                    self.performSegue(withIdentifier: "login", sender: nil)
                }
                
            }else{
                
                DispatchQueue.main.async {
                    self.activityIndicator.removeFromSuperview()
                    AlertUtils.showAlert(with: "Error", message: "couldn't log in!", viewController: self, isDefault: true, actions: nil)
                }
            }
        }
        
    }
}
