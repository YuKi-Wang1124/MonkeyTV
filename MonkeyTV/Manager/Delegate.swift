//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/19.
//

import UIKit

protocol ShowVideoPlayerDelegate: AnyObject {
    func showVideoPlayer(showName: String, playlistId: String, id: String, showImage: String)
}

protocol EmptyTextFieldDelegate: AnyObject {
    func emptyTextField()
}

protocol ChangeCellButtonDelegate: AnyObject {
    func changeButtonImage()
}

protocol CleanSearchHistoryDelegate: AnyObject {
    func cleanSearchHistory()
}

protocol LogInDelegate: AnyObject {
    func logOut()
}

protocol NotificationSearchViewControllerIsSelectDelegate: AnyObject {
    func reloadSearchHistoryCoreData()
}
