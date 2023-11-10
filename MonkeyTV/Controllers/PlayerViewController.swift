//
//  ViewController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit
import youtube_ios_player_helper

class PlayerViewController: UIViewController {
    
    var videoId: String = ""
    var playlistId: String = ""
    var id: String = ""
    var showName: String = ""
    var showImage: String = ""
    private var nextPageToken: String = ""
    private var userName: String = ""
    private var userImage: String = ""
    private var bulletChatText: String = ""
    
    private var landscapeConstraints: [NSLayoutConstraint] = []
    private var portraitConstraints: [NSLayoutConstraint] = []
        
    private var snapshot = NSDiffableDataSourceSnapshot<PlayerSection, MKShow>()
    private var dataSource: UITableViewDiffableDataSource<PlayerSection, MKShow>!
    
    // MARK: - support
    private var initialY: CGFloat = 0
    private var finalY: CGFloat = 0
    private var videoDuration = 0.00
    private var timer: Timer?
    private var bulletChats = [BulletChat]()
    private var playerBulletChats = [BulletChat]()
    private var emptyTextFieldDelegate: EmptyTextFieldDelegate?
    private var setupCellButtonDelegate: ChangeCellButtonDelegate?
    private let playerVars: [AnyHashable: Any] = [
        "frameborder": 0,
        "loop": 0,
        "playsigline": 1,
        "controls": 0,
        "showinfo": 0,
        "autoplay": 1
    ]
    // MARK: - Bools
    
    private var isMyShow: Bool = false
    private var isPanning: Bool = false
    private var isDanMuDisplayed: Bool = false
    private var danMuTextFiedIsShow: Bool = false
    private var videoIsPlaying: Bool = true
    private var playerIsShrink: Bool = false
    private var isSideViewVisible: Bool = false
    static var chatroonIsShow: Bool = false
    
    // MARK: - Views
    
