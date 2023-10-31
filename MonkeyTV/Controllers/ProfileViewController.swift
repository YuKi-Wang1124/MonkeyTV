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
import AuthenticationServices

class ProfileViewController: UIViewController, LogInDelegate {
    
    private var username: String = ""
    var bindAccountBoolArray: [Bool] = [false, false]
    private var cleanSearchHistoryDelegate: CleanSearchHistoryDelegate?
    var myUserInfo: UserInfo?
    
    private lazy var tableView: CustomTableView = {
        return  CustomTableView(
            rowHeight: UITableView.automaticDimension,
            separatorStyle: .singleLine,
            allowsSelection: false,
            registerCells: [ProfileTitleTableViewCell.self,
                            SignInWithTableViewCell.self,
                            DeleteTableViewCell.self])
    }()
    
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
        let label = CustomLabel(
            fontSize: 20,
            textColor: UIColor.setColor(lightColor: .darkGray, darkColor: .white),
            textAlignment: .center)
        label.text = Constant.welcomeSignIn
        return label
    }()
    
    private lazy var copyRightButton = {
        let button = CustomButton(
            image: UIImage.systemAsset(.cCircle, configuration: UIImage.smallSymbolConfig),
            color: .white, cornerRadius: 5, backgroundColor: UIColor.mainColor!)
        button.setTitle(Constant.copyrightNotice, for: .normal)
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
    
    private lazy var googleSignInButton = {
        let button = GIDSignInButton()
        button.style = .wide
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var rightButton = UIBarButtonItem()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtonLayout()
        setupTableView()
        buttonAddTarget()
        self.cleanSearchHistoryDelegate = SearchViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            if KeychainItem.currentEmail.isEmpty != true {
                await self.showLogInTableView()
            } else {
                logOut()
            }
        }
    }
    
    @objc func logOut() {
        self.saveUserInKeychain("")
        self.myUserInfo = nil
        tableView.reloadData()
        tableView.isHidden = true
        rightButton.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
    }
    
    private func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        view.addSubview(tableView)
        view.backgroundColor = .baseBackgroundColor
        tableView.backgroundColor = .baseBackgroundColor
        
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
        rightButton = UIBarButtonItem(title: "登出", style: .plain, target: self, action: #selector(logOut))
        self.navigationItem.rightBarButtonItem = rightButton
        copyRightButton.addTarget(self, action: #selector(presentCopyRightViewController), for: .touchUpInside)
    }
    
    @objc func presentCopyRightViewController() {
        let copyRightViewController = CopyRightViewController()
        self.navigationController?.pushViewController(copyRightViewController, animated: true)
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
                            let userData = UserData(id: id, email: email, userName: name,
                                                    userImage: image, userStatus: 0,
                                                    appleId: "", googleToken: accessToken.tokenString,
                                                    googleIsBind: true, appleIsBind: false)
                            let data = userData.asDictionary()
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
            let cell: ProfileTitleTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            guard let myUserInfo = myUserInfo else { return UITableViewCell() }
            cell.nameLabel.text = myUserInfo.userName
            cell.personalImageView.loadImage(myUserInfo.userImage, placeHolder: UIImage.systemAsset(.personalPicture))
            cell.emailLabel.text = myUserInfo.email
            return cell
        } else if indexPath.row == 3 {
            let cell: DeleteTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.deleteAccountButton.addTarget(self, action: #selector(deleteAccount), for: .touchUpInside)
            return cell
        } else {
            let cell: SignInWithTableViewCell = tableView.dequeueReusableCell(for: indexPath)
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
            self.cleanSearchHistoryDelegate?.cleanSearchHistory()
        }
        let cancelAction = UIAlertAction(title: Constant.cancel, style: .cancel)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func bindAccount(sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else {
            return
        }
        
        if buttonTitle == "取消綁定" {
            let title: String
            let message: String
            let bindKey: String
            
            if sender.tag == 0 {
                title = "刪除 Google 綁定"
                message = Constant.cancelBindingMessage
                bindKey = "googleIsBind"
            } else {
                title = "刪除 Apple 綁定"
                message = Constant.cancelBindingMessage
                bindKey = "appleIsBind"
            }
            
            let alertController = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .actionSheet)
            
            let okAction = UIAlertAction(
                title: "\(title)",
                style: .default) { _ in
                    
                let data: [String: Any] = [bindKey: false]
                    
                DispatchQueue.main.async {
                    FirestoreManager.updateUserInfo(email: KeychainItem.currentEmail, data: data)
                }
                self.bindAccountBoolArray[sender.tag] = !self.bindAccountBoolArray[sender.tag]
                self.tableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: Constant.cancel, style: .cancel)
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
            
            if sender.tag == 0 {
                GIDSignIn.sharedInstance.signOut()
            }
        } else if buttonTitle == Constant.bind {
            if sender.tag == 0 {
                googleSignIn()
            } else {
                appleSignIn()
            }
        }
    }
}

// MARK: - Sign in with apple

extension ProfileViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            handleAppleIDCredential(appleIDCredential)
        case _ as ASPasswordCredential:
            tableView.isHidden = false
        default:
            break
        }
    }

    func handleAppleIDCredential(
        _ appleIDCredential: ASAuthorizationAppleIDCredential
    ) {
        let userIdentifier = appleIDCredential.user

        guard let name = appleIDCredential.fullName,
                let email = appleIDCredential.email else {
            if !KeychainItem.currentEmail.isEmpty {
                updateUserInfoAndShowTableView(userIdentifier)
            } else {
                findUserByAppleIDAndShowTableView(userIdentifier)
            }
            return
        }

        let id = FirestoreManager.user.document().documentID
        let userName = "\(name.givenName ?? "") \(name.familyName ?? "")"
        self.saveUserInKeychain(email)

        Task {
            if await FirestoreManager.userIsExist(email: email) == false {
                let userData = UserData(id: id, email: email, userName: userName,
                                        userImage: "", userStatus: 0, appleId: userIdentifier, googleToken: "",
                                        googleIsBind: false, appleIsBind: true)
                let data = userData.asDictionary()
                DispatchQueue.main.async {
                    FirestoreManager.signInUserInfo(email: email, data: data)
                }
            } else {
                let data: [String: Any] = ["appleId": userIdentifier, "appleIsBind": true]
                FirestoreManager.updateUserInfo(email: email, data: data)
            }
            await self.showLogInTableView()
        }
    }

    func updateUserInfoAndShowTableView(
        _ userIdentifier: String
    ) {
        Task {
            let data: [String: Any] = ["appleId": userIdentifier, "appleIsBind": true]
            FirestoreManager.updateUserInfo(email: KeychainItem.currentEmail, data: data)
            await self.showLogInTableView()
        }
    }

    func findUserByAppleIDAndShowTableView(
        _ userIdentifier: String
    ) {
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
            } catch {
                print("\(error)")
            }
            await self.showLogInTableView()
        }
    }
    
    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "email", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }
}

extension ProfileViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {
        return self.view.window!
    }
}
