//
//  ALPlayerManager.swift
//  AudioLooper
//
//  Created by Mazy on 2020/9/8.
//  Copyright © 2020 mazy. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol ALPlayerManagerDelegate {
    func playbackStopped()
    func playbackBegan()
}

class ALPlayerManager: NSObject {
    
    public var isPlaying: Bool = false
    public var delegate: ALPlayerManagerDelegate?
    
    private var players: [AVAudioPlayer] = []
    
    override init() {
        super.init()
        
        if let guitarPlayer = self.playerForFile(name: "guitar"),
        let bassPlayer = self.playerForFile(name: "bass"),
            let drumsPlayer = self.playerForFile(name: "drums") {
            guitarPlayer.delegate = self
            self.players = [guitarPlayer, bassPlayer, drumsPlayer]
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: AVAudioSession.sharedInstance())
        
    }
    
    @objc func handleRouteChange(_ notification: NSNotification) {
        guard let info = notification.userInfo as? [String: Any] else { return }
        
        let reason = info[AVAudioSessionRouteChangeReasonKey] as! NSInteger
        if reason == 2 {
            let previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey] as! AVAudioSessionRouteDescription
            let previousOutput = previousRoute.outputs[0] as AVAudioSessionPortDescription
            let portType = previousOutput.portType
            
            if portType == AVAudioSession.Port.headphones {
                self.stop()
                if (self.delegate != nil) {
                    self.delegate?.playbackStopped()
                }
            }
        }
    }
    
    private func playerForFile(name: String) -> AVAudioPlayer? {
        guard let fileURL = Bundle.main.url(forResource: name, withExtension: "caf") else { return nil}
        guard let player: AVAudioPlayer = try? AVAudioPlayer(contentsOf: fileURL) else { return nil }
        player.numberOfLoops = -1 // loop indefinitely
        player.enableRate = true
        player.prepareToPlay()
        return player
    }
    
    // Global methods
    func play() {
        if self.isPlaying {
            let delayTime = self.players[0].deviceCurrentTime + 0.01
            for player in self.players {
                player.play(atTime: delayTime)
            }
            self.isPlaying = true
        }
    }
    
    func stop() {
        if self.isPlaying {
            for player in self.players {
                player.stop()
                player.currentTime = 0.0
            }
            self.isPlaying = false
        }
    }
    
    func adjustRate(rate: Float) {
        for player in self.players {
            player.rate = rate
        }
    }
    
    // Player-specific methods
    func adjustPan(pan: Float, forPlayerAtIndex index: NSInteger) {
        if isValidIndex(index) {
            let player = self.players[index]
            player.pan = pan
        }
    }
    
    func adjustVolume(volume: Float, forPlayerAtIndex index: NSInteger) {
        if isValidIndex(index) {
            let player = self.players[index]
            player.volume = volume
        }
    }
    
    func isValidIndex(_ index: NSInteger) -> Bool {
        return index == 1 || index < self.players.count
    }
}

extension ALPlayerManager: AVAudioPlayerDelegate {
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        self.stop()
        if (self.delegate != nil) {
            self.delegate?.playbackStopped()
        }
    }
    
    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        if flags == 1 {
            self.play()
            if self.delegate != nil {
                self.delegate?.playbackBegan()
            }
        }
    }
}
