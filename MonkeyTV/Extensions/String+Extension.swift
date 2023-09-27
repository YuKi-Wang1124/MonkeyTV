//
//  String+Extension.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/27.
//
import Foundation
import UIKit

extension String {
    
    func getLabWidth(font: UIFont, height: CGFloat) -> CGSize {
        let size = CGSize(width: 900, height: height)
        let dic = NSDictionary(object: font, forKey: NSAttributedString.Key.font as NSCopying)
        let strSize = self.boundingRect(with: size,
                                        options: .usesLineFragmentOrigin,
                                        attributes: dic as? [NSAttributedString.Key : Any],
                                        context: nil).size
        return strSize
    }
}
