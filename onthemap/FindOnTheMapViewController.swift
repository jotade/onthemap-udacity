//
//  FindOnTheMapViewController.swift
//  onthemap
//
//  Created by IM Development on 7/27/17.
//  Copyright © 2017 IM Development. All rights reserved.
//

import UIKit
import CoreLocation

class FindOnTheMapViewController: UIViewController {
    
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var locationTextField: UITextField!
    
    let geocoder = CLGeocoder()
    var activityIndicator: UIView?

    func geocodeLocation(city: String){
        
        geocoder.geocodeAddressString(city) { (placemarks, error) in
            
            if error != nil{
                
                print(error!.localizedDescription)
                Utils.showAlert(with: "Error", message: "couldn't find your location!", viewController: self, isDefault: true, actions: nil)
                return
            }
            
            if let place = placemarks?.first, let coordinate = place.location?.coordinate, let name = place.name, let country = place.country{
                
                AuthService.instance.currentStudent?.latitude = coordinate.latitude
                AuthService.instance.currentStudent?.longitude = coordinate.longitude
                AuthService.instance.currentStudent?.mapString = "\(name), \(country)"
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showLocation"), object: nil)
                
                self.dismiss(animated: true) {
                    
                    self.activityIndicator?.removeFromSuperview()
                }
            }
        }
    }
    
    @IBAction func find(_ sender: UIButton) {
        
        guard let location = locationTextField.text , locationTextField.text != "" else {
            
            Utils.showAlert(with: "Oops", message: "You forgot to put your location!", viewController: self, isDefault: true, actions: nil)
            
            return
        }
        
        activityIndicator = Utils.showActivityIndicatory(uiView: self.view)
        geocodeLocation(city: location)
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
}
