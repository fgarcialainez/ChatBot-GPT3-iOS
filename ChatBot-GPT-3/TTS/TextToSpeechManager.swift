//
//  TextToSpeechManager.swift
//  ChatBot GPT-3
//
//  Created by Félix Garcia Lainez on 13/7/21.
//  Copyright © 2022 Felix Garcia. All rights reserved.
//

import AVFoundation

class TextToSpeechManager {

    // MARK: - Properties

    var enabled = false
    
    private let voice: AVSpeechSynthesisVoice?
    private let synthesizer: AVSpeechSynthesizer
    
    // MARK: - Singleton Instance

    static let shared = TextToSpeechManager()
    
    private init() {
        // Create a speech synthesizer
        self.synthesizer = AVSpeechSynthesizer()
        
        // Retrieve the US English voice
        self.voice = AVSpeechSynthesisVoice(language: "en-US")
    }
    
    func speak(string: String) {
        // Create an utterance
        let utterance = AVSpeechUtterance(string: string)

        // Configure the utterance
        utterance.volume = 0.8
        
        // Assign the voice to the utterance.
        utterance.voice = self.voice
        
        // Tell the synthesizer to speak the utterance
        self.synthesizer.speak(utterance)
    }
}
