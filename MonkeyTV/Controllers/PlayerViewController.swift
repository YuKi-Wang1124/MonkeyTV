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
    private var danMuText: String = ""
    private var landscapeConstraints: [NSLayoutConstraint] = []
    private var portraitConstraints: [NSLayoutConstraint] = []
    
    // MARK: - support
    private var initialY: CGFloat = 0
    private var finalY: CGFloat = 0
    private var videoDuration = 0.00
    private var timer: Timer?
    private var bulletChats = [BulletChat]()
    private var playerBulletChats = [BulletChat]()
    private var emptyTextFieldDelegate: EmptyTextFieldDelegate?
    private var setupCellButtonDelegate: ChangeCellButtonDelegate?
    
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
    
    private lazy var danmuView: DanMuView = {
        let view = DanMuView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var buttonsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var showNameLabel: UILabel = {
        return UILabel.createLabel(fontSize: 20, textColor: UIColor.darkAndWhite)
    }()

    private lazy var secondLabel: UILabel = {
        return UILabel.createLabel(fontSize: 18, textColor: .white)
    }()

    private lazy var videoDurationLabel: UILabel = {
        return UILabel.createLabel(fontSize: 18, textColor: UIColor(white: 0.9, alpha: 1))
    }()

    private var tableView: UITableView = {
        var tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
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
    
    // MARK: - Snapshot & DataSource
    
    private var snapshot = NSDiffableDataSourceSnapshot<PlayerSection, MKShow>()
    private var dataSource: UITableViewDiffableDataSource<PlayerSection, MKShow>!
    
    private lazy var showDanMuButton = {
        let button = UIButton.createPlayerButton(
            image: UIImage.systemAsset(.square, configuration: UIImage.smallSymbolConfig),
            color: .white, cornerRadius: 10, backgroundColor: UIColor.clear)
        button.setTitle(" 彈幕", for: .normal)
        return button
    }()
    
    private lazy var pauseButton = {
        return UIButton.createPlayerButton(
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
        Task { await showUserName() }
        setupMyShow()
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
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
            
            danmuView.removeAllDanMuQueue()
            self.restartPlayerBulletChats()
            
        }, completion: { _ in
        })
    }
    deinit {
        timer = nil
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
        showControls(shouldShow: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            self?.buttonsView.backgroundColor = UIColor(white: 0, alpha: 0)
            self?.showControls(shouldShow: false)
        }
    }

    private func showControls(shouldShow: Bool) {
        showDanMuButton.isHidden = !shouldShow
        pauseButton.isHidden = !shouldShow
        videoSlider.isHidden = !shouldShow
        secondLabel.isHidden = !shouldShow
        videoDurationLabel.isHidden = !shouldShow
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
        
        showDanMuButton.addTarget(self, action: #selector(showDanMuView(sender:)),
                                  for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseVideo(sender:)), for: .touchUpInside)
        videoSlider.addTarget(self, action: #selector(handleSliderChange(sender:)),
                              for: .valueChanged)
    }
        
    @objc func handleSliderChange(sender: UISlider) {
        let desiredTime = sender.value
        secondLabel.text = TimeFormatter.shared.formatSecondsToHHMMSS(seconds: desiredTime)
        ytVideoPlayerView.seek(toSeconds: desiredTime, allowSeekAhead: true)
        danmuView.removeAllDanMuQueue()
        restartPlayerBulletChats()
    }
    
    @objc func pauseVideo(sender: UIButton) {
        danmuView.isPause = !danmuView.isPause
        if videoIsPlaying {
            sender.setImage(UIImage.systemAsset(.play, configuration: UIImage.symbolConfig),
                            for: .normal)
            ytVideoPlayerView.pauseVideo()
        } else {
            sender.setImage(UIImage.systemAsset(.pause, configuration: UIImage.symbolConfig),
                            for: .normal)
            ytVideoPlayerView.playVideo()
        }
        videoIsPlaying.toggle()
    }
    
    @objc func showDanMuView(sender: UIButton) {
        if !isDanMuDisplayed {
            sender.setImage(UIImage.systemAsset(.checkmarkSquare,
                                                configuration: UIImage.smallSymbolConfig), for: .normal)
            danmuView.isHidden = false
        } else {
            sender.setImage(UIImage.systemAsset(.square,
                                                configuration: UIImage.smallSymbolConfig), for: .normal)
            danmuView.isHidden = true
        }
        isDanMuDisplayed.toggle()
    }
}

// MARK: - YTPlayerViewDelegate

