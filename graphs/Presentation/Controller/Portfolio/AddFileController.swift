//
//  AddFileController.swift
//  graphs
//
//  Created by Danila Ferents on 12.04.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import UIKit
import CoreServices

class AddFileController: UIViewController {

	//Outlets
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var bottomCnstr: NSLayoutConstraint!

	//Variables
	var id: String!
	var isTrades: Bool!

	override func viewDidLoad() {
		super.viewDidLoad()
		setUpKeyboardDismiss()
	}

	func setUpKeyboardDismiss() {
		//add toolbar to the top of the keyboard to be able to hide it
		let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
		toolbar.barStyle = .default
		toolbar.items = [
			UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
			UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
		]
		textField.inputAccessoryView = toolbar
		//add recogniser to hide keyboard
		let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
		view.addGestureRecognizer(tap)

		//observe keyboard notifications
		NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
	}

	@objc func handleKeyboardNotification(notification: Notification) {

		if let userInfo = notification.userInfo {

			let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
			let isshowNotification = notification.name == UIResponder.keyboardWillShowNotification

			if let newheight = keyboardFrame {
				bottomCnstr.constant = isshowNotification ? -newheight.height : 0
			}

			UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
				self.view.layoutIfNeeded()
			})
		}
	}

	@objc func doneAction() {
		textField.resignFirstResponder()
	}

	@IBAction func AddTransactionsBtnClicked(_ sender: Any) {
		let picker = UIDocumentPickerViewController(documentTypes: [kUTTypeCommaSeparatedText as String], in: .open)
		picker.delegate = self
		textField.resignFirstResponder()
		guard let id = textField.text, id.isNotEmpty  else {
			simpleAlert(title: "Error.", msg: "Please fill out portfolio id.")
			return
		}
		self.id = id
		self.isTrades = false
		present(picker, animated: true, completion: nil)
	}

	@IBAction func AddTradesBtnClicked(_ sender: Any) {
		let picker = UIDocumentPickerViewController(documentTypes: [kUTTypeCommaSeparatedText as String], in: .open)
		picker.delegate = self
		textField.resignFirstResponder()
		guard let id = textField.text, id.isNotEmpty  else {
			simpleAlert(title: "Error.", msg: "Please fill out portfolio id.")
			return
		}
		self.id = id
		self.isTrades = true
		present(picker, animated: true, completion: nil)
	}
	
}

// MARK: - UIDocumentPickerDelegate

extension AddFileController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}

// MARK: - UIDocumentPickerDelegate

extension AddFileController: UIDocumentPickerDelegate {
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		guard let isTrades = self.isTrades, let id = Int(self.id), let url = urls.first else {
			simpleAlert(title: "Error.", msg: "Error in uploading")
			return
		}
		if isTrades {
			PortfolioApi.sharedManager.uploadTransactions(id: id, fileUrl: url) { [weak self] (result) in

				guard let self = self else {
					print("No Instance more!")
					return
				}

				self.presentError(result: result)
			}
		} else {
			PortfolioApi.sharedManager.uploadTrades(id: id, fileUrl: url) { [weak self] (result) in

				guard let self = self else {
					print("No Instance more!")
					return
				}
				self.presentError(result: result)
			}
		}
	}

	func presentError(result: Bool) {
		DispatchQueue.main.async {
			if result {
				self.simpleAlert(title: "Success!", msg: "Uploaded.")
			} else {
				self.simpleAlert(title: "Error.", msg: "Error in uploading")
			}
		}
	}
}
