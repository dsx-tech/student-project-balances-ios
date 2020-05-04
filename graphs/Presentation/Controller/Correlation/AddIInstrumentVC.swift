//
//  AddIInstrumentVC.swift
//  graphs
//
//  Created by Danila Ferents on 18.02.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import UIKit
import iOSDropDown

class AddIInstrumentVC: UIViewController {

	//Outlets
	@IBOutlet weak var dateTextField: RoundedTextField!
	let datePicker = UIDatePicker()

	@IBOutlet weak var firstInstrumentPicker: DropDown!
	@IBOutlet weak var secondInstrumentPicker: DropDown!

	@IBOutlet weak var saveBtn: RoundedButton!
	@IBOutlet weak var periodSegmentControl: UISegmentedControl!

	//Variables
	var firstInstrument: String!
	var secondInstrument: String!
	var date: String!
	var period: DurationQuotes = .month
	var vc: CorrelationVC!

	var basecurrency = "usd"
	let formatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
		setUpDropDowns()
		setUpToolBar()
		setUpDateTextFields()
    }

	@IBAction func savePicked(_ sender: Any) {
		guard let firstInstrument = self.firstInstrument else {
			self.simpleAlert(title: "Error", msg: "Please select first asset.")
			return
		}
		guard let secondInstrument = self.secondInstrument else {
			self.simpleAlert(title: "Error", msg: "Please select second asset.")
			return
		}
		if firstInstrument == secondInstrument {
			self.simpleAlert(title: "Error", msg: "Assets must not be equal")
		}
		guard let dateString = self.date, let date = formatter.date(from: dateString) else {
			self.simpleAlert(title: "Error", msg: "Please select date.")
			return
		}
		vc.callculatecorrelation(firstinstrument: firstInstrument,
								 secondinstrument: secondInstrument,
								 startDate: date,
								 duration: period)
		self.dismiss(animated: true, completion: nil)
	}
}

// - MARK: Set up functions

extension AddIInstrumentVC {
	func setUpDropDowns() {

		self.firstInstrumentPicker.optionArray = assets
		self.firstInstrumentPicker.didSelect { (selectedAsset, _, _) in
			self.firstInstrument = selectedAsset
			self.enableButton()
		}
		self.firstInstrumentPicker.layer.cornerRadius = 10
		self.firstInstrumentPicker.backgroundColor = UIColor.white
		self.firstInstrumentPicker.layer.borderColor = UIColor.gray.cgColor
		self.firstInstrumentPicker.layer.borderWidth = 1.0
		self.firstInstrumentPicker.clipsToBounds = true

		self.secondInstrumentPicker.optionArray = assets
		self.secondInstrumentPicker.didSelect { (selectedAsset, _, _) in
			self.secondInstrument = selectedAsset
			self.enableButton()
		}
		self.secondInstrumentPicker.layer.cornerRadius = 10
		self.secondInstrumentPicker.backgroundColor = UIColor.white
		self.secondInstrumentPicker.layer.borderColor = UIColor.gray.cgColor
		self.secondInstrumentPicker.layer.borderWidth = 1.0
		self.secondInstrumentPicker.clipsToBounds = true

	}

	func setUpDateTextFields() {

		self.dateTextField.inputView = self.datePicker

		self.datePicker.datePickerMode = .date

		let localeID = Locale.preferredLanguages.first
		self.datePicker.locale = Locale(identifier: localeID ?? "")

		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

		if let start = formatter.date(from: "2019-01-01T00:00:01") {
			self.datePicker.date = start
			self.date = "2019-01-01T00:00:01"
			self.dateTextField.text = "01.01.2019 00:00"
		}
	}

	func setUpToolBar() {

		let toolbarStart = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 400))
		toolbarStart.barStyle = .default

		toolbarStart.sizeToFit()

		toolbarStart.tintColor = UIColor.blue

		toolbarStart.isUserInteractionEnabled = true

		let doneActionStart = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneActionStartFunc))
		let cancelStart = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelFunc))

		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

		toolbarStart.setItems([cancelStart, flexSpace, doneActionStart], animated: true)

		dateTextField.inputAccessoryView = toolbarStart
	}
}

// - MARK: DatePickers

extension AddIInstrumentVC {
	func enableButton() {
		if self.date != nil && self.firstInstrument != nil && self.secondInstrument != nil {
			self.saveBtn.isEnabled = true
		} else {
			self.saveBtn.isEnabled = false
		}
	}
}

// - MARK: DatePickers

extension AddIInstrumentVC {

	@objc func cancelFunc() {
		view.endEditing(true)
	}

	@objc func doneActionStartFunc() {
		if datePicker.date > Date(timeIntervalSinceNow: 0) {
			self.simpleAlert(title: "Error!", msg: "Start date must be less than today")
		} else {
			self.date = getDataFromStartPicker()
			self.enableButton()
			view.endEditing(true)
		}
	}

	func getDataFromStartPicker() -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd.MM.yyyy HH:mm"
		dateTextField.text = formatter.string(from: datePicker.date)
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		return formatter.string(from: datePicker.date)
	}
}

// - MARK: SegmentControl

extension AddIInstrumentVC {
	@IBAction func indexChanged(_ sender: Any) {
		switch self.periodSegmentControl.selectedSegmentIndex {
		case 0:
			self.period = .month
		case 1:
			self.period = .threemonths
		case 2:
			self.period = .sixmonths
		case 3:
			self.period = .year
		default:
			print("Error in duration!")
		}
	}
}
