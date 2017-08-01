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
        AuthService.login(email: emailTextField.text!, password: passwordTextField.text!) { success in
            
            if success{

                DispatchQueue.main.async {
                    
                    self.activityIndicator.removeFromSuperview()
                    self.performSegue(withIdentifier: "login", sender: nil)
                }
            }
        }
    }
}
