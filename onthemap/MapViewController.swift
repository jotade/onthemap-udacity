//
//  MapViewController.swift
//  onthemap
//
//  Created by IM Development on 7/24/17.
//  Copyright © 2017 IM Development. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var addUpdateButton: UIBarButtonItem!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var linkView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveStudentsInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(showLocationFromPrompt), name: NSNotification.Name(rawValue: "showLocation"), object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "showLocation"), object: nil)
    }
    
    func showLocationFromPrompt(){

        tabBarController?.selectedIndex = 0
        addUpdateButton.isEnabled = false
        linkView.isHidden = false
        submitButton.isHidden = false
        
        let currentStudentPin = createStudentPin(student: AuthService.instance.currentStudent)
        mapView.addAnnotation(currentStudentPin)
        annotations.append(currentStudentPin)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: currentStudentPin.coordinate , span: span)
        mapView.setRegion(region, animated: true)
    }
    
    
    
    func createStudentPin(student: Student? ) -> MKPointAnnotation{
        
        let newPin = MKPointAnnotation()
        
        if let student = student, let latitude = student.latitude, let longitude = student.longitude, let firstName = student.firstName, let lastName = student.lastName{
            
            let coords = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            newPin.coordinate = coords
            newPin.title = firstName + " " + lastName
            if let url = student.mediaURL{
                newPin.subtitle = url
            }
        }
        return newPin
    }
    
    func loadAnnotations(){
        
        mapView.removeAnnotations(annotations)
        
        for student in DataService.instance.students{
            
            let studentPin = createStudentPin(student: student)
            annotations.append(studentPin)
        }
        
        DispatchQueue.main.async {
            self.mapView.addAnnotations(self.annotations)
        }
    }
    
    func retrieveStudentsInfo(){
        
        DataService.retrieveStudents { (success) in
            
            if success{
                
                self.loadAnnotations()
                
            }else{
                
                Utils.showAlert(with: "Error", message: "Couldn't retreive students info", viewController: self, isDefault: true, actions: nil)
            }
        }
    }
    
    func openURL(_ sender: UITapGestureRecognizer) {
        
        if let view = sender.view as? MKAnnotationView, let annotation = view.annotation, let stringUrl = annotation.subtitle, let url = URL(string: stringUrl!){
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
    //MARK: Button Actions
    
    @IBAction func addLocationAction(_ sender: UIBarButtonItem) {
        
        if let uniqueKey = AuthService.instance.currentStudent?.uniqueKey {
            
            let keys = DataService.instance.students.map{ $0.uniqueKey }
            if keys.contains(where: { $0 == uniqueKey }){

                let overwriteAction = UIAlertAction(title: "Overwrite", style: .default) { action in
                    DataService.instance.isUpdate = true
                    self.performSegue(withIdentifier: "find", sender: self)
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default) { action in
                    
                    self.dismiss(animated: true, completion: nil)
                }
                
                let actions = [overwriteAction, cancelAction]
                
                Utils.showAlert(with: "", message: "You have already posted a Student Location. Would you like to overwrite your current location?", viewController: self, isDefault: false, actions: actions)
                
                return
            }
            performSegue(withIdentifier: "find", sender: self)
        }
    }
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        
        AuthService.logout(){ success,dataString in
            
            print("LOGOUT: \(dataString)")
            self.parent?.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func submit(_ sender: UIButton) {
        
        guard let link = linkTextField.text , linkTextField.text != "", Utils.validateUrl(urlString: link as NSString) else{

            Utils.showAlert(with: "Oops", message: "Not a valid URL", viewController: self, isDefault: true, actions: nil)
            return
        }
        
        AuthService.instance.currentStudent?.mediaURL = link
        DataService.postStudentLocation(student: AuthService.instance.currentStudent, isUpdate: DataService.instance.isUpdate){ success in
            
            if success{
                DispatchQueue.main.async {
                    
                    self.addUpdateButton.isEnabled = true
                    self.mapView.removeAnnotations(self.annotations)
                    self.annotations = []
                    self.retrieveStudentsInfo()
                    self.linkView.isHidden = true
                    self.submitButton.isHidden = true
                }
            } else {
                DispatchQueue.main.async {
                    
                    self.addUpdateButton.isEnabled = true
                    self.linkView.isHidden = true
                    self.submitButton.isHidden = true
                    Utils.showAlert(with: "Oops", message: "Something went wrong, try again later!", viewController: self, isDefault: true, actions: nil)
                }
            }
        }
    }
    
    deinit {
        
        unsubscribeFromKeyboardNotifications()
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.openURL(_:)))
        
        view.addGestureRecognizer(tapGesture)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.removeGestureRecognizer(view.gestureRecognizers!.first!)
    }
}
