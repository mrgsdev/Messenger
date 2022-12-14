//
//  LoginViewController.swift
//  Messenger
//
//  Created by MRGS on 12.09.2022.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD



class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.clipsToBounds = true
        return scroll
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        field.isSecureTextEntry = true
        return field
    }()
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let facebookLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email", "public_profile"]
        return button
    }()
    
    private let googleLogInButton = GIDSignInButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log In"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        loginButton.addTarget(self,action: #selector(loginButtonTapped),for: .touchUpInside)
        googleLogInButton.addTarget(self, action: #selector(googleAuthPressed), for: .touchUpInside)
        emailField.delegate = self
        passwordField.delegate = self
        facebookLoginButton.delegate = self
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
        scrollView.addSubview(googleLogInButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width / 3
        imageView.frame = CGRect(x: (scrollView.width-size) / 2,
                                 y: 20,
                                 width: size,
                                 height: size)
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom+10,
                                  width: scrollView.width-60,
                                  height: 52)
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom+10,
                                     width: scrollView.width-60,
                                     height: 52)
        loginButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom+10,
                                   width: scrollView.width-60,
                                   height: 52)
        facebookLoginButton.frame = CGRect(x: 30,
                                           y: loginButton.bottom+10,
                                           width: scrollView.width-60,
                                           height: 52)
        //        facebookLoginButton.frame.origin.y = loginButton.bottom + 20
        
        googleLogInButton.frame = CGRect(x: 30,
                                         y: facebookLoginButton.bottom+10,
                                         width: scrollView.width-60,
                                         height: 52)
    }
    
    @objc private func loginButtonTapped() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        // Firebase Log In
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            if let error = error{
                let alert = UIAlertController(title: "Woops",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title:"Dismiss",
                                              style: .cancel, handler: nil))
                strongSelf.present(alert, animated: true)
            }
            guard let result = authResult else {
                print("failed: \(email)")
                return
            }
            let user = result.user
            print("Logged In User: \(user)")
            
            UserDefaults.standard.set(email, forKey: "email")
            
            strongSelf.navigationController?.dismiss(animated: false)
            //            if authResult != nil{
            //                let alert = UIAlertController(title: "Success",
            //                                              message: nil,
            //                                              preferredStyle: .alert)
            //                alert.addAction(UIAlertAction(title:"Dismiss",
            //                                              style: .cancel, handler: nil))
            //                strongSelf.present(alert, animated: true)
            //            }
        }
    }
    func alertUserLoginError() {
        let alert = UIAlertController(title: "Woops",
                                      message: "Please enter all information to log in.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Dismiss",
                                      style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    @objc private func didTapRegister(){
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc private func googleAuthPressed(){
        let user = GIDGoogleUser()
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("Did  sign to google: \(user)")
            guard let email = user?.profile?.email,
                  let firstName = user?.profile?.name,
                  let lastName = user?.profile?.familyName else {
                return
            }
            
            UserDefaults.standard.set(email, forKey: "email")
            DatabaseManager.shared.userExists(with: email) { exists in
                if !exists{
                    // insert to Database
                    let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAdress: email)
                    DatabaseManager.shared.insertUser(with: chatUser) { success in
                        if success{
                            if user!.profile!.hasImage{
                                guard let url = user!.profile?.imageURL(withDimension: 200) else {
                                    return
                                }
                                
                                URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
                                    guard let data = data else {
                                        return
                                    }
                                    
                                    let filename = chatUser.profilePictureFileName
                                    StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { result in
                                        switch result {
                                        case .success(let downloadUrl):
                                            UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                            print(downloadUrl)
                                        case .failure(let error):
                                            print("Storage maanger error: \(error)")
                                        }
                                    })
                                }).resume()
                            }
                        }
                    }
                }
            }
            
            
            
            guard let authentication = user?.authentication,
                  let idToken = authentication.idToken else {
                print("Missing of google user")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            // Authenticate with Firebase using the credential object
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("Error occurs when authenticate with Firebase: \(error.localizedDescription)")
                }
                
                // Present the main view
                self.navigationController?.dismiss(animated: false)
            }
        }
    }
    
    
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            loginButtonTapped()
        }
        
        return true
    }
    
}

extension LoginViewController: LoginButtonDelegate{
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        // no operation
    }
    
    func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User failed with facebook")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields":
                                                                        "email, first_name, last_name, picture.type(large)"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        
        facebookRequest.start { _, result, error in
            guard let result = result as? [String:Any], error == nil else {
                print("failed to make facebook graph request")
                return
            }
            print("\(result)")
            guard let firstName = result["first_name"] as? String,
                  let lastName = result["last_name"] as? String,
                  let email = result["email"] as? String,
                  let picture = result["picture"] as? [String: Any],
                  let data = picture["data"] as? [String: Any],
                  let pictureUrl = data["url"] as? String else {
                print("Faield to get email and name from fb result")
                return
            }
            
            UserDefaults.standard.set(email, forKey: "email")
            DatabaseManager.shared.userExists(with: email) { exists in
                if !exists{
                    let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAdress: email)
                    DatabaseManager.shared.insertUser(with: chatUser) { success in
                        if success{
                            guard let url = URL(string: pictureUrl) else {
                                return
                            }
                            
                            print("Downloading data from facebook image")
                            
                            URLSession.shared.dataTask(with: url, completionHandler: { data, _,_ in
                                guard let data = data else {
                                    print("Failed to get data from facebook")
                                    return
                                }
                                
                                print("got data from FB, uploading...")
                                
                                // upload image
                                let filename = chatUser.profilePictureFileName
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { result in
                                    switch result {
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                        print(downloadUrl)
                                    case .failure(let error):
                                        print("Storage maanger error: \(error)")
                                    }
                                })
                            }).resume()
                        }
                    }
                }
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                guard let strongSelf = self else {return}
                guard authResult != nil,error == nil else{
                    print("error Auth.auth().signIn FACEBOOK \(error)")
                    return
                }
                print("Success FACEBOOK")
                strongSelf.navigationController?.dismiss(animated: true)
            }
            
        }
        
        
    }
    
    
}
