//
//  MovieInputController.swift
//  DoroffM_FinalProject
//
//  Created by Michael Doroff on 5/23/21.
//

import UIKit
import MobileCoreServices
import AVFoundation
import LBTATools
import AVKit
import Firebase
import FirebaseDatabase


class MovieInputController: UIViewController {
    
    var reference: DatabaseReference!
    
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    
    let storage = Storage.storage()
    
    let defaults = UserDefaults.standard
    
    let button: UIButton = {
       
        let button = UIButton()
        button.setTitle("Button", for: .normal)
        button.addTarget(self, action: #selector(recordMovie), for: .touchUpInside)
        return button
        
    }()
    
    let playButton: UIButton = {
        
        let button = UIButton()
        button.setTitle("Play", for: .normal)
        button.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        return button
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        
        view.addSubview(button)
        button.centerInSuperview()
        view.addSubview(playButton)
        
        playButton.anchor(top: button.bottomAnchor, leading: nil, bottom: nil, trailing: nil)
        
    }
    
   @objc fileprivate func recordMovie() {
    
        let controller = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
            controller.sourceType = .camera
            controller.mediaTypes = [kUTTypeMovie as String]
            controller.delegate = self
                
            present(controller, animated: true, completion: nil)
        }
        else {
            print("Camera is not available")
        }
    }
}

extension MovieInputController: UINavigationControllerDelegate {
    
}

extension MovieInputController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        reference = Database.database().reference()
        
        dismiss(animated: true)
        
        guard let mediaUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }
        
        let uniqueid = NSUUID().uuidString
        let movieName = uniqueid + ".mov"
        
        _ = Firebase.Storage.storage().reference().child("movies").child(movieName).putFile(from: mediaUrl as URL, metadata: nil) { storageMetadata, err in
            if err != nil {
                print("Failed upload of video")
            }
            
            Firebase.Storage.storage().reference().child("movies").child(movieName).downloadURL { url, err in
                
                self.reference.child("movies").child(uniqueid).setValue(["FirebaseURL":url?.absoluteString, "Category": "Technology", "Tags": ""])
            
            }
        }
    }
    @objc fileprivate func playVideo() {
        
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
                    
                    guard let link = valueDict["FirebaseURL"] else { return }
                    
                    guard let url = URL(string:link as! String) else { return }

                    DispatchQueue.main.async {
                        let player = AVPlayer(url: url)
                        let vc = AVPlayerViewController()
                        vc.player = player

                        self.present(vc, animated: true) {
                            vc.player?.play()
                        }
                    }
                }
            }
        }
    }
}


