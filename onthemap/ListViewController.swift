//
//  ListViewController.swift
//  onthemap
//
//  Created by IM Development on 7/24/17.
//  Copyright © 2017 IM Development. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addUpdateLocationBarButton: UIBarButtonItem!
    
    var students = [Student]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        students = DataService.instance.students.sorted(by: {$0.updatedAt! > $1.updatedAt!})
        tableView.reloadData()
    }
    
    @IBAction func addUpdate(_ sender: UIBarButtonItem) {
        
        if let uniqueKey = AuthService.instance.currentStudent?.uniqueKey {
            
            let keys = DataService.instance.students.map{ $0.uniqueKey }
            if keys.contains(where: { $0 == uniqueKey }){
                
                let alertController = UIAlertController(title: "", message: "You have already posted a Student Location. Would you like to overwrite your current location?", preferredStyle: .alert)
                
                let overwriteAction = UIAlertAction(title: "Overwrite", style: .default) { action in
                    DataService.instance.isUpdate = true
                    self.performSegue(withIdentifier: "find", sender: self)
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default) { action in
                    self.dismiss(animated: true, completion: nil)
                }
                
                alertController.addAction(overwriteAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
        }
        performSegue(withIdentifier: "find", sender: self)
    }
}

extension ListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListTableViewCell
        
        cell.configureCell(student: students[indexPath.row])
        
        return cell
    }
}

extension ListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let stringURL = students[indexPath.row].mediaURL, let url = URL(string:stringURL) {
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}