//
//  VMMemoViewCell.swift
//  VoiceMemo
//
//  Created by Mazy on 2020/9/9.
//  Copyright © 2020 mazy. All rights reserved.
//

import UIKit

class VMMemoViewCell: UITableViewCell {

    @IBOutlet weak var mainTitleLabel: UILabel! // 名称
    @IBOutlet weak var dateLabel: UILabel! // 日期
    @IBOutlet weak var timeLabel: UILabel! // 时间
    
    func configWithModel(_ model: VMMemoModel) {
        mainTitleLabel.text = model.title
        dateLabel.text = model.dateString
        timeLabel.text = model.timeString
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
