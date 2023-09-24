//
//  ViewController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit
import youtube_ios_player_helper

class PlayerViewController: UIViewController {
    
    private var landscapeConstraints: [NSLayoutConstraint] = []
    private var portraitConstraints: [NSLayoutConstraint] = []
    // MARK: - support
    private let symbolConfig = UIImage.SymbolConfiguration(pointSize: 30)
    private let smallSymbolConfig = UIImage.SymbolConfiguration(pointSize: 20)
    
    // MARK: - Views
    private var ytVideoPlayerView = {
        let view = YTPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var buttonsView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var tableView = {
        var tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.backgroundColor = .systemMint
        tableView.register(ChatroomButtonTableViewCell.self,
                           forCellReuseIdentifier:
                            ChatroomButtonTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    // MARK: - Buttons
    private lazy var changeOrientationButton = {
        return UIButton.createPlayerButton(
            image: UIImage.systemAsset(.enlarge, configuration: smallSymbolConfig),
            color: .white, cornerRadius: 15)
    }()
    private lazy var showDanMuButton = {
        let button = UIButton.createPlayerButton(
            image: UIImage.systemAsset(.square, configuration: smallSymbolConfig),
            color: .white, cornerRadius: 12)
        button.setTitle("彈幕", for: .normal)
        return button
    }()
    private lazy var showDanMuTextFieldButton = {
        return UIButton.createPlayerButton(
            image: UIImage.systemAsset(.submitDanMu, configuration: smallSymbolConfig),
            color: .white, cornerRadius: 15)
    }()
    private lazy var showChatroomButton = {
        return UIButton.createPlayerButton(
            image: UIImage.systemAsset(.chatroom, configuration: smallSymbolConfig),
            color: .white, cornerRadius: 15)
    }()
    private lazy var pauseButton = {
        return UIButton.createPlayerButton(
            image: UIImage.systemAsset(.pause, configuration: symbolConfig),
            color: .white, cornerRadius: 30)
    }()
    private lazy var videoSlider: UISlider = {
        let slider = UISlider()
        slider.thumbTintColor = UIColor.mainColor
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let playerVars: [AnyHashable: Any] = [
            "margin": 0,
            "width": 100,
            //            "height": 100,
            "frameborder": 0,
            "loop": 0,
            "playsigline": 1,
            "controls": 0,
            //                "autohide": 1,
            "showinfo": 0,
            "fs": 0,
            //            "rel": 0,
            "autoplay": 1
        ]
        ytVideoPlayerView.load(withVideoId: "FjJtmJteK58", playerVars: playerVars)
        
        
        setup()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if UIDevice.current.orientation.isLandscape {
            
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [self] _ in
            if size.width > size.height {
                tableView.removeFromSuperview()
                NSLayoutConstraint.deactivate(portraitConstraints)
                NSLayoutConstraint.activate(landscapeConstraints)
            } else {
                view.addSubview(tableView)
                NSLayoutConstraint.deactivate(landscapeConstraints)
                NSLayoutConstraint.activate(portraitConstraints)
            }
        }, completion: { context in
            
        })
    }
    
    // MARK: - Button View Gesture
    private func addButtonViewGesture() {
        let singleFinger = UITapGestureRecognizer(target: self, action: #selector(showButtonView))
        singleFinger.numberOfTapsRequired = 1
        singleFinger.numberOfTouchesRequired = 1
        self.buttonsView.addGestureRecognizer(singleFinger)
    }
    @objc func showButtonView() {
        buttonsView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        changeOrientationButton.isHidden = false
        showDanMuButton.isHidden = false
        showDanMuTextFieldButton.isHidden = false
        pauseButton.isHidden = false
        videoSlider.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            self?.changeOrientationButton.isHidden = true
            self?.showDanMuButton.isHidden = true
            self?.showDanMuTextFieldButton.isHidden = true
            self?.pauseButton.isHidden = true
            self?.videoSlider.isHidden = true
            self?.buttonsView.backgroundColor = UIColor(white: 0, alpha: 0)
        }
    }
    // MARK: -
    
    func setup() {
        view.addSubview(ytVideoPlayerView)
        view.addSubview(tableView)
        view.addSubview(buttonsView)
        buttonsView.addSubview(showDanMuButton)
        //        buttonsView.addSubview(showDanMuTextFieldButton)
        buttonsView.addSubview(pauseButton)
        buttonsView.addSubview(changeOrientationButton)
        buttonsView.addSubview(videoSlider)
        
        addButtonViewGesture()
        
        landscapeConstraints = [
            ytVideoPlayerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            ytVideoPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ytVideoPlayerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            ytVideoPlayerView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor),
            
            buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            buttonsView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 9 / 16),
            
            pauseButton.centerXAnchor.constraint(equalTo: ytVideoPlayerView.centerXAnchor),
            pauseButton.centerYAnchor.constraint(equalTo: ytVideoPlayerView.centerYAnchor),
            pauseButton.heightAnchor.constraint(equalToConstant: 60),
            pauseButton.widthAnchor.constraint(equalToConstant: 60),

            
            
            videoSlider.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor),
            videoSlider.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor),
            videoSlider.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -160),
            videoSlider.heightAnchor.constraint(equalToConstant: 10)
        ]
        
        portraitConstraints = [
            ytVideoPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ytVideoPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ytVideoPlayerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            ytVideoPlayerView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 9 / 16),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: ytVideoPlayerView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            buttonsView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 9 / 16),
            
            pauseButton.centerXAnchor.constraint(equalTo: ytVideoPlayerView.centerXAnchor),
            pauseButton.centerYAnchor.constraint(equalTo: ytVideoPlayerView.centerYAnchor),
            pauseButton.heightAnchor.constraint(equalToConstant: 60),
            pauseButton.widthAnchor.constraint(equalToConstant: 60),

            
            videoSlider.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor),
            videoSlider.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor),
            videoSlider.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -40),
            videoSlider.heightAnchor.constraint(equalToConstant: 10)
        ]
        NSLayoutConstraint.activate(portraitConstraints)
        
    }
}





