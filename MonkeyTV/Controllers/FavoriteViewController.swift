//
//  FavoriteViewController.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import UIKit
import AVFoundation

class FavoriteViewController: UIViewController {
      private var player: AVPlayer?
      private var playerLayer: AVPlayerLayer?

      override func viewDidLoad() {
          super.viewDidLoad()

          let playerFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
          let videoURL = URL(string: "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
          player = AVPlayer(url: videoURL!)
          playerLayer = AVPlayerLayer(player: player)
          playerLayer?.frame = playerFrame
          playerLayer?.videoGravity = .resizeAspectFill
          view.layer.addSublayer(playerLayer!)
          player?.play()
      }
}
