//
//  VMRecorderManager.swift
//  VoiceMemo
//
//  Created by Mazy on 2020/9/9.
//  Copyright © 2020 mazy. All rights reserved.
//

import UIKit
import AVFoundation

protocol VMRecorderManagerDelegate {
    func interruptionBegan()
}

class VMRecorderManager: NSObject {

    var delegate: VMRecorderManagerDelegate?
    public var completionHandler: ((Bool)->Void)?
    
    lazy var levels: VMLevelPair = {
        self.recorder?.updateMeters()
        let avgPower =  self.recorder?.averagePower(forChannel: 0) ?? 0
        let peakPower = self.recorder?.peakPower(forChannel: 0) ?? 0
        let linearLevel = self.meterTable.valueForPower(avgPower)
        let linearPeak = self.meterTable.valueForPower(peakPower)
        return VMLevelPair(with: linearLevel, peakLevel: linearPeak)
    }()
    
    private var player: AVAudioPlayer?
    private var recorder: AVAudioRecorder?
    private lazy var meterTable: VMMeterTable = VMMeterTable()
    
    override init() {
        super.init()
        
        let tmpDir = NSTemporaryDirectory()
        let filePath = tmpDir + "memo.caf"
        let fileURL = URL(fileURLWithPath: filePath)

        let settings: [String: Any] = [ AVFormatIDKey : kAudioFormatAppleIMA4,
                         AVSampleRateKey : 44100.0,
                         AVNumberOfChannelsKey : 1,
                         AVEncoderBitDepthHintKey : 16,
                         AVEncoderAudioQualityKey : AVAudioQuality.medium
                            ]

        self.recorder = try? AVAudioRecorder(url: fileURL, settings: settings)
        self.recorder?.delegate = self;
        self.recorder?.isMeteringEnabled = true
        self.recorder?.prepareToRecord()
    }
    
    var formattedCurrentTime: String {

        let time = self.recorder?.currentTime ?? 0
        let hours = (time / 3600)
        let minutes = (time / 60).truncatingRemainder(dividingBy: 60)
        let seconds = time.truncatingRemainder(dividingBy: 60)
        let format = "%02i:%02i:%02i"
        return String(format: format, hours, minutes, seconds)
    }
    
    // Recorder methods
    func record() -> Bool {
        return self.recorder?.record() ?? false
    }
    
    func pause() {
        self.recorder?.pause()
    }
    
    // Player methods
    func playbackMemo(_ memo: VMMemoModel) -> Bool {
        self.player?.stop()
        guard let url = memo.url else {
            return false
        }
        self.player = try? AVAudioPlayer(contentsOf: url)
        if let palyer = self.player {
            palyer.play()
            return true
        }
        return false
    }
    
    func stopWithCompletionHandler(_ completed: @escaping ((Bool)->Void)) {
        self.completionHandler = completed
        self.recorder?.stop()
    }
    
    func saveRecordingWithName(_ name: String, completionHandler: @escaping ((Bool, VMMemoModel?)->Void)) {
        
        let timestamp = Date.timeIntervalSinceReferenceDate
        let filename = "\(name)-\(timestamp).m4a"
        
        guard let docsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }
        // MARK -
        let destPath = docsDir.appending(filename)

        guard let srcURL = self.recorder?.url else { return }
        let destURL = URL(fileURLWithPath: destPath)

        do {
            try FileManager.default.copyItem(at: srcURL, to: destURL)
            completionHandler(true, VMMemoModel(title: name, url: destURL))
        } catch {
            completionHandler(false, nil)
        }
    }
}

// AVAudioRecorderDelegate
extension VMRecorderManager: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
    }
    
    func audioRecorderBeginInterruption(_ recorder: AVAudioRecorder) {
        if (self.delegate != nil) {
            self.delegate?.interruptionBegan()
        }
    }
}


class VMMeterTable: NSObject {
    
    var MIN_DB: Float = -60.0
    var TABLE_SIZE: Int = 300
    
    var scaleFactor: Float = 0
    var meterTable: [Float] = []
    
    override init() {
        super.init()
        let dbResolution = MIN_DB / Float(TABLE_SIZE - 1)
        scaleFactor = 1.0 / dbResolution
        
        let minAmp = dbToAmp(MIN_DB)
        let ampRange = 1.0 - minAmp
        let invAmpRange = 1.0 / ampRange
        
        for i in 0..<TABLE_SIZE {
            let decibels = Float(i) * dbResolution
            let amp = dbToAmp(decibels)
            let adjAmp = (amp - minAmp) * invAmpRange
            meterTable.append(adjAmp)
        }
    }
    
    func dbToAmp(_ dB: Float) -> Float {
        return powf(10.0, Float(5.0 * dB))
    }
    
    func valueForPower(_ power: Float) -> Float {
        if power < MIN_DB {
            return 0.0
        } else if power > 0 {
            return 1.0
        } else {
            let index = Int(power * scaleFactor)
            return Float(meterTable[index])
        }
    }
    
}
