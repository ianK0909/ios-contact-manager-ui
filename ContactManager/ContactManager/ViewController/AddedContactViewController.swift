//
//  AddedContactViewController.swift
//  ContactManager
//
//  Created by Jin-Mac on 1/15/24.
//

import UIKit

protocol SendContactData {
    func addNewContact(name: String, age: Int, phoneNumber: String)
}

class AddedContactViewController: UIViewController {
    
    var delegate: SendContactData?

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func touchUpSaveButton(_ sender: UIButton) {
        addDistinguished()
    }
    
    @IBAction func touchUpCancelButton(_ sender: UIButton) {
        showConfirmationAlert(title: "", message: "정말로 취소하시겠습니까?") { _ in
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func fetchName() throws -> String {
        let addedName = nameTextField.text
        guard let name = addedName?.components(separatedBy: [" "]).joined(), String(name).count != 0 else {
            throw AddedContactError.nameMistake
        }
        return name
    }
    
    func fetchAge() throws -> Int {
        guard let ageText = ageTextField.text,
                ageText.allSatisfy({ $0.isNumber }),
                String(ageText).count <= 3,
                let addedAge = Int(ageText)
        else {
            throw AddedContactError.ageMistake
        }
        return addedAge
    }
    
    private func fetchPhoneNumber() throws -> String {
        guard let addedPhoneNumber = phoneNumberTextField.text,
              addedPhoneNumber.filter({ $0 == "-" }).count == 2
        else {
            throw AddedContactError.phoneNumberMistake
        }
        let lastIndex = addedPhoneNumber.index(before: addedPhoneNumber.endIndex)
        
        if (addedPhoneNumber[addedPhoneNumber.startIndex] == "-") ||
            (addedPhoneNumber[lastIndex]) == "-" {
            throw AddedContactError.phoneNumberMistake
        }
        
        let integerText = addedPhoneNumber.components(separatedBy: ["-"]).joined()
        guard integerText.allSatisfy({ $0.isNumber }),
              integerText.filter({ $0.isNumber }).count >= 9
        else {
            throw AddedContactError.phoneNumberMistake
        }
        return addedPhoneNumber
    }
    
    func addDistinguished() {
        var name: String = String()
        var age: Int = Int()
        var phoneNumber: String = String()
        let isAdded = Result {
            name = try fetchName()
            age = try fetchAge()
            phoneNumber = try fetchPhoneNumber()
        }
        switch isAdded {
        case .success():
            delegate?.addNewContact(name: name, age: age, phoneNumber: phoneNumber)
            self.dismiss(animated: true)
        case .failure(let error):
            guard let error: AddedContactError = error as? AddedContactError else { return }
            showAlert(title: "", message: error.errorMessage)
        }
    }
}
