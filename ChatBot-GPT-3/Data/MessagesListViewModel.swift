//
//  MessagesListViewModel.swift
//  ChatBot GPT-3
//
//  Created by Félix Garcia Lainez on 9/7/21.
//  Copyright © 2022 Felix Garcia. All rights reserved.
//

import Combine
import Foundation

class MessagesListViewModel: ObservableObject {
    
    // MARK: - Properties
    
    var sourceType: Constants.SourceType

    @Published var messages = [Message]()
    
    // MARK: - Initializer
    
    init(sourceType: Constants.SourceType, mock: Bool = false) {
        // Initialize properties
        self.sourceType = sourceType
        
        // Initialize the messages array with mock messages
        if mock {
            self.messages.append(contentsOf: MockMessages.messages)
        }
    }
    
    // MARK: - Private Methods
    
    private func generateAnswerMessage() {
        // Create a new pending message
        let waitingMessage = Message(user: MockMessages.botUser, content: "")
        
        // Append the waiting message to the list
        self.messages.append(waitingMessage)
        
        // Call GPT-3 API to get the new messages depending on the source type
        ServicesManager.shared.generateAnswerMessage(sourceType: self.sourceType, messagesHistory: self.messages) { content in
            // Process message content
            let messageContent = !content.isEmpty ? content :
                NSLocalizedString("I didn't understand you, sorry. Please try again.", comment: "")
            
            // Create a new message object
            let message = Message(user: MockMessages.botUser, content: messageContent)

            // Remove the pending message and add the new one
            self.messages.removeLast()
            self.messages.append(message)
            
            // Perform TTS
            if TextToSpeechManager.shared.enabled {
                TextToSpeechManager.shared.speak(string: messageContent)
            }
            
            // Notify the observers
            self.objectWillChange.send()
        }
    }
    
    // MARK: - Public Methods
    
    func clearMessages() {
        // Clear messages
        self.messages.removeAll()
    }
    
    func sendMessage(_ content: String) {
        // Create the messsage object
        let message = Message(user: MockMessages.felixUser, content: content)
        
        // Append the message to the list
        self.messages.append(message)
        
        // Generate answer message using OpenAI
        generateAnswerMessage()
    }
}
