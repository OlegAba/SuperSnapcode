//
//  AlbumTableViewCell.swift
//  Live-Snap
//
//  Created by Oleg Abalonski on 1/23/18.
//  Copyright © 2018 Oleg Abalonski. All rights reserved.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {
    
    var albumTitleLabel: UILabel!
    var albumCountLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.snapBlack
        selectionStyle = .none
        
        albumTitleLabel = UILabel()
        albumTitleLabel.textColor = UIColor.snapWhite
        
        albumCountLabel = UILabel()
        albumCountLabel.textColor = UIColor.snapWhite
        albumCountLabel.textAlignment = .right
        
        addSubview(albumTitleLabel)
        addSubview(albumCountLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        albumTitleLabel.frame = CGRect(x: 20, y: 0, width: frame.width / 2, height: frame.height)
        albumCountLabel.frame = CGRect(x: frame.width - (frame.width / 4) - 20, y: 0, width: frame.width / 4, height: frame.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setText(_ text: String) {
        albumTitleLabel.text = text
    }
    
    func setAlbumCount(_ count: Int) {
        albumCountLabel.text = String(count)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            backgroundColor = UIColor.snapYellow
            albumTitleLabel.textColor = UIColor.black
            albumCountLabel.textColor = UIColor.black
        } else {
            backgroundColor = UIColor.snapBlack
            albumTitleLabel.textColor = UIColor.snapWhite
            albumCountLabel.textColor = UIColor.snapWhite
        }
    }
    
}
