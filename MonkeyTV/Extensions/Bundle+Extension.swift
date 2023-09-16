//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/13.
//

import Foundation

extension Bundle {
    // swiftlint:disable force_cast
    static func valueForString(key: String) -> String {
        return Bundle.main.infoDictionary![key] as! String
    }

    static func valueForInt32(key: String) -> Int32 {
        return Bundle.main.infoDictionary![key] as! Int32
    }
    // swiftlint:enable force_cast
}
