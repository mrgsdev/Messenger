//
//  ViewController.swift
//  Messenger
//
//  Created by MRGS on 12.09.2022.
//

import UIKit

class ConverstationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
    
    let isLoggedIn = UserDefaults.standard.bool(forKey: "login_in")
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isLoggedIn {
            let vc = LoginViewController()
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: false)
            
        }
    }

}

