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
       guard let clientID = FirebaseApp.app()?.options.clientID else { return }
       let config = GIDConfiguration(clientID: clientID)
       GIDSignIn.sharedInstance.configuration = config
       GIDSignIn.sharedInstance.signIn(withPresenting: self) { signResult, error in
           if let error = error {
              return
           }
            guard let user = signResult?.user,
                  let idToken = user.idToken else { return }
            let accessToken = user.accessToken
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken.tokenString,
                accessToken: accessToken.tokenString)
           // Use the credential to authenticate with Firebase
//           print("========================")
//           print(accessToken.tokenString)
           Auth.auth().signIn(with: credential) { authResult, error in
//               print(authResult)
           }
       }
   }
    @IBAction func signOut(sender: Any) {
        GIDSignIn.sharedInstance.signOut()
    }
}
