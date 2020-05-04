//
//  AddTradeController.swift
//  graphs
//
//  Created by Danila Ferents on 28.04.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import UIKit
import iOSDropDown

class DropDownRounded: DropDown {
	override func awakeFromNib() {
		super.awakeFromNib()
		self.layer.cornerRadius = 10
		self.backgroundColor = UIColor.white
		self.layer.borderColor = UIColor.gray.cgColor
		self.layer.borderWidth = 1.0
		self.clipsToBounds = true
	}
}

class DropDownRoundedAssets: DropDownRounded {
	override func awakeFromNib() {
		super.awakeFromNib()
		self.optionArray = assets
	}
}

class AddTradeController: UIViewController {

	//Outlets
	@IBOutlet weak var dateTextField: RoundedTextField!
	let datePicker = UIDatePicker()
	@IBOutlet weak var idTextField: RoundedTextField!
	@IBOutlet weak var firstAssetTextField: DropDownRoundedAssets!
	@IBOutlet weak var secondAssetTextField: DropDownRoundedAssets!
	@IBOutlet weak var quantityTextField: RoundedTextField!
	@IBOutlet weak var quantityCurrencyTextField: DropDownRoundedAssets!
	@IBOutlet weak var priceTextField: RoundedTextField!
	@IBOutlet weak var priceCurrencyTextField: DropDownRoundedAssets!
	@IBOutlet weak var comissionTextField: RoundedTextField!
	@IBOutlet weak var comissionCurrencyTextField: DropDownRoundedAssets!
	@IBOutlet weak var valueIdTextField: RoundedTextField!
	@IBOutlet weak var tradeTypeSegmentControl: UISegmentedControl!
	let formatter = DateFormatter()
	@IBOutlet var gesture: UITapGestureRecognizer!

	//Variable
	var firstAsset: String!
	var secondAsset: String!
	var quantityCurrency: String!
	var priceCurrency: String!
	var comissionCurrency: String!
	var date: Date!
	var ids: [Int]!

	override func viewDidLoad() {
		super.viewDidLoad()
		self.gesture.delegate = self
		setUpToolBar()
		setUpDateTextFields()
		setUpDropDowns()
	}

	@IBAction func gestureTapped(_ sender: Any) {
		self.view.endEditing(true)
	}

	@IBAction func saveTradeClicked(_ sender: Any) {
		guard let date = self.date else {
			self.simpleAlert(title: "Error", msg: "Please input data.")
			return
		}

		guard let firstAsset = self.firstAsset else {
			self.simpleAlert(title: "Error", msg: "Please unput first active.")
			return
		}

		guard let secondAsset = self.secondAsset else {
			self.simpleAlert(title: "Error", msg: "Please input second active.")
			return
		}

		guard let quantityCurrency = self.quantityCurrency else {
			self.simpleAlert(title: "Error", msg: "Please input quantity currency.")
			return
		}

		guard let priceCurrency = self.priceCurrency else {
			self.simpleAlert(title: "Error", msg: "Please input price currency.")
			return
		}

		guard let comissionCurrency = self.comissionCurrency else {
			self.simpleAlert(title: "Error", msg: "Please input comission currency.")
			return
		}

		guard  quantityTextField.text != "", let quantity = Double(quantityTextField.text ?? "") else {
			self.simpleAlert(title: "Error", msg: "Invalid format in quantity.")
			return
		}

		guard priceTextField.text != "", let price = Double(priceTextField.text ?? "") else {
			self.simpleAlert(title: "Error", msg: "Invalid format in price.")
			return
		}

		guard comissionTextField.text != "", let comission = Double(comissionTextField.text ?? "") else {
			self.simpleAlert(title: "Error", msg: "Invalid format in comission.")
			return
		}

		guard idTextField.text != "", let id = Int(idTextField.text ?? "") else {
			self.simpleAlert(title: "Error", msg: "Invalid format in id.")
			return
		}

		guard valueIdTextField.text != "", let valueId = Int(valueIdTextField.text ?? "") else {
			self.simpleAlert(title: "Error", msg: "Invalid format in value id.")
			return
		}

		let selectedType = self.tradeTypeSegmentControl.selectedSegmentIndex == 0 ? "Sell" : "Buy"

		let trade = Trade(id: Int64(id),
						  dateTime: date,
						  instrument: "\(firstAsset)-\(secondAsset)",
			tradeType: selectedType,
			tradedQuantity: quantity,
			tradedQuantityCurrency: quantityCurrency,
			tradedPrice: price,
			tradedPriceCurrency: priceCurrency,
			commission: comission, commissionCurrency:
			comissionCurrency,
			tradeValueId: String(valueId))

		PortfolioApi.sharedManager.addTradeInPortfolios(ids: self.ids, trade: trade) { (result) in
			DispatchQueue.main.async {
				if result {
					self.dismiss(animated: true, completion: nil)
				} else {
					self.simpleAlert(title: "Error", msg: "Error in uploading Trade")
				}
			}
		}
	}

	@IBAction func cancelBtnClicked(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}

}

// - MARK: Set Up functions

extension AddTradeController {
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

	func setUpDropDowns() {
		self.firstAssetTextField.didSelect { (asset, _, _) in
			self.firstAsset = asset
		}

		self.secondAssetTextField.didSelect { (asset, _, _) in
			self.secondAsset = asset
		}

		self.quantityCurrencyTextField.didSelect { (asset, _, _) in
			self.quantityCurrency = asset
		}

		self.priceCurrencyTextField.didSelect { (asset, _, _) in
			self.priceCurrency = asset
		}

		self.comissionCurrencyTextField.didSelect { (asset, _, _) in
			self.comissionCurrency = asset
		}
	}
}

// - MARK: DatePickers

extension AddTradeController {

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

// - MARK: DatePickers

extension AddTradeController: UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}

//	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//		if type(of: touch.view) == UITableViewCell. {
//			return false
//		}
//		return true
//	}
}
