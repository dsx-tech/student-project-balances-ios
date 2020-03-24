////
////  RegisterVC.swift
////  graphs
////
////  Created by Danila Ferents on 12.03.20.
////  Copyright © 2020 Danila Ferents. All rights reserved.
////
//
//
//import UIKit
//
//class RegisterVC: UIViewController{
//    //Outlets
//    @IBOutlet weak var usernameTxt: UITextField!
//    @IBOutlet weak var emailTxt: UITextField!
//    @IBOutlet weak var passwordTxt: UITextField!
//    @IBOutlet weak var confirmPassTxt: UITextField!
//    @IBOutlet weak var registerClicked: UIButton!
//    @IBOutlet weak var activIndicator: UIActivityIndicatorView!
//    
//    @IBOutlet weak var passwordCheck: UIImageView!
//    @IBOutlet weak var confirmpasswordCheck: UIImageView!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        //monitor password changing
//        passwordTxt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
//        confirmPassTxt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
//    }
//    //function to minotr password changing
//    @objc func textFieldDidChange(_ textField: UITextField) {
//        guard let passTxt = passwordTxt.text else { return }
//        
//        if textField == confirmPassTxt {
//            passwordCheck.isHidden = false
//            confirmpasswordCheck.isHidden = false
//        } else {
//            if passTxt.isEmpty {
//                passwordCheck.isHidden = true
//                confirmpasswordCheck.isHidden = true
//                confirmPassTxt.text = ""
//            }
//        }
//       // Method is called to make checkmarks green when password matches
//        if passwordTxt.text == confirmPassTxt.text {
//            passwordCheck.image = UIImage(named: ImageIdtf.greenCheck)
//            confirmpasswordCheck.image = UIImage(named: ImageIdtf.greenCheck)
//        } else {
//            passwordCheck.image = UIImage(named: ImageIdtf.redCheck)
//            confirmpasswordCheck.image = UIImage(named: ImageIdtf.redCheck)
//        }
//    }
//    
//    @IBAction func registerClicked(_ sender: Any) {
//        guard let email = emailTxt.text, email.isNotEmpty,
//            let username = usernameTxt.text, username.isNotEmpty,
//            let password = passwordTxt.text, password.isNotEmpty else {
//                simpleAlert(title: "Error.", msg: "Please fill out all fields.")
//                return
//        }
//       
//        activIndicator.startAnimating()
//        guard let authUser = Auth.auth().currentUser else {
//            return
//        }
//        guard let confirmPass = confirmPassTxt.text, confirmPass == password else {
//            simpleAlert(title: "Error.", msg: "Passwords do not match.")
//            self.activIndicator.stopAnimating()
//            return
//        }
//        
//        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
//            if let error = error {
//                debugPrint(error)
//                Auth.auth().handleFireError(error: error, vc: self)
//                self.activIndicator.stopAnimating()
//                return
//            }
//            
//            guard let fireUser = result?.user else { return}
//            let wagUser = User.init(id: fireUser.uid, email: email, username: username, stripeId: "")
//            self.createFireStorUser(user: wagUser)
//        }
//            
////        //variable to use in authentification
////        let credential = EmailAuthProvider.credential(withEmail: email, link: password)
////        //universal process to create new user
////        authUser.linkAndRetrieveData(with: credential) { (result, error) in
////            if let error = error {
////                debugPrint(error)
////                Auth.auth().handleFireError(error: error, vc: self)
////                self.activIndicator.stopAnimating()
////                return
////            }
////            self.activIndicator.stopAnimating()
////            //to leave view controller and get back
////            self.dismiss(animated: true, completion: nil)
////        }
//        
//        //First method to crate user
////        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
////            if let error = error {
////                debugPrint(error)
////                self.activIndicator.stopAnimating()
////                return
////            }
////            self.activIndicator.stopAnimating()
////            self.dismiss(animated: true, completion: nil)
////        }
//    }
//    
//    func createFireStorUser (user: User) {
//        let docRef = Firestore.firestore().collection("Users").document(user.id)
//        
//        var modeData = User.modelToData(user: user)
//        
//        docRef.setData(modeData) { (error) in
//            if let error = error {
//                debugPrint(error)
//               Auth.auth().handleFireError(error: error, vc: self)
//            } else {
//                self.dismiss(animated: true, completion: nil)
//            }
//            self.activIndicator.stopAnimating()
//        }
//        
//    }
//}
