//
//  ForgotPasswordVC.swift
//  graphs
//
//  Created by Danila Ferents on 12.03.20.
//  Copyright © 2020 Danila Ferents. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {

    //outlets
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var cancelBtn: RoundedButton!
    @IBOutlet weak var forgetBTN: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func CancelClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func resetClicked(_ sender: Any) {
		guard let email = emailTxt.text, email.isNotEmpty else {
            simpleAlert(title: "Error", msg: "Fill in your email.")
            return
        }
    }
    
}
