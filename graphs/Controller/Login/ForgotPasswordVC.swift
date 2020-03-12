//
//  ForgotPasswordVC.swift
//  wagon
//
//  Created by Danila Ferents on 24/04/2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
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
//        Auth.auth().sendPasswordReset(withEmail: email) { error in
//            guard let error = error else {return}
//            Auth.auth().handleFireError(error: error, vc: self)
//            debugPrint(error)
//            return
//        }
//        self.dismiss(animated: true, completion: nil)
    }
    
}
