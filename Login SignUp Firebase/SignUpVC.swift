//
//  SignUpVC.swift
//  Login SignUp Firebase
//
//  Created by Mag isb-10 on 16/03/2024.
//

import UIKit
import FirebaseAuth

class SignUpVC: UIViewController {
  
  @IBOutlet weak var passwordTF: UITextField!
  @IBOutlet weak var emailTF: UITextField!
  @IBOutlet weak var usernameTF: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setBorder(textfield: usernameTF)
    setBorder(textfield: emailTF)
    setBorder(textfield: passwordTF)
  }
  
  func setBorder(textfield: UITextField) {
    textfield.layer.borderColor = UIColor.black.cgColor
    textfield.layer.borderWidth = 1.0
  }
  
  @IBAction func signUpBtn(_ sender: UIButton) {
    guard let email = emailTF.text else {return}
    guard let password = passwordTF.text else {return}
    
    Auth.auth().createUser(withEmail: email, password: password) { firebaseResults, error in
      if let e = error {
        print("error")
      }
      else {
        self.navigationController?.popViewController(animated: true)
      }
    }
  }
  
  
  @IBAction func gotoLoginVC(_ sender: UIButton) {
    self.navigationController?.popViewController(animated: true)
  }
  
  
}
