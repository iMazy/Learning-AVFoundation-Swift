//
//  ViewController.swift
//  VoiceMemo
//
//  Created by Mazy on 2020/9/9.
//  Copyright © 2020 mazy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var levelMeterView: VMLevelMeterView!
    
    private var memos: [VMMemoModel] = []
    private var levelTimer: CADisplayLink?
    private var timer: Timer?
    private lazy var manager: VMRecorderManager = VMRecorderManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.manager.delegate = self
        self.stopButton.isEnabled = false

        let recordImage = UIImage(named: "record")
        let pauseImage = UIImage(named: "pause")
        let stopImage = UIImage(named: "stop")

        self.recordButton.setImage(recordImage, for: .normal)
        self.recordButton.setImage(pauseImage, for: .selected)
        self.stopButton.setImage(stopImage, for: .normal)
        
        if  let docsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
            let url = URL(string: docsDir) {
            guard let directoryContents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []) else { return }
//            print("directoryContents \(directoryContents)")
            
            for url in directoryContents {
                
                if url.absoluteString.hasSuffix("m4a") {
                    
                    let lastPathComponent = url.lastPathComponent.replacingOccurrences(of: ".m4a", with: "")
                    let infos = lastPathComponent.components(separatedBy: "-")
                    guard let name = infos.first, let time = infos.last else { return }
                    let model = VMMemoModel(title: name, url: url)
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyyMMddHHmmss"
                    if let date = formatter.date(from: time) {
                        model.dateString = model.dateStringWithDate(date)
                        model.timeString = model.timeStringWithDate(date)
                    }
                    self.memos.append(model)
                    print(url.lastPathComponent)
                }
            }
            
            self.tableView.reloadData()

        }
    }
    
    @IBAction func recordAction(_ sender: UIButton) {
        self.stopButton.isEnabled = true
        if !sender.isSelected {
            self.startMeterTimer()
            self.startTimer()
            let result = self.manager.record()
            print("start result: \(result)")
        } else {
            self.stopMeterTimer()
            self.stopTimer()
            self.manager.pause()
        }
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func stopRecordingAction(_ sender: UIButton) {
        self.stopMeterTimer()
        self.recordButton.isSelected = false
        self.stopButton.isEnabled = false
        self.manager.stopWithCompletionHandler { (result) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                self.showSaveDialog()
            }
        }
    }
    
    func showSaveDialog()  {
        let alertVC = UIAlertController(title: "Save Recording", message: "Please provide a name", preferredStyle: .alert)
        alertVC.addTextField { (textField) in
            textField.placeholder = "My Recording"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            let filename = alertVC.textFields?.first?.text ?? ""
            self.manager.saveRecordingWithName(filename) { (result, model) in
                if result {
                    if let memo = model {
                        self.memos.append(memo)
                    }
                    self.tableView.reloadData()
                }
            }
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func startTimer() {
        self.timer?.invalidate()
        self.timer = Timer(timeInterval: 0.5, target: self, selector: #selector(updateTimeDisplay), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: .common)
    }
    
    @objc func updateTimeDisplay() {
        self.timeLabel.text = self.manager.formattedCurrentTime
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    
    func startMeterTimer() {
        self.levelTimer?.invalidate()
        self.levelTimer = CADisplayLink(target: self, selector: #selector(updateMeter))
        self.levelTimer?.preferredFramesPerSecond = 5
        self.levelTimer?.add(to: RunLoop.current, forMode: .common)
    }
    
    func stopMeterTimer()  {
        self.levelTimer?.invalidate()
        self.levelTimer = nil
        self.levelMeterView.resetLevelMeter()
    }

    @objc func updateMeter() {
        let levels: VMLevelPair = self.manager.levels
        self.levelMeterView.level = CGFloat(levels.level)
        self.levelMeterView.peakLevel = CGFloat(levels.peakLevel)
        self.levelMeterView.setNeedsDisplay()
    }
}

/// VMRecorderManagerDelegate
extension ViewController: VMRecorderManagerDelegate {
    ///
    func interruptionBegan() {
        self.recordButton.isSelected = false
        self.stopMeterTimer()
        self.stopTimer()
    }
}

/// MARK: - UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: VMMemoViewCell = tableView.dequeueReusableCell(withIdentifier: "VMMemoViewCell", for: indexPath) as! VMMemoViewCell
        cell.configWithModel(memos[indexPath.row])
        return cell
    }
}
