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
import JGProgressHUD


class MovieInputController: UIViewController, UITextFieldDelegate {
    
    var tags = ""
    var name = ""
    var category = ""
    
    var reference: DatabaseReference!
    
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    
    let storage = Storage.storage()
    
    let tagsTextField: UITextField = {
        
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter Tags Separated By a Comma", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        textField.textColor = .black
        textField.textAlignment = .center
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.blue.cgColor
        return textField
    }()
    
    let nameTextField: UITextField = {
        
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter Your Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        textField.textColor = .black
        textField.textAlignment = .center
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.blue.cgColor
        return textField
    }()
    
    let categoryTextField: UITextField = {
        
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter Your Category", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        textField.textColor = .black
        textField.textAlignment = .center
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.blue.cgColor
        return textField
    }()
    
    let submitButton: UIButton = {
        
        let button = UIButton()
        button.setTitle("Record Demo", for: .normal)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.black.cgColor
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(recordDemo), for: .touchUpInside)
        return button
    }()
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        
        view.addSubview(tagsTextField)
        view.addSubview(nameTextField)
        view.addSubview(categoryTextField)
        view.addSubview(submitButton)
        
        
        tagsTextField.delegate = self
        nameTextField.delegate = self
        categoryTextField.delegate = self
        
        let height: CGFloat = 50
         
        tagsTextField.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 48, left: 16, bottom: 0, right: 16), size: .init(width: 0, height: height))
        
        nameTextField.anchor(top: tagsTextField.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 32, left: 16, bottom: 0, right: 16), size: .init(width: 0, height: height))
        
        categoryTextField.anchor(top: nameTextField.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 32, left: 16, bottom: 0, right: 16), size: .init(width: 0, height: height))
        
        submitButton.anchor(top: categoryTextField.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 40, left: 48, bottom: 0, right: 48), size: .init(width: 0, height: height))

    }
    
   @objc fileprivate func recordDemo() {
    
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        var text = ""
        if let textFieldText = textField.text {
            text = textFieldText
        }
        
        guard let placeholder = textField.placeholder else { return }
        if (placeholder == "Enter Tags Separated By a Comma") {
            tags = text
        } else if (placeholder == "Enter Your Name") {
            name = text
        } else {
            category = text
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
        textField.resignFirstResponder()
        return true
    }
}

extension MovieInputController: UINavigationControllerDelegate {}

extension MovieInputController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        reference = Database.database().reference()
        
        dismiss(animated: true)
        
        guard let mediaUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }
        
        let hud = JGProgressHUD()
        hud.textLabel.text = "Uploading video to server.."
        hud.show(in: view)
        
        
        let uniqueid = NSUUID().uuidString
        let movieName = uniqueid + ".mov"
        
        _ = Firebase.Storage.storage().reference().child("movies").child(movieName).putFile(from: mediaUrl as URL, metadata: nil) { storageMetadata, err in
            if err != nil {
                print("Failed upload of video")
            }
            
            Firebase.Storage.storage().reference().child("movies").child(movieName).downloadURL { url, err in
                
                self.reference.child("movies").child(uniqueid).setValue(["FirebaseURL":url?.absoluteString, "Category": self.category, "Tags": self.tags, "Name": self.name])
                
                hud.dismiss()
                
                self.dismiss(animated: true)
            }
        }
    }
}


