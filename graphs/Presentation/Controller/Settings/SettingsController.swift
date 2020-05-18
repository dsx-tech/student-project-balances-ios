//
//  SettingsController.swift
//  
//
//  Created by Danila Ferents on 17.05.20.
//

import UIKit
import KeychainAccess

class SettingsController: UIViewController {

	//Outlets
	@IBOutlet weak var baseAssetSegmentController: UISegmentedControl!
	//Variables

	override func viewDidLoad() {
        super.viewDidLoad()
    }
	@IBAction func logOutClicked(_ sender: Any) {
		let targetStoryboardName = "LoginStoryboard"
		let targetStoryboard = UIStoryboard(name: targetStoryboardName, bundle: nil)
		if let targetVC = targetStoryboard.instantiateInitialViewController() {
			targetVC.modalPresentationStyle = .fullScreen
			self.present(targetVC, animated: true, completion: nil)
		}
	}
	@IBAction func portfoliosClicked(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
}

// - MARK: SegmentControl

extension SettingsController {
	@IBAction func indexChanged(_ sender: Any) {
		switch self.baseAssetSegmentController.selectedSegmentIndex {
		case 0:
			setUpUsd()
		case 1:
			setUpEuro()
		default:
			print("Error in segment control!")
		}
	}

	func setUpUsd() {
		let keychain = Keychain(service: "swagger")
		keychain["base_currency_img"] = "$"
		keychain["base_currency"] = "usd"
	}

	func setUpEuro() {
		let keychain = Keychain(service: "swagger")
		keychain["base_currency_img"] = "€"
		keychain["base_currency"] = "eur"
	}
}