    private lazy var ytVideoPlayerView: YTPlayerView = {
        let view = YTPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var bulletChatView: BulletChatView = {
        let view = BulletChatView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var buttonsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var showNameLabel: UILabel = {
        return CustomLabel(fontSize: 20, textColor: UIColor.darkAndWhite)
    }()
    
    private lazy var secondLabel: UILabel = {
        return CustomLabel(fontSize: 18, textColor: .white)
    }()
    
    private lazy var videoDurationLabel: UILabel = {
        return CustomLabel(fontSize: 18, textColor: UIColor(white: 0.9, alpha: 1))
    }()
    
    private lazy var tableView: CustomTableView = {
        return  CustomTableView(
            rowHeight: UITableView.automaticDimension,
            separatorStyle: .none,
            allowsSelection: true,
            registerCells: [ChatroomButtonTableViewCell.self,
                            BulletChatTextFieldTableViewCell.self,
                            ShowTableViewCell.self])
    }()
    
    private lazy var showDanMuButton = {
        let button = CustomButton(
            image: UIImage.systemAsset(.square, configuration: UIImage.smallSymbolConfig),
            color: .white, cornerRadius: 10, backgroundColor: UIColor.clear)
        button.setTitle(" 彈幕", for: .normal)
        return button
    }()
    
    private lazy var pauseButton = {
        return CustomButton(
            image: UIImage.systemAsset(.pause, configuration: UIImage.symbolConfig),
            color: .white, cornerRadius: 30)
    }()
    
    private lazy var videoSlider: UISlider = {
        let slider = UISlider()
        slider.thumbTintColor = UIColor.mainColor
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { await getUserName() }
        getMyFavoriteShowData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUILayout()
        setupTableView()
        setupVideoLauncher()
        setDanMu()
        getYouTubeVideoData()
        loadYoutubeVideo()
    }
    
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [self] _ in
            if size.width > size.height {
                tableView.removeFromSuperview()
                showNameLabel.removeFromSuperview()
                NSLayoutConstraint.deactivate(portraitConstraints)
                NSLayoutConstraint.activate(landscapeConstraints)
            } else {
                view.addSubview(tableView)
                view.addSubview(showNameLabel)
                showNameLabel.sizeToFit()
                NSLayoutConstraint.deactivate(landscapeConstraints)
                NSLayoutConstraint.activate(portraitConstraints)
            }
            bulletChatView.removeAllDanMuQueue()
            self.restartPlayerBulletChats()
        }, completion: { _ in
        })
    }
    
    deinit {
        timer = nil
        ytVideoPlayerView.pauseVideo()
        ytVideoPlayerView.removeWebView()
    }
    
    // MARK: - Button View & Gesture
    
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
        videoControls(isHidden: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            self?.buttonsView.backgroundColor = UIColor(white: 0, alpha: 0)
            self?.videoControls(isHidden: false)
        }
    }
    
    private func videoControls(isHidden: Bool) {
        showDanMuButton.isHidden = !isHidden
        pauseButton.isHidden = !isHidden
        videoSlider.isHidden = !isHidden
        secondLabel.isHidden = !isHidden
        videoDurationLabel.isHidden = !isHidden
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        
        if PlayerViewController.chatroonIsShow == true {
            return
        }
        
        let translation = gesture.translation(in: buttonsView)
        switch gesture.state {
            
        case .began:
            
            initialY = self.view.frame.origin.y
            finalY = initialY + translation.y
            isPanning = true
            
        case .changed:
            
            finalY = initialY + translation.y
            if finalY > initialY && (finalY - initialY) > self.view.frame.height / 3 {
                self.view.frame.origin.y = finalY
            }
            
        case .ended, .cancelled:
            
            isPanning = false
            let velocity = gesture.velocity(in: self.view)
            if finalY > initialY && (finalY - initialY) > self.view.frame.height / 3 && velocity.y > 100 {
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin.y = self.view.frame.height
                    self.dismiss(animated: true)
                }
            } else {
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
        
        showDanMuButton.addTarget(
            self, action: #selector(showBullet(sender:)), for: .touchUpInside)
        pauseButton.addTarget(
            self, action: #selector(pauseVideo(sender:)), for: .touchUpInside)
        videoSlider.addTarget(
            self, action: #selector(handleSliderChange(sender:)), for: .valueChanged)
    }
    
    @objc func handleSliderChange(sender: UISlider) {
        
        let desiredTime = sender.value
        secondLabel.text = TimeFormatter.shared.formatSecondsToHHMMSS(seconds: desiredTime)
        ytVideoPlayerView.seek(toSeconds: desiredTime, allowSeekAhead: true)
        bulletChatView.removeAllDanMuQueue()
        restartPlayerBulletChats()
    }
    
    @objc func pauseVideo(sender: UIButton) {
        
        bulletChatView.isPause = !bulletChatView.isPause
        
        switch videoIsPlaying {
        case true:
            sender.setImage(
                UIImage.systemAsset(.play, configuration: UIImage.symbolConfig), for: .normal)
            ytVideoPlayerView.pauseVideo()
        case false:
            sender.setImage(
                UIImage.systemAsset(.pause, configuration: UIImage.symbolConfig), for: .normal)
            ytVideoPlayerView.playVideo()
        }
        videoIsPlaying.toggle()
    }
    
    @objc func showBullet(sender: UIButton) {
        switch isDanMuDisplayed {
        case true:
            sender.setImage(
                UIImage.systemAsset(.square, configuration: UIImage.smallSymbolConfig), for: .normal)
            bulletChatView.isHidden = true
        case false:
            sender.setImage(
                UIImage.systemAsset(.checkmarkSquare, configuration: UIImage.smallSymbolConfig), for: .normal)
            bulletChatView.isHidden = false
        }
        isDanMuDisplayed.toggle()
    }
}

// MARK: - YTPlayerViewDelegate

extension PlayerViewController: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(
        _ playerView: YTPlayerView
    ) {
        getVideoDuratiion()
    }
    
    func playerView(
        _ playerView: YTPlayerView,
        didPlayTime playTime: Float
    ) {
        secondLabel.text = TimeFormatter.shared.formatSecondsToHHMMSS(seconds: playTime)
        
        playerBulletChats.forEach({
            if playTime >= $0.popTime {
                bulletChatView.danmuQueue.append(($0.content, false))
                self.playerBulletChats.remove(at: 0)
            }
        })
        
        if self.videoDuration != 0 {
            self.videoSlider.maximumValue = Float(self.videoDuration)
            videoSlider.value = playTime
        }
    }
}

// MARK: -
extension PlayerViewController {
    
    func tableView(
        _ tableView: UITableView,
        willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
        
        if indexPath.section == 2 {
            return indexPath
        }
        return nil
    }
    
    private func setupTableView() {
        
        tableView.delegate = self
        configureDataSource(tableView: tableView)
        snapshot.appendSections([.chatroom, .danmu, .playlist])
        let chatroom = MKShow(id: "chatroom",
                              videoId: videoId, image: showImage,
                              title: showName, playlistId: playlistId)
        let danmu = MKShow(id: "danmu",
                           videoId: videoId, image: showImage,
                           title: showName, playlistId: playlistId)
        snapshot.appendItems([chatroom], toSection: .chatroom)
        snapshot.appendItems([danmu], toSection: .danmu)
        
        tableView.addRefreshFooter(refreshingBlock: { [weak self] in
            self?.loadMoreYouTubeVideoData()
        })
    }

    private func addToSnapshot(data: [Playlist]) {
        data.forEach({
            let show = MKShow(id: $0.snippet.resourceId.videoId,
                              videoId: $0.snippet.resourceId.videoId,
                              image: $0.snippet.thumbnails.default.url,
                              title: $0.snippet.title,
                              playlistId: self.playlistId)
            self.snapshot.appendItems([show], toSection: .playlist)
            self.dataSource.apply(self.snapshot)
        })
    }
    
    private func configureDataSource(tableView: UITableView) {
        
        dataSource = UITableViewDiffableDataSource<PlayerSection, MKShow>(
            tableView: tableView,
            cellProvider: { tableView, indexPath, item in
                
                if indexPath.section == 0 {
                    let cell: BulletChatTextFieldTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                    cell.danMuTextField.delegate = cell
                    cell.userInputHandler = { [weak self] userInput in
                        self?.bulletChatText = userInput
                    }
                    cell.submitMessageButton.addTarget(self, action: #selector(self.submitMyDanMu), for: .touchUpInside)
                    self.emptyTextFieldDelegate = cell
                    cell.addButton.addTarget(self, action: #selector(self.addToMyShow(sender:)), for: .touchUpInside)
                    self.setupCellButtonDelegate = cell
                    cell.addButton.setImage(self.isMyShow ?
                                            UIImage.systemAsset(.checkmark, configuration: UIImage.symbolConfig) :
                                                UIImage.systemAsset(.plus, configuration: UIImage.symbolConfig),
                                            for: .normal)
                    cell.selectionStyle = .none
                    return cell
                } else if indexPath.section == 1 {
                    let cell: ChatroomButtonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                    cell.chatRoomButton.addTarget(
                        self, action: #selector(self.showChatroom(sender:)),
                        for: .touchUpInside)
                    cell.personalImageView.loadImage(self.userImage, placeHolder: UIImage.systemAsset(.personalPicture))
                    cell.chatroomNameLabel.text =
                    KeychainItem.currentEmail.isEmpty ? Constant.logInCanChat : "  以\(self.userName)的身份與大家聊天..."
                    cell.selectionStyle = .none
                    return cell
                } else {
                    let cell: ShowTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                    cell.showImageView.loadImage(item.image)
                    cell.showNameLabel.text = item.title
                    cell.playlistId = item.playlistId
                    cell.id = item.id
                    cell.selectionStyle = .none
                    return cell
                }
            }
        )
        tableView.dataSource = dataSource
        self.dataSource.apply(snapshot)
    }
    
    @objc func addToMyShow(sender: UIButton) {
        
        if KeychainItem.currentEmail == "" {
            UIAlertController.showLogInAlert(message: Constant.addShowLogInAlertMessage, delegate: self)
        } else {
            switch isMyShow {
            case true:
                sender.setImage(
                    UIImage.systemAsset( .plus, configuration: UIImage.symbolConfig), for: .normal)
                Task {
                    await FirestoreManager.deleteToMyFavorite(
                        email: KeychainItem.currentEmail,
                        playlistId: playlistId)
                }
                isMyShow = false
            case false:
                sender.setImage(
                    UIImage.systemAsset( .checkmark, configuration: UIImage.symbolConfig), for: .normal)
                FirestoreManager.addToMyFavorite(
                    email: KeychainItem.currentEmail,
                    playlistId: playlistId,
                    showImage: showImage,
                    showName: showName)
                isMyShow = true
            }
        }
    }
    
    // MARK: - Show Chatroom Button Action
    
    @objc func showChatroom(sender: UIButton) {
        
        if KeychainItem.currentEmail == "" {
            UIAlertController.showLogInAlert(message: Constant.addChatLogInAlertMessage, delegate: self)
        } else {
            PlayerViewController.chatroonIsShow = true
            var statusBarHeigh: CGFloat = 0.0
            if #available(iOS 13.0, *) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    statusBarHeigh = windowScene.statusBarManager?.statusBarFrame.height ?? 0
                }
            } else {
                statusBarHeigh = UIApplication.shared.statusBarFrame.height
            }
            let ytviewHeight = ytVideoPlayerView.frame.height
            let chatroomHeight = UIScreen.main.bounds.height - (statusBarHeigh + ytviewHeight + 30)
            
            let chatroomVC = ChatroomViewController()
            chatroomVC.videoId = self.videoId
            chatroomVC.showNameLabel.text = showNameLabel.text
            if let sheet = chatroomVC.sheetPresentationController {
                sheet.preferredCornerRadius = 0.0
                sheet.prefersGrabberVisible = true
                sheet.detents = [
                    .custom { _ in chatroomHeight }, .large()]
                sheet.largestUndimmedDetentIdentifier = .large
                self.sheetPresentationController?.prefersScrollingExpandsWhenScrolledToEdge = false
                self.present(chatroomVC, animated: true)
            }
        }
    }
    
    @objc func submitMyDanMu() {
        if bulletChatText != "" {
            bulletChatView.danmuQueue.append((bulletChatText, false))
            FirestoreManager.addBulletChatData(
                text: bulletChatText,
                popTime: videoSlider.value,
                videoId: videoId) {
                    self.emptyTextFieldDelegate?.emptyTextField()
                }
        }
    }
}

// MARK: - Get YouTube Video Data

extension PlayerViewController {
    
    private func loadYoutubeVideo() {
        if playlistId == "" {
            ytVideoPlayerView.load(withVideoId: videoId)
        } else {
            ytVideoPlayerView.load(withPlaylistId: playlistId, playerVars: playerVars)
        }
    }
}

extension PlayerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else { return }
        
        getVideoDuratiion()
        bulletChatView.removeAllDanMuQueue()
        bulletChats.removeAll()
        getBulletChatData(videoId: itemIdentifier.videoId)
        restartPlayerBulletChats()
        self.videoId = itemIdentifier.videoId
        showNameLabel.text = itemIdentifier.title
        ytVideoPlayerView.load(withVideoId: itemIdentifier.videoId, playerVars: playerVars)
    }
}

