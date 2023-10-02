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

    private lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.register(ProfileTitleTableViewCell.self,
                           forCellReuseIdentifier:
                            ProfileTitleTableViewCell.identifier)
        tableView.register(ChatroomButtonTableViewCell.self,
                           forCellReuseIdentifier:
                            ChatroomButtonTableViewCell.identifier)
        tableView.register(DanMuTextFieldTableViewCell.self,
                           forCellReuseIdentifier:
                            DanMuTextFieldTableViewCell.identifier)
        tableView.register(ShowTableViewCell.self,
                           forCellReuseIdentifier:
                            ShowTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.setColor(lightColor: .systemGray6, darkColor: .black)
        setupTableView()
        
    }
    @IBAction func signOut(sender: Any) {
        GIDSignIn.sharedInstance.signOut()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
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
        cell.personalImageView.image = UIImage.systemAsset(.personalPicture)

        cell.signInButton.addTarget(self, action: #selector(handleSignInButton), for: .touchUpInside)
        return cell
    }
    
    @objc func handleSignInButton() {
        print("zzzz")
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
            print(accessToken.tokenString)
            Auth.auth().signIn(with: credential) { authResult, error in
                print(authResult?.user.displayName)
            }
        }
    }
}
