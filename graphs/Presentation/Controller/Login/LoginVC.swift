//
//  LoginVC.swift
//  graphs
//
//  Created by Danila Ferents on 12.03.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import UIKit
import KeychainAccess

class LoginVC: UIViewController {
	
	//Outlets
	@IBOutlet weak var usernameTxt: UITextField!
	@IBOutlet weak var passwordTxt: UITextField!

	@IBOutlet weak var loginBtn: RoundedButton!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	//Variables
	var login: AuthResponse!

	override func viewDidLoad() {
		super.viewDidLoad()
		//add recogniser to hide keyboard
		let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
		view.addGestureRecognizer(tap)
	}
	@IBAction func forgotPasswordClicked(_ sender: Any) {
		let vc = ForgotPasswordVC()
		vc.modalTransitionStyle = .flipHorizontal
		vc.modalPresentationStyle = .overCurrentContext
		present(vc, animated: true, completion: nil)
	}
	@IBAction func loginBtnClicked(_ sender: Any) {
		guard let username = usernameTxt.text,
			username.isNotEmpty,
			let password = passwordTxt.text, password.isNotEmpty else {
				simpleAlert(title: "Error.", msg: "Please fill out all fields.")
				return
		}

		startIndicator()

		let keychain = Keychain(service: "swagger")

		AuthApi.sharedManager.authLogin(username: username, password: password) { [weak self] (response, result)  in
			
			DispatchQueue.main.async {

				guard let self = self else {
					print("No instance more! ")
					return }

				guard let login = response else {
					self.simpleAlert(title: "Error", msg: "Invalid password or Url!")
					self.stopIndicator()
					return
				}

				if result {
					self.login = login
					keychain["token"] = login.token
					print(login.token)
					let targetStoryboardName = "main"
					let targetStoryboard = UIStoryboard(name: targetStoryboardName, bundle: nil)
					if let targetVC = targetStoryboard.instantiateInitialViewController() {
						targetVC.modalPresentationStyle = .fullScreen
						self.present(targetVC, animated: true, completion: nil)
					}
				} else {
					self.simpleAlert(title: "Error", msg: "Something went wrong!")
				}
				self.stopIndicator()
			}
		}
		
	}

	func startIndicator() {
		self.activityIndicator.isHidden = false
		self.activityIndicator.startAnimating()
	}

	func stopIndicator() {
		self.activityIndicator.stopAnimating()
		self.activityIndicator.isHidden = true
	}

	@IBAction func guestClicked(_ sender: Any) {

		startIndicator()

		let keychain = Keychain(service: "swagger")

		AuthApi.sharedManager.authLogin(username: "username", password: "password") { [weak self] (response, result)  in

			DispatchQueue.main.async {

				guard let self = self else {
					print("No instance more! ")
					return }

				guard let login = response else {
					self.simpleAlert(title: "Error", msg: "Invalid password or Url!")
					self.stopIndicator()
					return
				}

				if result {
					self.login = login
					keychain["token"] = login.token
					print(login.token)
					
					let targetStoryboardName = "main"
					let targetStoryboard = UIStoryboard(name: targetStoryboardName, bundle: nil)
					if let targetVC = targetStoryboard.instantiateInitialViewController() {
						targetVC.modalPresentationStyle = .fullScreen
						self.present(targetVC, animated: true, completion: nil)
					}
				} else {
					self.simpleAlert(title: "Error", msg: "Something went wrong!")
				}
				self.stopIndicator()
			}
		}
	}

}
