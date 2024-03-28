//
//  ViewController.swift
//  Login SignUp Firebase
//
//  Created by Mag isb-10 on 16/03/2024.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class ViewController: UIViewController {
  @IBOutlet weak var emailTF: UITextField!
  @IBOutlet weak var passwordTF: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setBorder(textfield: emailTF)
    setBorder(textfield: passwordTF)
    
    
  }
  func setBorder(textfield: UITextField) {
    textfield.layer.borderColor = UIColor.black.cgColor
    textfield.layer.borderWidth = 1.0
  }
  
  @IBAction func loginBtn(_ sender: UIButton) {
    guard let email = emailTF.text else {return}
    guard let password = passwordTF.text else {return}
    
    Auth.auth().signIn(withEmail: email, password: password) { firebaseResults, error in
      if let e = error {
        print("error")
      }
      else {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC {
          self.navigationController?.pushViewController(vc, animated: true)
        }
      }
    }
  }
  
  @IBAction func signUpBtn(_ sender: UIButton) {
    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as? SignUpVC {
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
  
  func signInWithGoogle(idToken: String, accessToken: String) {
    let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
    Auth.auth().signIn(with: credential) { result, error in
      guard let _ = result, error == nil else {return}
      if let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC {
        self.navigationController?.pushViewController(vc, animated: true)
      }
      
    }
  }
  

  
  
  
  @IBAction func google(_ sender: Any) {
    
    GIDSignIn.sharedInstance.signIn(withPresenting: self) { user, error in
      if let error = error {
        print("Google sign in error: \(error.localizedDescription)")
        return
      }
      
      guard let user = user else {
        print("Google sign in error: User is nil")
        return
      }
      
      var imageProfile = UIImage(named: "placeholderUser_image")
      
      if ((user.user.profile?.hasImage) != nil), let picUrl = user.user.profile?.imageURL(withDimension: 100) {
        
        print(picUrl)
        
        URLSession.shared.dataTask(with: picUrl) { data, response, error in
          if let error = error {
            print("Error downloading image: \(error.localizedDescription)")
            return
          }
          
          guard let data = data, let image = UIImage(data: data) else {
            print("Error creating image from data")
            return
          }
          
          // Image downloaded successfully
          print("Image downloaded successfully")
          imageProfile = image
          
          DispatchQueue.main.async {
            // Perform any operations with the downloaded image
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC {
              self.navigationController?.pushViewController(vc, animated: true)
            }
          }
          
        }.resume()
      } else {
        print("User profile image not available")
      }
    }
    print("Google sign in button tapped")
  }
  
  
}

