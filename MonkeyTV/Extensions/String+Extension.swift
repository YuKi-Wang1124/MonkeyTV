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
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let stringSize = self.boundingRect(with: size,
                                        options: .usesLineFragmentOrigin,
                                        attributes: attributes,
                                        context: nil).size
        return stringSize
    }
}
