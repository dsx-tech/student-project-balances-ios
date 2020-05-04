//
//  AddTransactionController.swift
//  graphs
//
//  Created by Danila Ferents on 29.04.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import UIKit
import iOSDropDown

class AddTransactionController: UIViewController {
	//Outlets
	@IBOutlet weak var dateTextField: RoundedTextField!
	let datePicker = UIDatePicker()
	@IBOutlet weak var idTextField: RoundedTextField!
	@IBOutlet weak var transactionTypeSegmentControl: UISegmentedControl!
	@IBOutlet weak var amountTextField: RoundedTextField!
	@IBOutlet weak var currencyTextField: DropDownRoundedAssets!
	@IBOutlet weak var comissionTextField: RoundedTextField!
	@IBOutlet weak var valueIdTextField: RoundedTextField!
	@IBOutlet weak var saveBtn: UIButton!
	
	var date: Date!
	var currency: String!
	var ids: [Int]!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setUpToolBar()
		setUpDateTextFields()
		setUpDropDowns()
	}
	
	@IBAction func gestureTapped(_ sender: Any) {
		self.view.endEditing(true)
	}
	
	@IBAction func saveBtnClicked(_ sender: Any) {
		guard let date = self.date else {
			self.simpleAlert(title: "Error", msg: "Please input data.")
			return
		}
		
		guard let currency = self.currency else {
			self.simpleAlert(title: "Error", msg: "Please input currency!")
			return
		}
		
		guard idTextField.text != "", let id = Int(idTextField.text ?? "") else {
			self.simpleAlert(title: "Error", msg: "Invalid format in id.")
			return
		}
		
		guard amountTextField.text != "", let amount = Double(amountTextField.text ?? "") else {
			self.simpleAlert(title: "Error", msg: "Invalid format in amount")
			return
		}
		
		guard self.comissionTextField.text != "", let comission = Double(comissionTextField.text ?? "") else {
			self.simpleAlert(title: "Error", msg: "Invalid format in comission")
			return
		}
		
		guard self.valueIdTextField.text != "", let valueId = Int(valueIdTextField.text ?? "") else {
			self.simpleAlert(title: "Error", msg: "Invalid format in valueId")
			return
		}
		
		let selectedType = self.transactionTypeSegmentControl.selectedSegmentIndex == 0 ? "Withdraw" : "Deposit"
		
		let transaction = Transaction(id: UInt64(id),
									  dateTime: date,
									  amount: amount,
									  currency: currency,
									  transactionValueId: String(valueId),
									  transactionStatus: "Complete", transactionType: selectedType,
									  commission: comission)
		
		PortfolioApi.sharedManager.addTransactionInPortfolios(ids: self.ids, transaction: transaction) { (result) in
			DispatchQueue.main.async {
				if result {
					self.dismiss(animated: true, completion: nil)
				} else {
					self.simpleAlert(title: "Error", msg: "Error in uploading Transaction")
				}
			}
		}
	}
	
	@IBAction func cancelBtnClicked(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
}

// - MARK: Set Up functions

extension AddTransactionController {
	func setUpToolBar() {
		
		let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 400))
		toolbar.barStyle = .default
		
		toolbar.sizeToFit()
		
		toolbar.tintColor = UIColor.blue
		
		toolbar.isUserInteractionEnabled = true
		
		let doneAction = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneActionDateFunc))
		let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelFunc))
		
		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		
		toolbar.setItems([cancel, flexSpace, doneAction], animated: true)
		
		dateTextField.inputAccessoryView = toolbar
	}
	
	func setUpDateTextFields() {
		
		self.dateTextField.inputView = self.datePicker
		
		self.datePicker.datePickerMode = .date
		
		let localeID = Locale.preferredLanguages.first
		self.datePicker.locale = Locale(identifier: localeID ?? "")
	}
	
	func setUpDropDown() {
		self.currencyTextField.didSelect { (asset, _, _) in
			self.currency = asset
		}
	}
	
	func setUpDropDowns() {
		self.currencyTextField.didSelect { (asset, _, _) in
			self.currency = asset
		}
	}
}

// - MARK: DatePickers

extension AddTransactionController {
	
	@objc func doneActionDateFunc() {
		self.date = getDataFromPicker()
		view.endEditing(true)
	}
	
	@objc func cancelFunc() {
		view.endEditing(true)
	}
	
	func getDataFromPicker() -> Date {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd.MM.yyyy HH:mm"
		dateTextField.text = formatter.string(from: datePicker.date)
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		return datePicker.date
	}
}