// MARK: - Layout & Setting

extension PlayerViewController {
    
    private func protraitLayout() {
        portraitConstraints = [
            ytVideoPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ytVideoPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ytVideoPlayerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            ytVideoPlayerView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 9 / 16),
            
            secondLabel.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor, constant: 24),
            secondLabel.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -8),
            
            videoDurationLabel.leadingAnchor.constraint(equalTo: secondLabel.trailingAnchor, constant: 4),
            videoDurationLabel.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -8),
            
            showDanMuButton.leadingAnchor.constraint(equalTo: videoDurationLabel.trailingAnchor, constant: 4),
            showDanMuButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -4),
            showDanMuButton.widthAnchor.constraint(equalToConstant: 90),
            showDanMuButton.heightAnchor.constraint(equalToConstant: 30),
            
            showNameLabel.topAnchor.constraint(equalTo: ytVideoPlayerView.bottomAnchor, constant: 10),
            showNameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            showNameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            showNameLabel.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -8),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            buttonsView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 9 / 16),
            
            bulletChatView.widthAnchor.constraint(equalTo: view.widthAnchor),
            bulletChatView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bulletChatView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 9 / 16, constant: -30),
            
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
    
    private func landscapeLayout() {
        landscapeConstraints = [
            ytVideoPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ytVideoPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ytVideoPlayerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            ytVideoPlayerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            secondLabel.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor, constant: 80),
            secondLabel.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -32),
            
            videoDurationLabel.leadingAnchor.constraint(equalTo: secondLabel.trailingAnchor, constant: 4),
            videoDurationLabel.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -32),
            
            showDanMuButton.leadingAnchor.constraint(equalTo: videoDurationLabel.trailingAnchor, constant: 16),
            showDanMuButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -28),
            showDanMuButton.widthAnchor.constraint(equalToConstant: 90),
            showDanMuButton.heightAnchor.constraint(equalToConstant: 30),
            
            bulletChatView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bulletChatView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bulletChatView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bulletChatView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),
            
            pauseButton.centerXAnchor.constraint(equalTo: ytVideoPlayerView.centerXAnchor),
            pauseButton.centerYAnchor.constraint(equalTo: ytVideoPlayerView.centerYAnchor),
            pauseButton.heightAnchor.constraint(equalToConstant: 60),
            pauseButton.widthAnchor.constraint(equalToConstant: 60),
            
            videoSlider.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor, constant: 30),
            videoSlider.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor, constant: -30),
            videoSlider.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -70),
            videoSlider.heightAnchor.constraint(equalToConstant: 10)
        ]
    }
    
    private func setupUILayout() {
        
        view.backgroundColor = .baseBackgroundColor
        ytVideoPlayerView.backgroundColor = .black
        
        view.addSubview(ytVideoPlayerView)
        view.addSubview(tableView)
        view.addSubview(bulletChatView)
        view.addSubview(buttonsView)
        view.addSubview(showNameLabel)
        
        buttonsView.addSubview(showDanMuButton)
        buttonsView.addSubview(pauseButton)
        buttonsView.addSubview(videoSlider)
        buttonsView.addSubview(secondLabel)
        buttonsView.addSubview(videoDurationLabel)
        
        addButtonViewGesture()
        landscapeLayout()
        protraitLayout()
    }
    
    private func setupVideoLauncher() {
        buttonsView.backgroundColor = UIColor.clear
        videoControls(isHidden: false)
        setBtnsAddtarget()
        ytVideoPlayerView.delegate = self
        ytVideoPlayerView.backgroundColor = .black
        addButtonViewGesture()
    }
    
    // MARK: - Dan Mu
    private func setDanMu() {
        bulletChatView.isHidden = true
        bulletChatView.minSpeed = 1
        bulletChatView.maxSpeed = 2
        bulletChatView.gap = 20
        bulletChatView.lineHeight = 30
        bulletChatView.start()
        timer = Timer.scheduledTimer(timeInterval: 0.4,
                                     target: self, selector: #selector(addDanMuText),
                                     userInfo: nil, repeats: false)
    }
    
    @objc func addDanMuText() {
        let interval = CGFloat.random(in: 0.3...1.0)
        Timer.scheduledTimer(timeInterval: interval,
                             target: self, selector: #selector(addDanMuText),
                             userInfo: nil, repeats: false)
    }
}

