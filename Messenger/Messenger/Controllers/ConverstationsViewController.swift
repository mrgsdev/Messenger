//
//  ViewController.swift
//  Messenger
//
//  Created by MRGS on 12.09.2022.
//

import UIKit
import FirebaseAuth
class ConverstationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPink
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      validateAuth()
    }
    private func validateAuth(){
        if Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: false)
        }
    }
}

