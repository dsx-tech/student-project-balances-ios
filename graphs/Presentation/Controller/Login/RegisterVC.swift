//
//  RegisterVC.swift
//  graphs
//
//  Created by Danila Ferents on 12.03.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import UIKit
import KeychainAccess

class RegisterVC: UIViewController {
	//Outlets
	@IBOutlet weak var usernameTxt: UITextField!
	@IBOutlet weak var emailTxt: UITextField!
	@IBOutlet weak var passwordTxt: UITextField!
	@IBOutlet weak var confirmPassTxt: UITextField!
	@IBOutlet weak var activIndicator: UIActivityIndicatorView!

	@IBOutlet weak var passwordCheck: UIImageView!
	@IBOutlet weak var confirmpasswordCheck: UIImageView!
	var auth: AuthResponse!

	override func viewDidLoad() {
		super.viewDidLoad()
		let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
		view.addGestureRecognizer(tap)
		//monitor password changing
		passwordTxt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
		confirmPassTxt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
	}

	//function to minotr password changing
	@objc func textFieldDidChange(_ textField: UITextField) {
		guard let passTxt = passwordTxt.text else { return }

		if textField == confirmPassTxt {
			passwordCheck.isHidden = false
			confirmpasswordCheck.isHidden = false
		} else {
			if passTxt.isEmpty {
				passwordCheck.isHidden = true
				confirmpasswordCheck.isHidden = true
				confirmPassTxt.text = ""
			}
		}

		// Method is called to make checkmarks green when password matches
		if passwordTxt.text == confirmPassTxt.text {
			passwordCheck.image = UIImage(named: ImageIdtf.greenCheck)
			confirmpasswordCheck.image = UIImage(named: ImageIdtf.greenCheck)
		} else {
			passwordCheck.image = UIImage(named: ImageIdtf.redCheck)
			confirmpasswordCheck.image = UIImage(named: ImageIdtf.redCheck)
		}
	}

	@IBAction func registerClicked(_ sender: Any) {
		guard let email = emailTxt.text, email.isNotEmpty,
			let username = usernameTxt.text, username.isNotEmpty,
			let password = passwordTxt.text, password.isNotEmpty else {
				simpleAlert(title: "Error.", msg: "Please fill out all fields.")
				stopIndicator()
				return
		}

		startIndicator()

		guard let confirmPass = confirmPassTxt.text, confirmPass == password else {
			simpleAlert(title: "Error.", msg: "Passwords do not match.")
			stopIndicator()
			return
		}

		let keychain = Keychain(service: "swagger")

		AuthApi.sharedManager.createUser(email: email, password: password, username: username) { [weak self] (response, result)  in

			DispatchQueue.main.async {

				guard let self = self else {
					print("No instance more!")
					return
				}

				if result {
					guard let auth = response else {
						print("Error in getting response!")
						self.stopIndicator()
						return
					}
					self.auth = auth
					keychain["token"] = auth.token

					let targetStoryboardName = "main"
					let targetStoryboard = UIStoryboard(name: targetStoryboardName, bundle: nil)
					if let targetVC = targetStoryboard.instantiateInitialViewController() {
						targetVC.modalPresentationStyle = .fullScreen
						self.present(targetVC, animated: true, completion: nil)
					}
				} else {
					self.simpleAlert(title: "Error", msg: "Something went wrong. Please try again.")
				}
				self.stopIndicator()
			}
		}
	}

	func startIndicator() {
		self.activIndicator.isHidden = false
		self.activIndicator.startAnimating()
	}

	func stopIndicator() {
		self.activIndicator.stopAnimating()
		self.activIndicator.isHidden = true
	}
}
