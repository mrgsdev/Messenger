//
//  ViewController.swift
//  Messenger
//
//  Created by MRGS on 12.09.2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
class ConverstationsViewController: UIViewController {
    
    //MARK: - @IBOutlet
    private let spinner = JGProgressHUD(style: .dark)
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    let noConverstationLabel: UILabel = {
        let label = UILabel()
        label.text = "No Converstations!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        view.backgroundColor = .systemPink
        view.addSubview(tableView)
        view.addSubview(noConverstationLabel)
        setupTableView()
        fetchConverstations()
    }
    
    
    @objc func didTapComposeButton(){
        let vc = NewConversationViewController()
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true ) 
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    private func validateAuth(){
        if Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: false)
        }
    }
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    private func fetchConverstations()  {
        tableView.isHidden = false
        
    }
}

extension ConverstationsViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Hello"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ChatViewController()
        vc.title = "Jenny Smith"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
}
