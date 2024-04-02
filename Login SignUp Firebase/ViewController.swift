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
import AuthenticationServices

class ViewController: UIViewController {
  @IBOutlet weak var emailTF: UITextField!
  @IBOutlet weak var passwordTF: UITextField!
  
  @IBOutlet weak var appleBtn: ASAuthorizationAppleIDButton!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setBorder(textfield: emailTF)
    setBorder(textfield: passwordTF)
    
    signInWithApple()
  }
  func setBorder(textfield: UITextField) {
    textfield.layer.borderColor = UIColor.black.cgColor
    textfield.layer.borderWidth = 1.0
  }
  
  func signInWithApple() {
    appleBtn.addTarget(self, action: #selector(handleSigninWithApple), for: .touchUpInside)
  }
  
  @objc func handleSigninWithApple() {
    performSignIn()
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
  
  
  //MARK: - google sign in
  
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

extension ViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
  
  private func performSignIn() {
    let request = createAppleIDRequest()
    let controller = ASAuthorizationController(authorizationRequests: [request])
    controller.delegate = self
    controller.presentationContextProvider = self
    controller.performRequests()
  }
  
  private func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName, .email]
    request.nonce = randomNonceString()
    request.state = randomNonceString()
    return request
  }
  
  private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
      let randoms: [UInt8] = (0 ..< 16).map { _ in
        var random: UInt8 = 0
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
        if errorCode != errSecSuccess {
          fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        return random
      }
      
      randoms.forEach { random in
        if remainingLength == 0 {
          return
        }
        
        if random < charset.count {
          result.append(charset[Int(random)])
          remainingLength -= 1
        }
      }
    }
    
    return result
  }
  
  // MARK: - ASAuthorizationControllerDelegate
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      let userIdentifier = appleIDCredential.user
      let fullName = appleIDCredential.fullName
      let email = appleIDCredential.email
      // Use the user information for your app's login system
      print("User ID: \(userIdentifier)")
      print("Full Name: \(fullName?.givenName ?? "") \(fullName?.familyName ?? "")")
      print("Email: \(email ?? "")")
      
      
      DispatchQueue.main.async {
        // Perform any operations with the downloaded image
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC {
          self.navigationController?.pushViewController(vc, animated: true)
        }
      }
      
    }
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error
    print("Sign in with Apple failed: \(error)")
  }
  
  // MARK: - ASAuthorizationControllerPresentationContextProviding
  
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return self.view.window!
  }
}
