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
    var filteredContact: [Contact] = []
    var isFiltering: Bool {
        let searchController = contactNavigation.searchController
        let isActive = searchController?.isActive ?? false
        let isSearchBarHasText = searchController?.searchBar.text?.isEmpty == false
        return isActive && isSearchBarHasText
    }

    @IBOutlet weak var contactTableView: UITableView!
    @IBOutlet weak var contactNavigation: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        loadContactData()
        setSearchController()
    }
    
    func setSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        contactNavigation.searchController = searchController
        searchController.searchBar.placeholder = "Name or PhoneNumber"
        contactNavigation.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.automaticallyShowsCancelButton = true
        searchController.searchResultsUpdater = self
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
        return self.isFiltering ? filteredContact.count : contactManager.contactCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let customCell: ContactCustomCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ContactCustomCell else {
            return ContactCustomCell()
        }
        
        if self.isFiltering {
            let testContact = filteredContact[indexPath.row]
            customCell.nameLabel.text = testContact.fetchedName
            customCell.ageLabel.text = testContact.fetchedAge
            customCell.phoneNumberLabel.text = testContact.fetchedPhoneNumber
        } else {
            let contact = contactManager.fetchContact(index: indexPath.row)
            switch contact {
            case .success(let data):
                customCell.nameLabel.text = data.fetchedName
                customCell.ageLabel.text = data.fetchedAge
                customCell.phoneNumberLabel.text = data.fetchedPhoneNumber
            case .failure(let error):
                showAlert(title: "알림", message: error.errorMessage)
            }
        }
        
        return customCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        contactManager.deleteContact(index: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}

extension ContactViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.lowercased() else { return }
        filteredContact = self.contactManager.fetchStorage().filter {
            $0.fetchedName.localizedCaseInsensitiveContains(text) ||
            $0.fetchedPhoneNumber.localizedCaseInsensitiveContains(text)
        }
        contactTableView.reloadData()
    }
}

extension ContactViewController: addedContactDelegate {
    
    func addNewContact(name: String, age: Int, phoneNumber: String) {
        contactManager.addContact(newName: name, newAge: age, newPhoneNumber: phoneNumber)
        let indexPath = IndexPath(row: contactManager.contactCount - 1, section: 0)
        contactTableView.insertRows(at: [indexPath], with: .automatic)
    }
}