// MARK: - GET DATA

extension PlayerViewController {
    
    private func getUserName() async {
        if KeychainItem.currentEmail.isEmpty {
            return
        }
        if let userInfo = await UserInfoManager.userInfo() {
            userName = userInfo.userName
            userImage = userInfo.userImage
        }
        tableView.reloadData()
    }
    
    private func getMyFavoriteShowData() {
        Task {
            await FirestoreManager.checkPlaylistIdInMyFavorite(
                email: KeychainItem.currentEmail,
                playlistIdToCheck: playlistId
            ) { (containsPlaylistId, error) in
                if error != nil {
                    return
                }
                if let containsPlaylistId = containsPlaylistId {
                    self.isMyShow = containsPlaylistId
                }
            }
        }
    }
    
    private func getYouTubeVideoData() {
        HTTPClientManager.shared.getYouTubeVideoData(
            complettion: { playlistArray in
                self.addToSnapshot(data: playlistArray)
                if let first = self.snapshot.itemIdentifiers(inSection: .playlist).first {
                    self.videoId = first.videoId
                    self.showName = first.title
                    DispatchQueue.main.async {
                        self.showNameLabel.text = first.title
                    }
                    self.dataSource.apply(self.snapshot)
                }
                self.getBulletChatData(videoId: self.videoId)
            })
    }
    
