//
//  DemoMovieTableViewController.swift
//  DoroffM_FinalProject
//
//  Created by Michael Doroff on 5/24/21.
//
import UIKit
import MobileCoreServices
import AVFoundation
import LBTATools
import AVKit
import Firebase
import FirebaseDatabase

class DemoMovieTableViewContorller: UITableViewController {
    
    var reference: DatabaseReference!
    
    var demoMovieArray: [(name: String, firebaseURL: String, category: String,tags: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        callOnFirebase()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demoMovieArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let demoVideo  = demoMovieArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = demoVideo.category
        cell.detailTextLabel?.text = "Recorded by: \(demoVideo.name)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let demoVideo = demoMovieArray[indexPath.row]
        
        guard let url = URL(string: demoVideo.firebaseURL) else { return }
        
        DispatchQueue.main.async {
            let player = AVPlayer(url: url)
            let vc = AVPlayerViewController()
            vc.player = player
            
            self.present(vc, animated: true) {
                vc.player?.play()
            }
            
        }
    }
    
    fileprivate func callOnFirebase(){
        
        print("Calling on Firebase...")
        demoMovieArray = []
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
                    DispatchQueue.main.async {
                        self.tableView.reloadData()

                    }
                  
                }
            }
        }
    }
}

    
