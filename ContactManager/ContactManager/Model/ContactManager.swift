//
//  ContactStorage.swift
//  ContactManager
//
//  Created by MAC2020 on 2024/01/04.
//

import Foundation

final class ContactMananger {
    
    private var storage: [Contact] = []
    
    var contactCount: Int {
        return storage.count
    }
    
    func initializeContact(contactData: [Contact]) {
        storage = contactData
    }
    
    func fetchContact(index: Int) -> Result<Contact, ContactManangerError> {
        if storage.isEmpty { return .failure(.contactEmpty) }
        if (0 > index || storage.count <= index) { return .failure(.contactExist) }
        return .success(storage[index])
    }
    
    func addContact(newName: String, newAge: Int, newPhoneNumber: String) {
        storage.append(Contact(name: newName, age: newAge, phoneNumber: newPhoneNumber))
    }
    
    func deleteContact(index: Int) {
        storage.remove(at: index)
    }
    
    func fetchStorage() -> [Contact] {
        return storage
    }
}
