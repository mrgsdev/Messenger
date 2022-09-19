//
//  NewConverstationViewController.swift
//  Messenger
//
//  Created by MRGS on 12.09.2022.
//

import UIKit
import JGProgressHUD
class NewConversationViewController: UIViewController {

    private let spinner = JGProgressHUD()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users..."
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dissmissSelf))
        searchBar.becomeFirstResponder()
    }
     
    @objc private func dissmissSelf(){
        dismiss(animated: true)
    }
}
extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: " ").isEmpty else {
            return
        }
        
       
    }
    
}
