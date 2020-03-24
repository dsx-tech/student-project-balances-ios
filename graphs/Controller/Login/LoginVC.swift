//
//  LoginVC.swift
//  graphs
//
//  Created by Danila Ferents on 12.03.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
	
	//Outlets
	@IBOutlet weak var emailTxt: UITextField!
	@IBOutlet weak var passwordTxt: UITextField!
	@IBOutlet weak var usernameTxt: UITextField!

	@IBOutlet weak var loginBtn: RoundedButton!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	//Variables
	var login: LoginResponse!

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
		guard let email = emailTxt.text,
			email.isNotEmpty,
			let password = passwordTxt.text, password.isNotEmpty,
			let username = usernameTxt.text, username.isNotEmpty else {
			simpleAlert(title: "Error.", msg: "Please fill out all fields.")
			return
		}
		activityIndicator.startAnimating()
		let authApi = AuthApi()
		authApi.authLogin(url: Urls.loginUrl, email: email, password: password, username: username) { [weak self] (response) in
			guard let login = response, self = self else {
				print("Error in getting response!")
				return }
			
		}
	}
	
	@IBAction func guestClicked(_ sender: Any) {
	}

}