extension PlayerViewController: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        getVideoDuratiion()
    }
    
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        
        secondLabel.text = TimeFormatter.shared.formatSecondsToHHMMSS(seconds: playTime)
        
        playerBulletChats.forEach({
            if playTime >= $0.popTime {
                danmuView.danmuQueue.append(($0.content, false))
                self.playerBulletChats.remove(at: 0)
            }
        })
        
        if self.videoDuration != 0 {
            self.videoSlider.maximumValue = Float(self.videoDuration)
            videoSlider.value = playTime
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
                print("\(timeString)")
    
            }
        }
    }
    
    // MARK: - Get Dan Mu Data
    
    private func getDanMuData(videoId: String) {
        FirestoreManager.bulletChat.whereField(
            "videoId", isEqualTo: videoId).getDocuments { querySnapshot, error in
                if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                            let decodedObject = try JSONDecoder().decode(BulletChatData.self, from: jsonData)
                            self.bulletChats.append(decodedObject.bulletChat)
                            
                        } catch {
                            print("\(error)")
                        }
                    }
                    self.restartPlayerBulletChats()
                }
            }
    }
    
    private func restartPlayerBulletChats() {
        
        self.playerBulletChats.removeAll()
        self.playerBulletChats.append(contentsOf: self.bulletChats.filter {
            $0.popTime >= videoSlider.value - 2
        })
        self.playerBulletChats.sort()
    }
}

