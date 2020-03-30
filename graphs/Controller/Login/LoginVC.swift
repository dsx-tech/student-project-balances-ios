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
		activityIndicator.isHidden = true
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
		activityIndicator.startAnimating()

		let authApi = AuthApi()
		let keychain = Keychain(service: "swagger")

		authApi.authLogin(url: Urls.loginUrl, username: username, password: password) { [weak self] (response) in
			guard let login = response, let self = self else {
				print("Error in getting response!")
				return }
			self.login = login
			keychain["token"] = login.token

			let targetStoryboardName = "main"
			let targetStoryboard = UIStoryboard(name: targetStoryboardName, bundle: nil)
			if let targetVC = targetStoryboard.instantiateInitialViewController() as? UITabBarController {
				if let selectedVC = targetVC.selectedViewController as? LineChartVCCharts {
					selectedVC.login = self.login
				}
				self.present(targetVC, animated: true, completion: nil)
			}
		}
		
	}
	
	@IBAction func guestClicked(_ sender: Any) {
		//make demo
	}

}
