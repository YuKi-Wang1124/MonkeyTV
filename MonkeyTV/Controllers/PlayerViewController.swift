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
    private var initialY: CGFloat = 0
    private var finalY: CGFloat = 0
    // MARK: - Bools
    private var isPanning = false
    private var isDanMuDisplayed = false
    private var danMuTextFiedIsShow = false
    private var videoIsPlaying = true
    private var playerIsShrink = false
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
        buttonsView.addGestureRecognizer(singleFinger)
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        buttonsView.addGestureRecognizer(dragGesture)
    }
    @objc func showButtonView() {
        buttonsView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        showDanMuButton.isHidden = false
        showDanMuTextFieldButton.isHidden = false
        pauseButton.isHidden = false
        videoSlider.isHidden = false
        changeOrientationButton.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            self?.showDanMuButton.isHidden = true
            self?.showDanMuTextFieldButton.isHidden = true
            self?.pauseButton.isHidden = true
            self?.videoSlider.isHidden = true
            self?.changeOrientationButton.isHidden = true
            self?.buttonsView.backgroundColor = UIColor(white: 0, alpha: 0)
        }
    }
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
           let translation = gesture.translation(in: buttonsView)
           
           switch gesture.state {
           case .began:
               initialY = self.view.frame.origin.y
               finalY = initialY + translation.y
               isPanning = true
           case .changed:
               finalY = initialY + translation.y
               // 判斷是否超過 1/3 並且啟始點 Y 座標小於最終 Y 座標
               if finalY > initialY && (finalY - initialY) > self.view.frame.height / 3 {
                   // 在此處執行縮小視圖控制器的操作
                   // 例如，改變視圖控制器的 frame
                   self.view.frame.origin.y = finalY
               }
           case .ended, .cancelled:
               isPanning = false
               // 判斷是否具有一定加速度並且手勢已經達到 1/3 以上
               let velocity = gesture.velocity(in: self.view)
               if finalY > initialY && (finalY - initialY) > self.view.frame.height / 3 && velocity.y > 100 {
                   // 在此處執行往下縮小視圖控制器的操作
                   // 例如，使用動畫將視圖控制器縮小到底部
                   dismiss(animated: true)
                   UIView.animate(withDuration: 0.3) {
                       self.view.frame.origin.y = self.view.frame.height
                   }
               } else {
                   // 恢復視圖控制器到原始位置
                   UIView.animate(withDuration: 0.3) {
                       self.view.frame.origin.y = 0
                   }
               }
           default:
               break
           }
       }
    // MARK: - Buttons AddTaget
    private func setBtnsAddtarget() {
//        showDanMuButton.addTarget(self, action: #selector(showDanMuView(sender:)),
//                                  for: .touchUpInside)
//        showDanMuTextFieldButton.addTarget(self, action: #selector(showDanMuTextField(sender:)),
//                                           for: .touchUpInside)
//        pauseButton.addTarget(self, action: #selector(pauseVideo(sender:)), for: .touchUpInside)
        changeOrientationButton.addTarget(self,
                                          action: #selector(changeOrientation(sender:)),
                                          for: .touchUpInside)
//        submitDanMuButton.addTarget(self, action: #selector(submitMyDanMuButton(sender:)),
//                                    for: .touchUpInside)
//        videoSlider.addTarget(self, action: #selector(handleSliderChange(sender:)),
//                              for: .valueChanged)
    }
    // MARK: - Change Orientation
    @objc func changeOrientation(sender: UIButton) {
        if playerIsShrink == false {
            tableView.removeFromSuperview()
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
        } else {
            view.addSubview(tableView)
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
        }
        playerIsShrink.toggle()
    }
    // MARK: -
    func setup() {
        setBtnsAddtarget()
        view.addSubview(ytVideoPlayerView)
        view.addSubview(tableView)
        view.addSubview(buttonsView)
        buttonsView.addSubview(showDanMuButton)
        //        buttonsView.addSubview(showDanMuTextFieldButton)
        buttonsView.addSubview(pauseButton)
        buttonsView.addSubview(videoSlider)
        buttonsView.addSubview(changeOrientationButton)
        
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
            
            changeOrientationButton.centerXAnchor.constraint(equalTo: ytVideoPlayerView.centerXAnchor,constant: -50),
            changeOrientationButton.centerYAnchor.constraint(equalTo: ytVideoPlayerView.centerYAnchor),
            changeOrientationButton.heightAnchor.constraint(equalToConstant: 60),
            changeOrientationButton.widthAnchor.constraint(equalToConstant: 60),

            showDanMuButton.centerXAnchor.constraint(equalTo: buttonsView.centerXAnchor, constant: 180),
            showDanMuButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -120),
            showDanMuButton.widthAnchor.constraint(equalToConstant: 90),
            showDanMuButton.heightAnchor.constraint(equalToConstant: 30),
            
            
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
            
            showDanMuButton.centerXAnchor.constraint(equalTo: buttonsView.centerXAnchor, constant: 40),
            showDanMuButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -8),
            showDanMuButton.widthAnchor.constraint(equalToConstant: 90),
            showDanMuButton.heightAnchor.constraint(equalToConstant: 30),
            
            
            changeOrientationButton.centerXAnchor.constraint(equalTo: ytVideoPlayerView.centerXAnchor,constant: -50),
            changeOrientationButton.centerYAnchor.constraint(equalTo: ytVideoPlayerView.centerYAnchor),
            changeOrientationButton.heightAnchor.constraint(equalToConstant: 60),
            changeOrientationButton.widthAnchor.constraint(equalToConstant: 60),

            
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
//
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
//
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
