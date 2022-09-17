//
//  Constants.swift
//  ChatBot GPT-3
//
//  Created by Félix Garcia Lainez on 11/7/21.
//  Copyright © 2022 Felix Garcia. All rights reserved.
//

import Foundation

struct Constants {
    // OpenAI Use Cases Definition
    enum SourceType {
        case ChatAIAssistant
        case FactualAnswering
        case QuestionsAnswers
        case FriendChat
        case SarcasticChat
        case SmartChat
    }
    
    // UserDefaults Keys
    static let UsernameKey = "USERNAME_KEY"
    static let BiographyKey = "BIOGRAPHY_KEY"
    
    // External Services
    static let AppCenterSecret = "REPLACE_BY_APP_CENTER_SECRET"
    static let OpenAIApiKey = "REPLACE_BY_OPEN_AI_API_KEY"
}
