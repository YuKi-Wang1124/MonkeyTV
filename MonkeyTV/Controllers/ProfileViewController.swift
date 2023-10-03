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
import LineSDK
import AuthenticationServices

class ProfileViewController: UIViewController {

    private lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.register(ProfileTitleTableViewCell.self,
                           forCellReuseIdentifier:
                            ProfileTitleTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - UI
   private lazy var personalImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 60
        imageView.clipsToBounds = true
        imageView.image = UIImage.systemAsset(.personalPicture)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.setColor(lightColor: .darkGray, darkColor: .white)
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.text = "歡迎登入 MonkeyTV"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var appleSignInButton = {
        let button = ASAuthorizationAppleIDButton()
        button.layer.cornerRadius = 6
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var googleSignInButton = {
        let button = GIDSignInButton()
        button.style = .wide
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var lineSignInButton = {
        let button = LoginButton()
        button.buttonSize = .normal
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)
        setupTableView()
        setupButtonLayout()
        buttonAddTarget()
        
        lineSignInButton.delegate = self
        lineSignInButton.permissions = [.profile]
        lineSignInButton.presentingViewController = self
        
        if let userName = UserDefaults.standard.string(forKey: "userName"),
           let image = UserDefaults.standard.string(forKey: "userImage"),
           let id = UserDefaults.standard.string(forKey: "userId") {
            print("userName =====\(userName)")
            print("iamge =====\(image)")
            print("id =====\(id)")
            print(checkIfLoginIsRequired())
        }
        
    }
    
    @objc func signOut(sender: Any) {
        GIDSignIn.sharedInstance.signOut()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        view.addSubview(tableView)
        view.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)
        tableView.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func buttonAddTarget() {
        googleSignInButton.addTarget(self, action: #selector(googleSignIn), for: .touchUpInside)
        appleSignInButton.addTarget(self, action: #selector(appleSignIn), for: .touchUpInside)
        lineSignInButton.addTarget(self, action: #selector(lineSignIn), for: .touchUpInside)
    }
    
    @objc func lineSignIn() {        
        LoginManager.shared.login(permissions: [.profile], in: self) { result in
            switch result {
            case .success(let loginResult):
                if let profile = loginResult.userProfile {
                    print("User ID: \(profile.userID)")
                    print("User Display Name: \(profile.displayName)")
                    print("User Icon: \(String(describing: profile.pictureURL))")
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @objc func appleSignIn() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @objc func googleSignIn() {
        print("zzzz")
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signResult, error in
            if let error = error { return }
            guard let user = signResult?.user,
                  let idToken = user.idToken else { return }
            let accessToken = user.accessToken
            let credential = GoogleAuthProvider.credential( withIDToken: idToken.tokenString,
                                                            accessToken: accessToken.tokenString)
            // Use the credential to authenticate with Firebase
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error { print("Auth error: \(error)") }
                if let authResult = authResult,
                   let name = authResult.user.displayName,
                   let image = authResult.user.photoURL?.absoluteString,
                   let email = authResult.user.email {
                    
                    let id = FirestoreManager.user.document().documentID
                    let data: [String: Any] = ["id": id, "email": email, "userName": name,
                                               "userImage": image, "userStatus": 0,
                                               "token": ["tokenType": 0,
                                                         "token": accessToken.tokenString] as [String: Any]]
                    
                    UserDefaults.standard.set(name, forKey: "userName")
                    UserDefaults.standard.set(image, forKey: "userImage")
                    UserDefaults.standard.set(id, forKey: "userId")
                    let lastLoginDate = Date()
                    UserDefaults.standard.set(lastLoginDate, forKey: "lastLoginDate")

                    FirestoreManager.user.document(id).setData(data) { error in
                        if error != nil { print("Error adding document: \(String(describing: error))") } else { }
                    }
                }
            }}
    }
    
    private func setupButtonLayout() {
        
        view.addSubview(personalImageView)
        view.addSubview(nameLabel)
        view.addSubview(googleSignInButton)
        view.addSubview(appleSignInButton)
        view.addSubview(lineSignInButton)

        NSLayoutConstraint.activate([
            personalImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            personalImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3),
            personalImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3),
            personalImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: personalImageView.bottomAnchor, constant: 32),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 50),

            googleSignInButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 32),
            googleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            googleSignInButton.widthAnchor.constraint(equalToConstant: 250),
            googleSignInButton.heightAnchor.constraint(equalToConstant: 70),

            appleSignInButton.topAnchor.constraint(equalTo: googleSignInButton.bottomAnchor, constant: 24),
            appleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appleSignInButton.widthAnchor.constraint(equalToConstant: 240),
            appleSignInButton.heightAnchor.constraint(equalToConstant: 45),
            
            lineSignInButton.topAnchor.constraint(equalTo: appleSignInButton.bottomAnchor, constant: 24),
            lineSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lineSignInButton.widthAnchor.constraint(equalToConstant: 240)
        ])
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
        tableView.dequeueReusableCell(
            withIdentifier: ProfileTitleTableViewCell.identifier,
            for: indexPath) as? ProfileTitleTableViewCell
        guard let cell = cell else { return UITableViewCell() }

        return cell
    }
}

extension ProfileViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            if let name = appleIDCredential.fullName,
               let email = appleIDCredential.email {

                let userName = "\(name.givenName ?? "") \(name.familyName ?? "")"
                
                print(userName)

                let id = FirestoreManager.user.document().documentID
                let data: [String: Any] = ["id": id, "email": email, "userName": userName,
                                           "userImage": "", "userStatus": 0,
                                           "token": ["tokenType": 1,
                                                     "token": userIdentifier] as [String: Any]]
                
                UserDefaults.standard.set(userName, forKey: "userName")

                UserDefaults.standard.set("", forKey: "userImage")
                UserDefaults.standard.set(id, forKey: "userId")
                let lastLoginDate = Date()
                UserDefaults.standard.set(lastLoginDate, forKey: "lastLoginDate")
                
                FirestoreManager.user.document(id).setData(data) { error in
                    if error != nil { print("Error adding document: \(String(describing: error))") } else { }
                }
            }
        case let passwordCredential as ASPasswordCredential:
        
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
        default:
            break
        }
    }

    func checkIfLoginIsRequired() -> Bool {
        if let lastLoginDate = UserDefaults.standard.object(forKey: "lastLoginDate") as? Date {
            let currentDate = Date()
            let calendar = Calendar.current
            if let days = calendar.dateComponents([.day], from: lastLoginDate, to: currentDate).day, days >= 30 {
                return true
            }
        }
        return false
    }

}

extension ProfileViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension ProfileViewController: LoginButtonDelegate {
    
    func loginButton(_ button: LoginButton, didSucceedLogin loginResult: LoginResult) {
//        hideIndicator()
        print("Login Succeeded.")
    }

    func loginButton(_ button: LoginButton, didFailLogin error: LineSDKError) {
//        hideIndicator()
        print("Error: \(error)")
    }

    func loginButtonDidStartLogin(_ button: LoginButton) {
//        showIndicator()
        print("Login Started.")
    }
}
