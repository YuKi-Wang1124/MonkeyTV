//
//  ViewController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit
import youtube_ios_player_helper

class PlayerViewController: UIViewController {
    var videoId: String = "6vn8HP8_L6Q"
    private var landscapeConstraints: [NSLayoutConstraint] = []
    private var portraitConstraints: [NSLayoutConstraint] = []
    // MARK: - support
    private let symbolConfig = UIImage.SymbolConfiguration(pointSize: 30)
    private let smallSymbolConfig = UIImage.SymbolConfiguration(pointSize: 20)
    private var initialY: CGFloat = 0
    private var finalY: CGFloat = 0
    private var videoDuration = 0
    private var timer: Timer?
    private var bulletChats = [BulletChat]()
    private var danMuText: String = ""
    private var emptyTextFieldDelegate: EmptyTextFieldDelegate?
    // MARK: - Bools
    private var isPanning = false
    private var isDanMuDisplayed = false
    private var danMuTextFiedIsShow = false
    private var videoIsPlaying = true
    private var playerIsShrink = false
    private var isSideViewVisible = false
    // MARK: - Views
    private var ytVideoPlayerView: YTPlayerView = {
        let view = YTPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var danmuView: DanMuView = {
        let view = DanMuView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var buttonsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var tableView: UITableView = {
        var tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(ChatroomButtonTableViewCell.self,
                           forCellReuseIdentifier:
                            ChatroomButtonTableViewCell.identifier)
        tableView.register(DanMuTextFieldTableViewCell.self,
                           forCellReuseIdentifier:
                            DanMuTextFieldTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private var snapshot = NSDiffableDataSourceSnapshot<OneSection, MKShow>()
    private var dataSource: UITableViewDiffableDataSource<OneSection, MKShow>!
    // MARK: - Buttons
    private lazy var changeOrientationButton = {
        return UIButton.createPlayerButton(
            image: UIImage.systemAsset(.enlarge, configuration: smallSymbolConfig),
            color: .white, cornerRadius: 10)
    }()
    private lazy var showDanMuButton = {
        let button = UIButton.createPlayerButton(
            image: UIImage.systemAsset(.square, configuration: smallSymbolConfig),
            color: .white, cornerRadius: 10)
        button.setTitle("彈幕", for: .normal)
        return button
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
        setupUILayout()
        setupTableView()
        getDanMuData()
        setupVideoLauncher()
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [self] _ in
            if size.width > size.height {
                tableView.removeFromSuperview()
                self.changeOrientationButton.setImage(
                    UIImage.systemAsset(.shrink, configuration: self.symbolConfig), for: .normal)
                NSLayoutConstraint.deactivate(portraitConstraints)
                NSLayoutConstraint.activate(landscapeConstraints)
            } else {
                self.changeOrientationButton.setImage(
                    UIImage.systemAsset(.enlarge, configuration: self.symbolConfig), for: .normal)
                view.addSubview(tableView)
                NSLayoutConstraint.deactivate(landscapeConstraints)
                NSLayoutConstraint.activate(portraitConstraints)
            }
        }, completion: { _ in
        })
    }
    deinit {
        timer = nil
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
        pauseButton.isHidden = false
        videoSlider.isHidden = false
        changeOrientationButton.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            self?.showDanMuButton.isHidden = true
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
        showDanMuButton.addTarget(self, action: #selector(showDanMuView(sender:)),
                                  for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseVideo(sender:)), for: .touchUpInside)
        changeOrientationButton.addTarget(self,
                                          action: #selector(changeOrientation(sender:)),
                                          for: .touchUpInside)
        videoSlider.addTarget(self, action: #selector(handleSliderChange(sender:)),
                              for: .valueChanged)
    }
    // MARK: - Handle Slider Change
    @objc func handleSliderChange(sender: UISlider) {
        let desiredTime = sender.value
        ytVideoPlayerView.seek(toSeconds: desiredTime, allowSeekAhead: true)
    }
    // MARK: - pauseVideo
    @objc func pauseVideo(sender: UIButton) {
        danmuView.isPause = !danmuView.isPause
        if videoIsPlaying {
            sender.setImage(UIImage.systemAsset(.play, configuration: self.symbolConfig),
                            for: .normal)
            ytVideoPlayerView.pauseVideo()
        } else {
            sender.setImage(UIImage.systemAsset(.pause, configuration: self.symbolConfig),
                            for: .normal)
            ytVideoPlayerView.playVideo()
        }
        videoIsPlaying.toggle()
    }
    // MARK: - Change Orientation
    @objc func changeOrientation(sender: UIButton) {
        if playerIsShrink == false {
            tableView.removeFromSuperview()
            sender.setImage(UIImage.systemAsset(.shrink, configuration: self.symbolConfig), for: .normal)
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
        } else {
            view.addSubview(tableView)
            sender.setImage(UIImage.systemAsset(.enlarge, configuration: self.symbolConfig), for: .normal)
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
        }
        playerIsShrink.toggle()
    }
    // MARK: - showDanMuView
    @objc func showDanMuView(sender: UIButton) {
        if !isDanMuDisplayed {
            sender.setImage(UIImage.systemAsset(.checkmarkSquare, configuration: smallSymbolConfig), for: .normal)
            danmuView.isHidden = false
        } else {
            sender.setImage(UIImage.systemAsset(.square, configuration: smallSymbolConfig), for: .normal)
            danmuView.isHidden = true
        }
        isDanMuDisplayed.toggle()
    }
    // MARK: -
    private func setupUILayout() {
        setBtnsAddtarget()
        view.addSubview(ytVideoPlayerView)
        view.addSubview(tableView)
        view.addSubview(danmuView)
        view.addSubview(buttonsView)
        buttonsView.addSubview(showDanMuButton)
        buttonsView.addSubview(pauseButton)
        buttonsView.addSubview(videoSlider)
        buttonsView.addSubview(changeOrientationButton)
        
        addButtonViewGesture()
        
        landscapeConstraints = [
            ytVideoPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ytVideoPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ytVideoPlayerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            ytVideoPlayerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            danmuView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            danmuView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            danmuView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            danmuView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            pauseButton.centerXAnchor.constraint(equalTo: ytVideoPlayerView.centerXAnchor),
            pauseButton.centerYAnchor.constraint(equalTo: ytVideoPlayerView.centerYAnchor),
            pauseButton.heightAnchor.constraint(equalToConstant: 60),
            pauseButton.widthAnchor.constraint(equalToConstant: 60),
            
            showDanMuButton.centerXAnchor.constraint(equalTo: buttonsView.centerXAnchor, constant: 80),
            showDanMuButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -32),
            showDanMuButton.widthAnchor.constraint(equalToConstant: 90),
            showDanMuButton.heightAnchor.constraint(equalToConstant: 30),
            
            changeOrientationButton.leadingAnchor.constraint(equalTo: showDanMuButton.trailingAnchor, constant: 12),
            changeOrientationButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -32),
            changeOrientationButton.heightAnchor.constraint(equalToConstant: 30),
            changeOrientationButton.widthAnchor.constraint(equalToConstant: 30),
            
            videoSlider.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor),
            videoSlider.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor),
            videoSlider.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -80),
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
            
            danmuView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            danmuView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            danmuView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            danmuView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 9 / 16),
            
            pauseButton.centerXAnchor.constraint(equalTo: ytVideoPlayerView.centerXAnchor),
            pauseButton.centerYAnchor.constraint(equalTo: ytVideoPlayerView.centerYAnchor),
            pauseButton.heightAnchor.constraint(equalToConstant: 60),
            pauseButton.widthAnchor.constraint(equalToConstant: 60),
            
            showDanMuButton.centerXAnchor.constraint(equalTo: buttonsView.centerXAnchor),
            showDanMuButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -8),
            showDanMuButton.widthAnchor.constraint(equalToConstant: 90),
            showDanMuButton.heightAnchor.constraint(equalToConstant: 30),
            changeOrientationButton.leadingAnchor.constraint(equalTo: showDanMuButton.trailingAnchor, constant: 12),
            changeOrientationButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -8),
            changeOrientationButton.heightAnchor.constraint(equalToConstant: 30),
            changeOrientationButton.widthAnchor.constraint(equalToConstant: 30),
            
            videoSlider.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor),
            videoSlider.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor),
            videoSlider.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -40),
            videoSlider.heightAnchor.constraint(equalToConstant: 10)
        ]
        NSLayoutConstraint.activate(portraitConstraints)
    }
    private func setupVideoLauncher() {
        buttonsView.backgroundColor = UIColor(white: 0, alpha: 0.0)
        //        danMuTextField.isHidden = true
        //        submitDanMuButton.isHidden = true
        changeOrientationButton.isHidden = true
        showDanMuButton.isHidden = true
        pauseButton.isHidden = true
        videoSlider.isHidden = true
        setBtnsAddtarget()
        setDanMu()
        ytVideoPlayerView.delegate = self
        ytVideoPlayerView.backgroundColor = .black
        addButtonViewGesture()
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
        ytVideoPlayerView.load(withVideoId: videoId, playerVars: playerVars)
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
}
// MARK: - YTPlayerViewDelegate
extension PlayerViewController: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        getVideoDuratiion()
    }
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch state {
        case .playing:
            print("Video is playing")
        case .paused:
            print("Video is paused")
        case .ended:
            print("Video playback ended")
        default:
            break
        }
    }
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
    }
    //    func playerViewPreferredInitialLoading(_ playerView: YTPlayerView) -> UIView? {
    //    }
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        self.bulletChats.sort()
        bulletChats.forEach({
            if playTime >= $0.popTime {
                danmuView.danmuQueue.append(($0.content, false))
                self.bulletChats.remove(at: 0)
            }
        })
        if self.videoDuration != 0 {
            self.videoSlider.maximumValue = Float(self.videoDuration)
            videoSlider.value = playTime
        }
    }
    func getVideoDuratiion() {
        ytVideoPlayerView.duration { (duration, error) in
            if let error = error {
                print("無法取得影片總時間：\(error.localizedDescription)")
            } else {
                self.videoDuration = Int(duration)
            }
        }
    }
    // MARK: - getDanMuData
    private func getDanMuData() {
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
                }
            }
    }
}

