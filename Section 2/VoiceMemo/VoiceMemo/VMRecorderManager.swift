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

/// 录音单利类
class VMRecorderManager: NSObject {

    var delegate: VMRecorderManagerDelegate?
    
    /// 获取分贝数据模型
    var levels: VMLevelPair {
        self.recorder?.updateMeters()
        let avgPower =  self.recorder?.averagePower(forChannel: 0) ?? 0
        let peakPower = self.recorder?.peakPower(forChannel: 0) ?? 0
        let linearLevel = self.meterTable.valueForPower(avgPower)
        let linearPeak = self.meterTable.valueForPower(peakPower)
        return VMLevelPair(with: linearLevel, peakLevel: linearPeak)
    }
    
    /// 语音播放
    private var player: AVAudioPlayer?
    /// 语音录取
    private var recorder: AVAudioRecorder?
    /// 数据管理
    private lazy var meterTable: VMMeterTable = VMMeterTable()

    override init() {
        super.init()
        
        // 设置保存路径
        let tmpDir = NSTemporaryDirectory()
        let filePath = tmpDir + "memo.m4a"
        let fileURL = URL(fileURLWithPath: filePath)
        // 设置音频属性
        let settings: [String: Any] = [ AVFormatIDKey : kAudioFormatAppleLossless,
                                        AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                                        AVEncoderBitRateKey: 32000,
                                        AVNumberOfChannelsKey: 2,
                                        AVSampleRateKey: 44100.0]
//        print(fileURL)
        // 请求录音许可 并准备录音
        AVAudioSession.sharedInstance().requestRecordPermission { (result) in
            if result {
                DispatchQueue.main.async {
                    self.recorder = try? AVAudioRecorder(url: fileURL, settings: settings)
                    self.recorder?.delegate = self;
                    self.recorder?.isMeteringEnabled = true
                    self.recorder?.prepareToRecord()
                    
                }
            }
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            try AVAudioSession.sharedInstance().setActive(true, options: .init(rawValue: 0))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// 通过时间间隔转换为: 时:分:秒
    var formattedCurrentTime: String {

        let time = self.recorder?.currentTime ?? 0
        let hours = Int(time / 3600)
        let minutes = Int((time / 60).truncatingRemainder(dividingBy: 60))
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        let format = "%02d:%02d:%02d"
        return String(format: format, hours, minutes, seconds)
    }
    
    /// 开始录音
    /// Recorder methods
    func record() -> Bool {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] (granted) in
                DispatchQueue.main.async {
                    if granted {
                        self?.recorder?.record()
                    }
                }
            }
        case .denied:
            break
        case .granted:
            return self.recorder?.record() ?? false
        default:
            break
        }
        return self.recorder?.record() ?? false
    }
    
    /// 暂停
    func pause() {
        self.recorder?.pause()
    }
    
    /// 播放录音文件
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
    
    /// 停止录音
    func stopWithCompletionHandler(_ completed: @escaping ((Bool)->Void)) {
        self.recorder?.stop()
        completed(true)
    }
    
    /// 保存录音
    /// - Parameters:
    ///   - name: 名称
    ///   - completionHandler: 回调模型结果
    func saveRecordingWithName(_ name: String, completionHandler: @escaping ((Bool, VMMemoModel?)->Void)) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let filename = "/\(name)-\(formatter.string(from: Date())).m4a"
        
        guard let docsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }
        
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
        return powf(10.0, Float(0.05 * dB))
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
