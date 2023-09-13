//
//  ProfileViewController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class ProfileViewController: UIViewController {
   lazy var signInBtn = GIDSignInButton()
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        signInBtn.frame = CGRect(x: 100, y: 300, width: 200, height: 50)
        signInBtn.addTarget(self, action: #selector(handleSignInButton), for: .touchUpInside)
        view.addSubview(signInBtn)
    }
   @objc func handleSignInButton() {
       GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
          guard error == nil else { return }

          // If sign in succeeded, display the app's main content View.
        }
     }
    @IBAction func signOut(sender: Any) {
      GIDSignIn.sharedInstance.signOut()
    }

}
