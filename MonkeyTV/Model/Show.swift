//
//  Show.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/22.
//

import Foundation

struct Show: Codable, Hashable {
    let type: Int
    let playlistId: String
    let image: String
    let id: String
    let showName: String
}

enum OneSection {
    case main
}

enum ShowCatalog: String, CaseIterable {
    case health = "少一點醫生，多一點健康 🍀"
    case animation = "二次元輕鬆看 🐹"
    case sport = "體育賽事隨你看 🏋🏻‍♀️"
    case drama = "有點甜，有點鹹，一起追劇 🎬"
    case food = "用眼睛吃美食不會胖 🍔"
    case entertainment = "娛樂一下，放鬆身心 👨‍👩‍👧"
}