    private func getBulletChatData(videoId: String) {
        FirestoreManager.getBulletChatData(videoId: videoId) { bulletChats in
            self.bulletChats = bulletChats
            self.restartPlayerBulletChats()
        }
    }

    private func restartPlayerBulletChats() {
        playerBulletChats.removeAll()
        playerBulletChats.append(contentsOf: self.bulletChats.filter {
            $0.popTime >= videoSlider.value - 2
        })
        playerBulletChats.sort()
    }
    
    private func loadMoreYouTubeVideoData() {
        HTTPClientManager.shared.request(
            YoutubeRequest.nextPageToken,
            completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    do {
                        let info = try  JSONDecoder().decode(PlaylistListResponse.self, from: data)
                        YouTubeParameter.shared.nextPageToken = info.nextPageToken
                        addToSnapshot(data: info.items)
                        loadMoreYouTubeVideoData()
                    } catch {
                        decodePreTokenData(data, self)
                    }
                case .failure(let error):
                    print(Result<Any>.failure(error))
                }
            })
        tableView.endWithNoMoreData()
    }
    
    private func decodePreTokenData(
        _ data: Data,
        _ self: PlayerViewController
    ) {
        do {
            let info = try JSONDecoder().decode(PlaylistListLastResponse.self, from: data)
            self.nextPageToken = info.prevPageToken
            if YouTubeParameter.shared.nextPageToken == nextPageToken {
                tableView.endWithNoMoreData()
                return
            }
            addToSnapshot(data: info.items)
        } catch {
            print(Result<Any>.failure(error))
        }
    }
    
    private func getVideoDuratiion() {
        ytVideoPlayerView.duration { [self] (duration, error) in
            if let error = error {
                print("無法取得影片總時間：\(error.localizedDescription)")
            } else {
                self.videoDuration = duration
                let timeString = TimeFormatter.shared.formatSecondsToHHMMSS(seconds: Float(videoDuration))
                videoDurationLabel.text = "/ " + timeString
            }
        }
    }
}
