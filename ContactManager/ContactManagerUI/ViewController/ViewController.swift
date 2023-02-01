//
//  ViewController.swift
//  ContactManagerUI
//
//  Created by 신동오 on 2023/01/30.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var contactTableView: UITableView!
    
    private var contacts: [Contact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        contacts = mockupContacts
    }
    
    private func setupTableView() {
        contactTableView.dataSource = self
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = contactTableView.dequeueReusableCell(withIdentifier: ContactCell.reuseIdentifier, for: indexPath) as? ContactCell,
              let contact = contacts[safe: indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.configure(with: contact)
        
        return cell
    }
    
    
}


