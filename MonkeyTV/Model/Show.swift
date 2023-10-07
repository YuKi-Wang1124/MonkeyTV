//
//  Show.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/22.
//

import Foundation

enum PlayerSection {
    case chatroom
    case danmu
    case playlist
}

struct Show: Codable, Hashable {
    let type: Int
    let playlistId: String
    let image: String
    let id: String
    let showName: String
    enum CodingKeys: String, CodingKey {
          case type
          case playlistId
          case image
          case id
          case showName
      }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        image = try container.decode(String.self, forKey: .image)
        playlistId = try container.decode(String.self, forKey: .playlistId)
        showName = try container.decode(String.self, forKey: .showName)
        type = try container.decode(Int.self, forKey: .type)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(image, forKey: .image)
        try container.encode(playlistId, forKey: .playlistId)
        try container.encode(showName, forKey: .showName)
        try container.encode(type, forKey: .type)
    }
}

enum OneSection {
    case main
}

enum ShowCatalog: String, CaseIterable {
    case titleAnimation = "標題"
    case animation = "二次元輕鬆看 🐹"
    case drama = "有點甜，有點鹹，一起追劇 🎬"
    case entertainment = "娛樂一下，放鬆身心 👨‍👩‍👧"
    case sport = "體育賽事隨你看 🏋🏻‍♀️"
    case food = "用眼睛吃美食不會胖 🍔"
    case health = "少一點醫生，多一點健康 🍀"
//    case internationalShow = "國外節目看到飽 🌎"
}
