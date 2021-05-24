//
//  ViewController.swift
//  DoroffM_FinalProject
//
//  Created by Michael Doroff on 5/2/21.
//

import UIKit
import MobileCoreServices
import AVFoundation

class HomeController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func recordDemo(_ sender: UIButton) {
        
        let movieController = MovieInputController()
        present(movieController, animated: true)
    }
}



