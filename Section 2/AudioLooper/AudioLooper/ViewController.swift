//
//  ViewController.swift
//  AudioLooper
//
//  Created by Mazy on 2020/9/8.
//  Copyright © 2020 mazy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var playButton: ALPlayButton!
    @IBOutlet weak var playLabel: UILabel!
    
    @IBOutlet weak var rateKnob: ALGreenControlKnob!
    
    @IBOutlet var panKnobs: [ALOrangeControlKnob]!
    @IBOutlet var volumeKnobs: [ALOrangeControlKnob]!
    
    private lazy var manager: ALPlayerManager = ALPlayerManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.manager.delegate = self
        
        self.rateKnob.minimumValue = 0.5
        self.rateKnob.maximumValue = 1.5
//        self.rateKnob.value = 1.0
        self.rateKnob.setValue(1.0, animated: false)
        self.rateKnob.defaultValue = 1.0
        
        for knob in self.panKnobs {
            knob.minimumValue = -1.0
            knob.maximumValue = 1.0
//            knob.value = 0.0
            self.rateKnob.setValue(0.0, animated: false)
            knob.defaultValue = 0.0
        }
        
        for knob in self.volumeKnobs {
            knob.minimumValue = 0.0
            knob.maximumValue = 1.0
//            knob.value = 1.0
            self.rateKnob.setValue(1.0, animated: false)
            knob.defaultValue = 1.0
        }
    }

    @IBAction func playAction(_ sender: ALPlayButton) {
        self.playButton.isSelected = !self.playButton.isSelected
        if !self.manager.isPlaying {
            self.manager.play()
            self.playLabel.text = "Stop"
        } else {
            self.manager.stop()
            self.playLabel.text = "Play"
        }
    }
    
    @IBAction func adjustRateAction(_ sender: ALGreenControlKnob) {
        self.manager.adjustRate(rate: Float(sender.value))
    }
    
    @IBAction func adjustPanAction(_ sender: ALOrangeControlKnob) {
        self.manager.adjustPan(pan: Float(sender.value), forPlayerAtIndex: sender.tag)
    }
    
    @IBAction func adjustVolumeAction(_ sender: ALOrangeControlKnob) {
        self.manager.adjustVolume(volume: Float(sender.value), forPlayerAtIndex: sender.tag)
    }
    
}

//
extension ViewController: ALPlayerManagerDelegate {
    
    func playbackBegan() {
        self.playButton.isSelected = true
        self.playLabel.text = "Stop"
    }
    
    func playbackStopped() {
        self.playButton.isSelected = false
        self.playLabel.text = "Paly"
    }
    
    override var prefersStatusBarHidden: Bool {
         return true
    }
}