//    private func setLandscapeAutoLayOut() {
//        tableView.removeFromSuperview()
//        removeAllContraints()
//        NSLayoutConstraint.activate([
//            baseView.centerXAnchor.constraint(equalTo: rootViewController.view.centerXAnchor),
//            baseView.centerYAnchor.constraint(equalTo: rootViewController.view.centerYAnchor),
//            baseView.widthAnchor.constraint(equalTo: rootViewController.view.widthAnchor),
//            baseView.heightAnchor.constraint(equalTo: rootViewController.view.heightAnchor),
//            ytVideoPlayerView.centerXAnchor.constraint(equalTo: rootViewController.view.centerXAnchor),
//            ytVideoPlayerView.centerYAnchor.constraint(equalTo: rootViewController.view.centerYAnchor),
//            ytVideoPlayerView.widthAnchor.constraint(equalTo: rootViewController.view.heightAnchor),
//            ytVideoPlayerView.heightAnchor.constraint(equalTo: rootViewController.view.widthAnchor),
//            buttonsView.centerXAnchor.constraint(equalTo: rootViewController.view.centerXAnchor),
//            buttonsView.centerYAnchor.constraint(equalTo: rootViewController.view.centerYAnchor),
//            buttonsView.widthAnchor.constraint(equalTo: rootViewController.view.heightAnchor),
//            buttonsView.heightAnchor.constraint(equalTo: rootViewController.view.widthAnchor),
//            danmuView.centerXAnchor.constraint(equalTo: rootViewController.view.centerXAnchor),
//            danmuView.centerYAnchor.constraint(equalTo: rootViewController.view.centerYAnchor),
//            danmuView.widthAnchor.constraint(equalTo: rootViewController.view.heightAnchor),
//            danmuView.heightAnchor.constraint(equalTo: rootViewController.view.widthAnchor),
//
//            videoSlider.centerXAnchor.constraint(equalTo: ytVideoPlayerView.centerXAnchor),
//            videoSlider.centerYAnchor.constraint(equalTo: ytVideoPlayerView.centerYAnchor, constant: 100),
//            videoSlider.widthAnchor.constraint(equalTo: rootViewController.view.heightAnchor, constant: -450),
//            videoSlider.heightAnchor.constraint(equalToConstant: 50),
//            changeOrientationButton.centerXAnchor.constraint(equalTo: ytVideoPlayerView.centerXAnchor),
//            changeOrientationButton.centerYAnchor.constraint(equalTo: ytVideoPlayerView.centerYAnchor, constant: 150),
//            changeOrientationButton.widthAnchor.constraint(equalToConstant: 40),
//            changeOrientationButton.heightAnchor.constraint(equalToConstant: 40),
//            showDanMuButton.centerXAnchor.constraint(equalTo: ytVideoPlayerView.centerXAnchor, constant: 90),
//            showDanMuButton.centerYAnchor.constraint(equalTo: ytVideoPlayerView.centerYAnchor, constant: 150),
//            showDanMuButton.widthAnchor.constraint(equalToConstant: 100),
//            showDanMuButton.heightAnchor.constraint(equalToConstant: 40)
//        ])
//    }
//    private func setPortraitAutoLayOut() {
//        rootViewController.view.addSubview(tableView)
//        removeAllContraints()
//        NSLayoutConstraint.activate([
//            baseView.leadingAnchor.constraint(equalTo: rootViewController.view.leadingAnchor),
//            baseView.trailingAnchor.constraint(equalTo: rootViewController.view.trailingAnchor),
//            baseView.topAnchor.constraint(equalTo: rootViewController.view.topAnchor),
//            baseView.leftAnchor.constraint(equalTo: rootViewController.view.leftAnchor),
//            baseView.widthAnchor.constraint(equalTo: rootViewController.view.widthAnchor),
//            baseView.heightAnchor.constraint(equalTo: rootViewController.view.heightAnchor),
//            ytVideoPlayerView.topAnchor.constraint(equalTo: rootViewController.view.topAnchor),
//            ytVideoPlayerView.leftAnchor.constraint(equalTo: rootViewController.view.leftAnchor),
//            ytVideoPlayerView.widthAnchor.constraint(equalTo: rootViewController.view.widthAnchor),
//            ytVideoPlayerView.heightAnchor.constraint(equalTo: rootViewController.view.widthAnchor, multiplier: 9/16),
//            baseView.topAnchor.constraint(equalTo: rootViewController.view.topAnchor),
//            baseView.leftAnchor.constraint(equalTo: rootViewController.view.leftAnchor),
//            baseView.widthAnchor.constraint(equalTo: rootViewController.view.widthAnchor),
//            baseView.heightAnchor.constraint(equalTo: rootViewController.view.widthAnchor, multiplier: 9/16),
//            tableView.topAnchor.constraint(equalTo: ytVideoPlayerView.bottomAnchor),
//            tableView.leadingAnchor.constraint(equalTo: rootViewController.view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: rootViewController.view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: rootViewController.view.bottomAnchor),
//            buttonsView.leadingAnchor.constraint(equalTo: rootViewController.view.leadingAnchor),
//            buttonsView.trailingAnchor.constraint(equalTo: rootViewController.view.trailingAnchor),
//            buttonsView.heightAnchor.constraint(equalTo: rootViewController.view.widthAnchor, multiplier: 9 / 16),
//            buttonsView.topAnchor.constraint(equalTo: rootViewController.view.topAnchor),
//            changeOrientationButton.centerXAnchor.constraint(equalTo: rootViewController.view.centerXAnchor),
//            changeOrientationButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -16),
//            changeOrientationButton.widthAnchor.constraint(equalToConstant: 30),
//            changeOrientationButton.heightAnchor.constraint(equalToConstant: 30),
//            danmuView.leadingAnchor.constraint(equalTo: ytVideoPlayerView.leadingAnchor),
//            danmuView.trailingAnchor.constraint(equalTo: ytVideoPlayerView.trailingAnchor),
//            danmuView.topAnchor.constraint(equalTo: ytVideoPlayerView.topAnchor),
//            danmuView.heightAnchor.constraint(equalTo: ytVideoPlayerView.heightAnchor, multiplier: 5 / 10),
//            showDanMuButton.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor, constant: -80),
//            showDanMuButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -16),
//            showDanMuButton.widthAnchor.constraint(equalToConstant: 100),
//            showDanMuButton.heightAnchor.constraint(equalToConstant: 30),
//            showDanMuTextFieldButton.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor, constant: -225),
//            showDanMuTextFieldButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -16),
//            showDanMuTextFieldButton.widthAnchor.constraint(equalToConstant: 30),
//            showDanMuTextFieldButton.heightAnchor.constraint(equalToConstant: 30),
//            pauseButton.centerXAnchor.constraint(equalTo: buttonsView.centerXAnchor),
//            pauseButton.centerYAnchor.constraint(equalTo: buttonsView.centerYAnchor),
//            pauseButton.widthAnchor.constraint(equalToConstant: 50),
//            pauseButton.heightAnchor.constraint(equalToConstant: 50),
//
//        ])
//
