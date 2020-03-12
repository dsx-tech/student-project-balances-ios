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
	
	@IBOutlet weak var loginBtn: RoundedButton!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!


    override func viewDidLoad() {
        super.viewDidLoad()

    }
	@IBAction func forgotPasswordClicked(_ sender: Any) {
		let vc = ForgotPasswordVC()
        vc.modalTransitionStyle = .flipHorizontal
        vc.modalPresentationStyle = .overCurrentContext
		present(vc, animated: true, completion: nil)
	}
	@IBAction func loginBtnClicked(_ sender: Any) {
	}
	
	@IBAction func guestClicked(_ sender: Any) {
	}

}
