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
    
    var username: String = ""
    
    private lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.separatorStyle = .singleLine
        tableView.register(ProfileTitleTableViewCell.self,
                           forCellReuseIdentifier:
                            ProfileTitleTableViewCell.identifier)
        tableView.register(SignInWithTableViewCell.self,
                           forCellReuseIdentifier:
                            SignInWithTableViewCell.identifier)
        tableView.register(DeleteTableViewCell.self,
                           forCellReuseIdentifier:
                            DeleteTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsSelection = false
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
        label.text = "歡迎 註冊 / 登入 MonkeyTV"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var copyRightButton = {
        let button = UIButton.createPlayerButton(
            image: UIImage.systemAsset(.cCircle, configuration: UIImage.smallSymbolConfig),
            color: .white, cornerRadius: 5, backgroundColor: UIColor.mainColor!)
        button.setTitle("  MonkeyTV 版權宣告", for: .normal)
        return button
    }()
    
    private lazy var appleSignInButton = {
        let button = ASAuthorizationAppleIDButton()
        button.layer.cornerRadius = 6
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.layer.borderWidth = 1
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
    
    private var myUserInfo: UserInfo?
    
    var rightButton = UIBarButtonItem()
    
    private lazy var bindAccountBoolArray: [Bool] = [false, false]
    
    override func viewWillAppear(_ animated: Bool) {
        Task {
            if KeychainItem.currentEmail.isEmpty != true {
                await self.showLogInTableView()
            } else {
                rightButtonTapped()
            }
        }
    }
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButtonLayout()
        setupTableView()
        buttonAddTarget()
        
        lineSignInButton.delegate = self
        lineSignInButton.permissions = [.profile]
        lineSignInButton.presentingViewController = self
        
        rightButton = UIBarButtonItem(title: "登出", style: .plain, target: self, action: #selector(rightButtonTapped))
        self.navigationItem.rightBarButtonItem = rightButton
        copyRightButton.addTarget(self, action: #selector(presentCopyRightViewController), for: .touchUpInside)
    }
    
    @objc func presentCopyRightViewController() {
        let copyRightViewController = CopyRightViewController()
        self.navigationController?.pushViewController(copyRightViewController, animated: true)
    }
    
    @objc func rightButtonTapped() {
        self.saveUserInKeychain("")
        self.myUserInfo = nil
        tableView.reloadData()
        tableView.isHidden = true
        rightButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
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
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signResult, error in
            if error != nil { return }
            guard let user = signResult?.user,
                  let idToken = user.idToken else { return }
            let accessToken = user.accessToken
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                           accessToken: accessToken.tokenString)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error { print("Auth error: \(error)") }
                if let authResult = authResult,
                   let name = authResult.user.displayName,
                   let image = authResult.user.photoURL?.absoluteString,
                   let email = authResult.user.email {
                    print(email)
                    self.saveUserInKeychain(email)
                    Task {
                        if await FirestoreManager.userIsExist(email: email) == false {
                            let id = FirestoreManager.user.document().documentID
                            let data: [String: Any] = ["id": id, "email": email, "userName": name,
                                                       "userImage": image, "userStatus": 0,
                                                       "appleId": "", "googleToken": accessToken.tokenString,
                                                       "googleIsBind": true, "appleIsBind": false]
                            DispatchQueue.main.async {
                                FirestoreManager.signInUserInfo(email: email, data: data)
                            }
                        } else {
                            let data: [String: Any] = ["userImage": image,
                                                       "googleToken": accessToken.tokenString,
                                                       "googleIsBind": true]
                            DispatchQueue.main.async {
                                FirestoreManager.updateUserInfo(email: email, data: data)
                            }
                        }
                        Task {
                            await self.showLogInTableView()
                        }
                    }
                }
            }
        }
    }
    
    func showLogInTableView() async {
        if KeychainItem.currentEmail.isEmpty {
            return
        }
        if let userInfo = await UserInfoManager.userInfo() {
            myUserInfo = userInfo
            if let myUserInfo = myUserInfo {
                
                bindAccountBoolArray = [myUserInfo.googleIsBind,
                                        myUserInfo.appleIsBind]
                tableView.reloadData()
            }
        }
        self.tableView.isHidden = false
        self.rightButton.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor.mainColor,
             NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22)], for: .normal)
    }
    
    private func setupButtonLayout() {
        
        view.addSubview(personalImageView)
        view.addSubview(nameLabel)
        view.addSubview(googleSignInButton)
        view.addSubview(appleSignInButton)
        view.addSubview(copyRightButton )
        
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
            googleSignInButton.widthAnchor.constraint(equalToConstant: 240),
            googleSignInButton.heightAnchor.constraint(equalToConstant: 70),
            
            appleSignInButton.topAnchor.constraint(equalTo: googleSignInButton.bottomAnchor, constant: 24),
            appleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appleSignInButton.widthAnchor.constraint(equalToConstant: 245),
            appleSignInButton.heightAnchor.constraint(equalToConstant: 45),
            
            copyRightButton.topAnchor.constraint(equalTo: appleSignInButton.bottomAnchor, constant: 24),
            copyRightButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            copyRightButton.widthAnchor.constraint(equalToConstant: 245),
            copyRightButton.heightAnchor.constraint(equalToConstant: 45)
            
            //            lineSignInButton.topAnchor.constraint(equalTo: appleSignInButton.bottomAnchor, constant: 24),
            //            lineSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            //            lineSignInButton.widthAnchor.constraint(equalToConstant: 240)
        ])
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row != 0 {
            return 58.0
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell =
            tableView.dequeueReusableCell(
                withIdentifier: ProfileTitleTableViewCell.identifier,
                for: indexPath) as? ProfileTitleTableViewCell
            guard let cell = cell else { return UITableViewCell() }
            
            guard let myUserInfo = myUserInfo else { return UITableViewCell() }
            cell.nameLabel.text = myUserInfo.userName
            cell.personalImageView.loadImage(myUserInfo.userImage, placeHolder: UIImage.systemAsset(.personalPicture))
            cell.emailLabel.text = myUserInfo.email
            return cell
        } else if indexPath.row == 3 {
            let cell =
            tableView.dequeueReusableCell(
                withIdentifier: DeleteTableViewCell.identifier,
                for: indexPath) as? DeleteTableViewCell
            guard let cell = cell else { return UITableViewCell() }
            cell.deleteAccountButton.addTarget(self, action: #selector(deleteAccount), for: .touchUpInside)
            return cell
        } else {
            let cell =
            tableView.dequeueReusableCell(
                withIdentifier: SignInWithTableViewCell.identifier,
                for: indexPath) as? SignInWithTableViewCell
            guard let cell = cell else { return UITableViewCell() }
            let index = indexPath.row - 1
            let logInMethodStrings = LogInMethod.allCases.map { $0.rawValue }
            let lowercaseLogInMethodStrings = logInMethodStrings.map { $0.lowercased() }
            cell.iconNameLabel.text = logInMethodStrings[index]
            cell.iconImageView.image = UIImage(named: lowercaseLogInMethodStrings[index])
            
            if self.bindAccountBoolArray[index] == true {
                cell.signInButton.setTitle("取消綁定", for: .normal)
            } else {
                cell.signInButton.setTitle("綁定", for: .normal)
            }
            
            cell.signInButton.tag = index
            cell.signInButton.addTarget(self, action: #selector(bindAccount(sender:)), for: .touchUpInside)
            return cell
        }
    }
    
    @objc func deleteAccount() {
        let deleteEmail = KeychainItem.currentEmail
        let alertController = UIAlertController(
            title: "刪除帳號",
            message: "若刪除帳號，您在 MonkeyTV 留存的資料將遺失，是否繼續刪除帳號？",
            preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "刪除", style: .default) { _ in
            let data: [String: Any] = ["googleIsBind": false, "appleIsBind": false]
            FirestoreManager.updateUserInfo(email: deleteEmail, data: data)
            Task { await FirestoreManager.deleteAllMyFavorite(email: deleteEmail) }
            self.myUserInfo = nil
            self.tableView.isHidden = true
            self.saveUserInKeychain("")
            self.rightButton.setTitleTextAttributes(
                [NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func bindAccount(sender: UIButton) {
        if sender.titleLabel?.text == "取消綁定" {
            if sender.tag == 0 {
                let alertController = UIAlertController(
                    title: "刪除 Google 綁定",
                    message: "若取消綁定，您在 MonkeyTV 留存的資料將可能遺失，是否取消綁定？",
                    preferredStyle: .actionSheet)
                let okAction = UIAlertAction(title: "確定刪除 Google 綁定", style: .default) { _ in
                    let data: [String: Any] = ["googleIsBind": false]
                    DispatchQueue.main.async {
                        FirestoreManager.updateUserInfo(email: KeychainItem.currentEmail, data: data)
                    }
                    self.bindAccountBoolArray[sender.tag] = !self.bindAccountBoolArray[sender.tag]
                    self.tableView.reloadData()
                }
                let cancelAction = UIAlertAction(title: "取消", style: .cancel)
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                present(alertController, animated: true, completion: nil)
                GIDSignIn.sharedInstance.signOut()
            } else {
                print("cancel Apple")
                let alertController = UIAlertController(
                    title: "刪除 Apple 綁定",
                    message: "若取消綁定，您在 MonkeyTV 留存的資料將可能遺失，請確認是否取消綁定？",
                    preferredStyle: .actionSheet)
                
                let okAction = UIAlertAction(
                    title: "確定刪除 Apple 綁定", style: .default) { _ in
                        let data: [String: Any] = ["appleIsBind": false]
                        DispatchQueue.main.async {
                            FirestoreManager.updateUserInfo(email: KeychainItem.currentEmail, data: data)
                        }
                        self.bindAccountBoolArray[sender.tag] = !self.bindAccountBoolArray[sender.tag]
                        self.tableView.reloadData()
                    }
                let cancelAction = UIAlertAction(title: "取消", style: .cancel)
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                present(alertController, animated: true, completion: nil)
            }
        } else if sender.titleLabel?.text == "綁定" {
            if sender.tag == 0 {
                googleSignIn()
            } else {
                print("bind Apple")
                appleSignIn()
            }
        }
    }
}

// MARK: - Sign in with apple

extension ProfileViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization) {
            switch authorization.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                let userIdentifier = appleIDCredential.user
                if let name = appleIDCredential.fullName,
                   let email = appleIDCredential.email {
                    let id = FirestoreManager.user.document().documentID
                    let userName = "\(name.givenName ?? "") \(name.familyName ?? "")"
                    self.saveUserInKeychain(email)
                    Task {
                        if await FirestoreManager.userIsExist(email: email) == false {
                            let data: [String: Any] = ["id": id, "email": email, "userName": userName,
                                                       "userImage": "", "userStatus": 0,
                                                       "appleId": userIdentifier, "googleToken": "",
                                                       "googleIsBind": false, "appleIsBind": true]
                            DispatchQueue.main.async {
                                FirestoreManager.signInUserInfo(email: email, data: data)
                            }
                        } else {
                            let data: [String: Any] = ["appleId": userIdentifier, "appleIsBind": true]
                            FirestoreManager.updateUserInfo(email: email, data: data)
                        }
                        await self.showLogInTableView()
                    }
                } else {
                    if KeychainItem.currentEmail.isEmpty != true {
                        let data: [String: Any] = ["appleId": userIdentifier, "appleIsBind": true]
                        FirestoreManager.updateUserInfo(email: KeychainItem.currentEmail, data: data)
                        Task { await self.showLogInTableView() }
                    } else {
                        Task {
                            let querySnapshot = try await FirestoreManager.user.whereField(
                                "appleId", isEqualTo: userIdentifier).getDocuments()
                            do {
                                for document in querySnapshot.documents {
                                    let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                                    let decodedObject = try JSONDecoder().decode(UserInfo.self, from: jsonData)
                                    self.saveUserInKeychain(decodedObject.email)
                                    let data: [String: Any] = ["appleId": userIdentifier, "appleIsBind": true]
                                    FirestoreManager.updateUserInfo(email: decodedObject.email, data: data)
                                }
                            } catch { print("\(error)") }
                            await self.showLogInTableView()
                        }
                    }
                }
            case _ as ASPasswordCredential:
                tableView.isHidden = false
            default:
                break
            }
        }
    
    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "email", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
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
        print("Login Succeeded.")
    }
    
    func loginButton(_ button: LoginButton, didFailLogin error: LineSDKError) {
        print("Error: \(error)")
    }
    
    func loginButtonDidStartLogin(_ button: LoginButton) {
        print("Login Started.")
    }
}

enum LogInMethod: String, CaseIterable {
    case google = "Google"
    case apple = "Apple"
}
