//
//  ProfileViewController.swift
//  Messenger
//
//  Created by MRGS on 12.09.2022.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
class ProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let data = ["Log Out"]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.backgroundColor = .systemPink
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
    }
    
    func createTableHeader() -> UIView? {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return nil }

        let safeEmail = DatabaseManager.safeEmail(emailAdress: email)
        let filename = safeEmail + "_profile_pic.png"
        
        let path = "images/"+filename
        
        print(path)
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 300))
        headerView.backgroundColor = .link
        let imageView = UIImageView(frame: CGRect(x: (headerView.width-150)/2, y: 75, width: 150, height: 150))
        
        headerView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
   
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width / 2
        
        StorageManager.shared.downloadURL(for: path) { [weak self] result in
            switch result {
            case .success(let url):
                self?.downloadImage(imageView: imageView, url: url)
            case .failure(let error):
                print("ERROR downlaod url")
            }
        }
        return headerView
    }
    
    func downloadImage(imageView:UIImageView,url:URL)  {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data,error == nil else{
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
                print(image)
                imageView.backgroundColor = .white
            }
        }.resume()
    }
}
extension ProfileViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: {[weak self] _ in
            guard let strongSelf = self else { return }
            FBSDKLoginKit.LoginManager().logOut() // Facebook Log Out
            GIDSignIn.sharedInstance.signOut() // Google Log Out
            do {
                try Auth.auth().signOut()
                if Auth.auth().currentUser == nil {
                    let vc = LoginViewController()
                    let navVC = UINavigationController(rootViewController: vc)
                    navVC.modalPresentationStyle = .fullScreen
                    strongSelf.present(navVC, animated: true)
                }
            } catch  {
                print("Failed signOut")
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true)
        
    }
    
    
}
