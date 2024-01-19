//
//  AddedContactViewController.swift
//  ContactManager
//
//  Created by Jin-Mac on 1/15/24.
//

import UIKit

protocol addedContactDelegate: AnyObject {
     func addNewContact(name: String, age: Int, phoneNumber: String)
}

final class AddedContactViewController: UIViewController {
    
    weak var delegate: addedContactDelegate?

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    @IBAction func touchUpSaveButton(_ sender: UIButton) {
        validateContant()
    }
    
    @IBAction func touchUpCancelButton(_ sender: UIButton) {
        showConfirmationAlert(title: "", message: "정말로 취소하시겠습니까?") { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
        
    }
    
    private func configure() {
        self.phoneNumberTextField.delegate = self
        self.ageTextField.delegate = self
        self.phoneNumberTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    private func fetchName() throws -> String {
        let addedName = nameTextField.text
        guard let name = addedName?.components(separatedBy: [" "]).joined(), String(name).count != 0 else {
            throw AddedContactError.nameMistake
        }
        return name
    }
    
    private func fetchAge() throws -> Int {
        guard let ageText = ageTextField.text,
              ageText.allSatisfy({ $0.isNumber }),
              String(ageText).count <= NumberNameSpace.ageDigitLimit,
              let addedAge = Int(ageText)
        else {
            throw AddedContactError.ageMistake
        }
        return addedAge
    }
    
    private func fetchPhoneNumber() throws -> String {
        guard let addedPhoneNumber = phoneNumberTextField.text else {
            throw AddedContactError.phoneNumberMistake
        }
        let integerText = addedPhoneNumber.components(separatedBy: ["-"]).joined()
        guard integerText.allSatisfy({ $0.isNumber }),
              integerText.filter({ $0.isNumber }).count >= NumberNameSpace.phoneNumberMin
        else {
            throw AddedContactError.phoneNumberMistake
        }
        return addedPhoneNumber
    }
    
    private func validateContant() {
        let isAdded = Result {
            let name = try fetchName()
            let age = try fetchAge()
            let phoneNumber = try fetchPhoneNumber()
            return (name, age, phoneNumber)
        }
        switch isAdded {
        case .success(let (name, age, phoneNumber)):
            addConditionSucceed(name: name, age: age, phoneNumber: phoneNumber)
        case .failure(let error):
            guard let error: AddedContactError = error as? AddedContactError else { return }
            showAlert(title: "", message: error.errorMessage)
        }
    }
    
    private func addConditionSucceed(name: String, age: Int, phoneNumber: String) {
        delegate?.addNewContact(name: name, age: age, phoneNumber: phoneNumber)
        self.dismiss(animated: true)
    }
}

extension AddedContactViewController: UITextFieldDelegate {
    
    @objc func textFieldDidChange(_ sender: Any?) {
        guard let phoneNumber = phoneNumberTextField.text?.components(separatedBy: ["-"]).joined() else { return }
        phoneNumberTextField.text = phoneNumber.formatConversionPhoneNumber()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
        }
        guard let regex = distinguishRegularExpression(textField: textField) else { return false }
        guard let _ = string.range(of: regex, options: .regularExpression) else { return false }
        return true
    }
    
    func distinguishRegularExpression(textField: UITextField) -> String? {
        
        switch textField.tag {
        case TextFieldTagNameSpace.age:
            guard let count = textField.text?.count,
                  count < NumberNameSpace.ageDigitLimit else {
                return nil
            }
            return RegexNameSpace.age
        case TextFieldTagNameSpace.phoneNumber:
            return RegexNameSpace.phoneNumber
        default:
            return nil
        }
    }
}

