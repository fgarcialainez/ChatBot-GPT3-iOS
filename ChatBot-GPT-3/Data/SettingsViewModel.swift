//
//  SettingsViewModel.swift
//  ChatBot GPT-3
//
//  Created by Félix Garcia Lainez on 3/2/22.
//  Copyright © 2022 Felix Garcia. All rights reserved.
//

import Foundation

class SettingsViewModel: ObservableObject {
    @Published var username: String
    @Published var biography: String
    @Published var ttsEnabled: Bool
    
    init() {
        self.username = UserDefaults.standard.object(forKey: Constants.UsernameKey) as? String ?? ""
        self.biography = UserDefaults.standard.object(forKey: Constants.BiographyKey) as? String ?? ""
        self.ttsEnabled = TextToSpeechManager.shared.enabled
    }
    
    func save() {
        // Save data in UserDefaults
        let defaults = UserDefaults.standard
        
        defaults.set(self.username, forKey: Constants.UsernameKey)
        defaults.set(self.biography, forKey: Constants.BiographyKey)
        
        // Update TTS activation status
        TextToSpeechManager.shared.enabled = self.ttsEnabled
    }
}
