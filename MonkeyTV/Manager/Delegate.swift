//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/19.
//

import UIKit

protocol OrientationChangeDelegate: AnyObject {
    func didChangeOrientation(to newOrientation: UIInterfaceOrientation)
}

protocol ShowVideoPlayerDelegate: AnyObject {
    func showVideoPlayer()
}

