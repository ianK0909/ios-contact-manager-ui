//
//  ContactViewController.swift
//  ContactManagerUI
//
//  Created by 신동오 on 2023/01/30.
//

import UIKit

final class ContactViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet private weak var contactTableView: UITableView!

    private let contactDataSource = ContactDataSource()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchContactData()
    }

    // MARK: - Helpers
    private func setupTableView() {
        contactTableView.dataSource = contactDataSource
    }

    private func fetchContactData() {
        // 임시 연락처 데이터
        mockupContacts.forEach {
            ContactManager.shared.add(contact: $0)
        }
        contactTableView.reloadData()
    }
}
