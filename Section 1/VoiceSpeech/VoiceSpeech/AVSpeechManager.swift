//
//  AVSpeechManager.swift
//  VoiceSpeech
//
//  Created by Mazy on 2020/9/6.
//  Copyright © 2020 mazy. All rights reserved.
//

import UIKit
import AVFoundation

class AVSpeechManager: NSObject {

    public lazy var synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    private var voices: [AVSpeechSynthesisVoice?] = []
    private var speechStrings: [String] = []
    
    // 通过 static let 创建单例
//    static let shared = AVSpeechManager()
    // 构造函数，init前加private修饰,表示原始构造方法只能自己使用，外界不发调用
    override init() {
        super.init()
        self.voices = [AVSpeechSynthesisVoice(language: "en-US"), AVSpeechSynthesisVoice(language: "en-GB")]
        self.speechStrings = self.buildSpeechStrings()
    }
    
    func beginConversation() {
        for (index, message) in self.speechStrings.enumerated() {
            let utterance = AVSpeechUtterance(string: message)
            utterance.voice = self.voices[index % 2]
            utterance.rate = 0.5
            utterance.pitchMultiplier = 0.8
            utterance.postUtteranceDelay = 0.1
            self.synthesizer.speak(utterance)
        }
    }
    
    func buildSpeechStrings() -> [String] {
        return ["Hello AV Foundation. How are you?",
        "I'm well! Thanks for asking.",
        "Are you excited about the book?",
        "Very! I have always felt so misunderstood.",
        "What's your favorite feature?",
        "Oh, they're all my babies.  I couldn't possibly choose.",
        "It was great to speak with you!",
        "The pleasure was all mine!  Have fun!"]
    }
    
}
