//
//  ViewController.swift
//  ContactManager
//
//  Created by Jin-Mac on 1/4/24.
//

import UIKit

class ContactViewController: UIViewController {
    
    
    private let contactManager = ContactMananger()
    private let cellIdentifier = "ContactCustomCell"

    @IBOutlet weak var contactTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        loadContactData()
    }
    
    private func configure() {
        self.contactTableView.dataSource = self
    }
    
    private func loadContactData() {
        let decoder = JSONDecoder()
        guard let dataAssets: NSDataAsset = NSDataAsset(name: "Dummy") else { return }
        
        do {
            let dummyData = try decoder.decode([Contact].self, from: dataAssets.data)
            contactManager.initializeContact(contactData: dummyData)
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.showAlert(title: "알림", message: "데이터 불러오기 실패")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let addedModalView = segue.destination as? AddedContactViewController else {
           return showAlert(title: "", message: "뷰 생성 실패")
        }
        addedModalView.delegate = self
    }
}

extension ContactViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactManager.contactCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let customCell: ContactCustomCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ContactCustomCell else {
            return ContactCustomCell()
        }
        
        let contact = contactManager.fetchContact(index: indexPath.row)
        
        switch contact {
        case .success(let data):
            customCell.nameLabel.text = data.fetchedName
            customCell.ageLabel.text = data.fetchedAge
            customCell.phoneNumberLabel.text = data.fetchedPhoneNumber
        case .failure(let error):
            showAlert(title: "알림", message: error.errorMessage)
        }
        
        return customCell
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        contactManager.deleteContact(index: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}

extension ContactViewController: addedContactDelegate {
    
    func addNewContact(name: String, age: Int, phoneNumber: String) {
        contactManager.addContact(newName: name, newAge: age, newPhoneNumber: phoneNumber)
        let indexPath = IndexPath(row: contactManager.contactCount - 1, section: 0)
        contactTableView.insertRows(at: [indexPath], with: .automatic)
    }
}
