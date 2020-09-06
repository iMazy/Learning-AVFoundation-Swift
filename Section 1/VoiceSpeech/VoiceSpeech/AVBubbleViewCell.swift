//
//  AVBubbleViewCell.swift
//  VoiceSpeech
//
//  Created by Mazy on 2020/9/6.
//  Copyright © 2020 mazy. All rights reserved.
//

import UIKit

class AVBubbleViewCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