// MARK: -
extension PlayerViewController {
    
    private func setupTableView() {
        configureDataSource(tableView: tableView)
        snapshot.appendSections([.main])
        snapshot.appendItems([MKShow(image: "first", title: "first", playlistId: "first")])
        snapshot.appendItems([MKShow(image: "chatroom", title: "chatroom", playlistId: "chatroom")])
        snapshot.appendItems([MKShow(image: "danmu", title: "danmu", playlistId: "danmu")])
        tableView.dataSource = dataSource
        dataSource.apply(snapshot)
    }
    
    private func configureDataSource(tableView: UITableView) {
        dataSource = UITableViewDiffableDataSource<OneSection, MKShow>(
            tableView: tableView,
            cellProvider: { tableView, indexPath, item in
                if indexPath.row == 1 {
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: ChatroomButtonTableViewCell.identifier,
                        for: indexPath) as? ChatroomButtonTableViewCell
                    guard let cell = cell else { return UITableViewCell() }
                    cell.chatRoomButton.addTarget(
                        self, action: #selector(self.showChatroom(sender:)),
                        for: .touchUpInside)
                    return cell
                } else if indexPath.row == 2 {
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: DanMuTextFieldTableViewCell.identifier,
                        for: indexPath) as? DanMuTextFieldTableViewCell
                    guard let cell = cell else { return UITableViewCell() }
                    cell.danMuTextField.delegate = cell
                    cell.userInputHandler = { [weak self] userInput in
                        self?.danMuText = userInput
                        print(userInput)
                    }
                    cell.submitMessageButton.addTarget(self, action: #selector(self.submitMyDanMu), for: .touchUpInside)
                    self.emptyTextFieldDelegate = cell
                    return cell
                }
                return UITableViewCell()
            }
        )
    }
    // MARK: - Show Chatroom Button Action
    @objc func showChatroom(sender: UIButton) {
        let chatroomVC = ChatroomViewController()
        if let sheet = chatroomVC.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [
                .custom { _ in 500.0 },
                .large()]
            sheet.largestUndimmedDetentIdentifier = .large
            chatroomVC.videoId = self.videoId
            self.present(chatroomVC, animated: true)
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
                                         "popTime": videoSlider.value + 2,
                                         // TODO: userid
                                         "userId": "匿名"] as [String: Any],
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