// MARK: -
extension PlayerViewController {
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
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
            self?.loadMore()
        })
    }
    
    private func loadMore() {
        let decoder = JSONDecoder()
        HTTPClientManager.shared.request(
            YoutubeRequest.nextPageToken, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                do {
                    let info = try decoder.decode(PlaylistListResponse.self, from: data)
                    YouTubeParameter.shared.nextPageToken = info.nextPageToken
                    addToSnapshot(data: info.items)
                    loadMore()
                } catch {
                    do {
                        let info = try decoder.decode(PlaylistListLastResponse.self, from: data)
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
            case .failure(let error):
                print(Result<Any>.failure(error))
            }
        })
        tableView.endWithNoMoreData()
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
                
                if indexPath.section == 1 {
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: ChatroomButtonTableViewCell.identifier,
                        for: indexPath) as? ChatroomButtonTableViewCell
                    
                    guard let cell = cell else { return UITableViewCell() }
                    cell.chatRoomButton.addTarget(
                        self, action: #selector(self.showChatroom(sender:)),
                        for: .touchUpInside)
                    cell.personalImageView.loadImage(self.userImage, placeHolder: UIImage.systemAsset(.personalPicture))
                    
                    if KeychainItem.currentEmail == "" {
                        cell.chatroomNameLabel.text = "  登入會員後即可與大家聊天..."
                    } else {
                        cell.chatroomNameLabel.text = "  以\(self.userName)的身份與大家聊天..."
                    }
                    cell.selectionStyle = .none
                    return cell
                } else if indexPath.section == 0 {
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: DanMuTextFieldTableViewCell.identifier,
                        for: indexPath) as? DanMuTextFieldTableViewCell
                    
                    guard let cell = cell else { return UITableViewCell() }
                    cell.danMuTextField.delegate = cell
                    cell.userInputHandler = { [weak self] userInput in
                        self?.danMuText = userInput
                    }
                    cell.submitMessageButton.addTarget(self, action: #selector(self.submitMyDanMu), for: .touchUpInside)
                    self.emptyTextFieldDelegate = cell
                    cell.addButton.addTarget(self, action: #selector(self.addToMyShow(sender:)), for: .touchUpInside)
                    self.setupCellButtonDelegate = cell
                    
                    if self.isMyShow {
                        cell.addButton.setImage(
                            UIImage.systemAsset(.checkmark, configuration: UIImage.symbolConfig), for: .normal)
                    } else {
                        cell.addButton.setImage(
                            UIImage.systemAsset(.plus, configuration: UIImage.symbolConfig), for: .normal)
                    }
                    cell.selectionStyle = .none
                    return cell
                    
                } else if indexPath.section == 2 {
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: ShowTableViewCell.identifier,
                        for: indexPath) as? ShowTableViewCell
                    
                    guard let cell = cell else { return UITableViewCell() }
                    cell.showImageView.loadImage(item.image)
                    cell.showNameLabel.text = item.title
                    cell.playlistId = item.playlistId
                    cell.id = item.id
                    cell.selectionStyle = .none
                    return cell
                }
                return UITableViewCell()
            }
        )
        tableView.dataSource = dataSource
        self.dataSource.apply(snapshot)
    }
    
    private func showLogInAlert(message: String) {
        let alertController = UIAlertController(
            title: "請先加入會員",
            message: message,
            preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "前往登入", style: .default) { [weak self] _ in
            self?.handleLoginAction()
        })
        alertController.addAction(UIAlertAction(title: "先看看", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    private func handleLoginAction() {
        dismiss(animated: true)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let tabBarController = windowScene.windows.first?.rootViewController as? UITabBarController {
            tabBarController.selectedIndex = 3
        }
    }

    @objc func addToMyShow(sender: UIButton) {
        
        if KeychainItem.currentEmail == "" {
            showLogInAlert(message: Constant.addShowLogInAlertMessage)
        } else {
            if isMyShow == true {
                sender.setImage(UIImage.systemAsset( .plus, configuration: UIImage.symbolConfig),
                                for: .normal)
                
                Task { await  FirestoreManager.deleteToMyFavorite(
                    email: KeychainItem.currentEmail,
                    playlistId: playlistId) }
                isMyShow = false
            } else {
                sender.setImage(UIImage.systemAsset( .checkmark, configuration: UIImage.symbolConfig),
                                for: .normal)
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
            showLogInAlert(message: Constant.addShowLogInAlertMessage)
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
    
    @objc func submitMyDanMu(sender: UIButton) {
        if danMuText != "" {
            danmuView.danmuQueue.append((danMuText, false))
            let id = FirestoreManager.bulletChat.document().documentID
            let data: [String: Any] = ["bulletChat":
                                        ["chatId": UUID().uuidString,
                                         "content": danMuText,
                                         "contentType": 0,
                                         "popTime": videoSlider.value,
                                         "userId": KeychainItem.currentEmail] as [String: Any],
                                       "videoId": videoId,
                                       "id": id]
            FirestoreManager.bulletChat.document(id).setData(data) { error in
                if error != nil {
                    print("Error adding document: (error)")
                } else {
                    self.emptyTextFieldDelegate?.emptyTextField()
                }
            }
        }
    }
}

// MARK: - Get YouTube Video Data

extension PlayerViewController {
    
    func getYouTubeVideoData() {
        HTTPClientManager.shared.request(
            YoutubeRequest.playlistItems(
                playlistId: YouTubeParameter.shared.playlistId),
            completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    do {
                        let info = try JSONDecoder().decode(PlaylistListResponse.self, from: data)
                        YouTubeParameter.shared.nextPageToken = info.nextPageToken
                        addToSnapshot(data: info.items)
                    } catch {
                        print(Result<Any>.failure(error))
                    }
                case .failure(let error):
                    print(Result<Any>.failure(error))
                }
                if let first = self.snapshot.itemIdentifiers(inSection: .playlist).first {
                    self.videoId = first.videoId
                    self.showName = first.title
                    DispatchQueue.main.async {
                        self.showNameLabel.text = first.title
                    }
                    getDanMuData(videoId: self.videoId)
                    self.dataSource.apply(snapshot)
                }
            })
    }
    private func loadYoutubeVideo() {
        let playerVars: [AnyHashable: Any] = [
            "frameborder": 0,
            "loop": 0,
            "playsigline": 1,
            "controls": 0,
            "showinfo": 0,
            "autoplay": 1
        ]
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
        
        let playerVars: [AnyHashable: Any] = [
            "frameborder": 0, "loop": 0,
            "playsigline": 1,
            "controls": 0,
            "showinfo": 0,
            "autoplay": 1]
        
        getVideoDuratiion()
        danmuView.removeAllDanMuQueue()
        bulletChats.removeAll()
        getDanMuData(videoId: itemIdentifier.videoId)
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
            
            danmuView.widthAnchor.constraint(equalTo: view.widthAnchor),
            danmuView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            danmuView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 9 / 16, constant: -30),
            
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
            
            danmuView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            danmuView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            danmuView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            danmuView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),
            
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
        tableView.backgroundColor = .baseBackgroundColor
        ytVideoPlayerView.backgroundColor = .black
        
        setBtnsAddtarget()
        view.addSubview(ytVideoPlayerView)
        view.addSubview(tableView)
        view.addSubview(danmuView)
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
    
    private func showUserName() async {
        if KeychainItem.currentEmail.isEmpty {
            return
        }
        if let userInfo = await UserInfoManager.userInfo() {
            userName = userInfo.userName
            userImage = userInfo.userImage
        }
        tableView.reloadData()
    }
    
    private func setupVideoLauncher() {
        buttonsView.backgroundColor = UIColor(white: 0, alpha: 0.0)
        showControls(shouldShow: false)
        setBtnsAddtarget()
        ytVideoPlayerView.delegate = self
        ytVideoPlayerView.backgroundColor = .black
        addButtonViewGesture()
    }
    
    // MARK: - Dan Mu
    private func setDanMu() {
        danmuView.isHidden = true
        danmuView.minSpeed = 1
        danmuView.maxSpeed = 2
        danmuView.gap = 20
        danmuView.lineHeight = 30
        danmuView.start()
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
    
    private func setupMyShow() {
        Task {
            await FirestoreManager.checkPlaylistIdInMyFavorite(
                email: KeychainItem.currentEmail, playlistIdToCheck: playlistId) { (containsPlaylistId, error) in
                    if let error = error {
                        print("Error: \(error)")
                        return
                    }
                    if let containsPlaylistId = containsPlaylistId {
                        self.isMyShow = containsPlaylistId
                    }
                }
        }
    }
}
