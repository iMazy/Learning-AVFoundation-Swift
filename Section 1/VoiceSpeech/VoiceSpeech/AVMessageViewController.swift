//
//  AVMessageViewController.swift
//  VoiceSpeech
//
//  Created by Mazy on 2020/9/6.
//  Copyright © 2020 mazy. All rights reserved.
//

import UIKit
import AVFoundation

class AVMessageViewController: UITableViewController {

    private var manager: AVSpeechManager?
    private var speechStrings: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()


        self.manager = AVSpeechManager()
        self.manager?.synthesizer.delegate = self
        self.manager?.beginConversation()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.speechStrings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = indexPath.row % 2 == 0 ? "YouCell" : "AVCell";
        let cell: AVBubbleViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! AVBubbleViewCell
        cell.messageLabel.text = self.speechStrings[indexPath.row]

        return cell
    }

}

extension AVMessageViewController: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        self.speechStrings.append(utterance.speechString)
        self.tableView.reloadData()
        
        let indexPath = IndexPath(row: self.speechStrings.count - 1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
    }
}
