//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/10/2.
//

import UIKit

class ProfileTitleTableViewCell: UITableViewCell {
   
    static let identifier = "\(ProfileTitleTableViewCell.self)"
   
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func prepareForReuse() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  
}
