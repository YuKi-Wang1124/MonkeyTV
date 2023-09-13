//
//  Constants.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//

import Foundation

struct Constants {
    //swiftlint: disable identifier_name
    static var API_KEY = "AIzaSyAIIgG8wnY2bnMd9cXnSJaQWM5TnB63k7o"
    static var PLAYLIST_ID = "PL12UaAf_xzfrh9ZhI7S3lWTfUSwv84mzL"
    static var API_URL = "https://youtube.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(PLAYLIST_ID)&key=\(API_KEY)"

}

