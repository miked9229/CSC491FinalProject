//
//  ViewController.swift
//  DoroffM_FinalProject
//
//  Created by Michael Doroff on 5/2/21.
//

import UIKit
import MobileCoreServices
import AVFoundation
import Firebase
import FirebaseDatabase

class HomeController: UIViewController {
    
    var reference: DatabaseReference!
    
    var demoMovieArray: [(name: String, firebaseURL: String, category: String,tags: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        callOnFirebase()
        
    }
    
    @IBAction func recordDemo(_ sender: UIButton) {
        
        let movieController = MovieInputController()
        present(movieController, animated: true)
    }
    
    
    @IBAction func goToSearch(_ sender: UIButton) {
        
        let demoMovieTableViewController = DemoMovieTableViewContorller()
        demoMovieTableViewController.demoMovieArray = demoMovieArray
        present(demoMovieTableViewController, animated: true)
    }
    
    
    fileprivate func callOnFirebase(){
        
        reference = Database.database().reference()
        
        var data = [String: Any]()
        
        reference.child("movies").getData { err, snapshot in
            
            if let error = err {
                print("Error getting data \(error)")
            }
            else if snapshot.exists() {
                let value = snapshot.value
                
                data = value as? [String: Any] ?? [:]
                
                data.forEach { (key, value) in
                    
                    guard let valueDict = value as? [String: Any] else { return }
                    
                    guard let name = valueDict["Name"] as? String else { return }
                    guard let link = valueDict["FirebaseURL"] as? String else{ return }
                    guard let category = valueDict["Category"] as? String else { return }
                    guard let tags = valueDict["Tags"] as? String else { return }
                    
                    self.demoMovieArray.append((name: name, firebaseURL: link, category: category, tags: tags))

                }
            }
        }
    }
}



