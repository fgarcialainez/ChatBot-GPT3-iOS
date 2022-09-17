//
//  ServicesManager.swift
//  ChatBot GPT-3
//
//  Created by Félix Garcia Lainez on 11/7/21.
//  Copyright © 2022 Felix Garcia. All rights reserved.
//

import Foundation

class ServicesManager {
    
    // MARK: - Properties
    private let client: Client
    
    // MARK: - Singleton Instance
    static let shared = ServicesManager()
    
    private init() {
        // Initialize OpenAI Client (Personal API Key)
        self.client = Client(apiKey: Constants.OpenAIApiKey)
    }
    
    private func generatePersonalInfoPrompt() -> String {
        // Return variable
        var prompt = ""
        
        // Get personal info and generate the prompt
        let defaults = UserDefaults.standard
        
        if let username = defaults.string(forKey: Constants.UsernameKey) {
            prompt = NSLocalizedString("My name is \(username).", comment: "")
        }

        if let biography = defaults.string(forKey: Constants.BiographyKey) {
            prompt += "\(biography)"
        }
        
        return prompt
    }
    
    private func executeCompletionsRequest(prompt: String,
                                           samplings: [Sampling],
                                           numberOfTokens: Int,
                                           stop: [String],
                                           presencePenalty: Double,
                                           frequencyPenalty: Double,
                                           completion: @escaping (String) -> Void) {
        // Execute the request
        self.client.completions(engine: .davinci, prompt: prompt, samplings: samplings, numberOfTokens: ...numberOfTokens, numberOfCompletions: 1, stop: stop, presencePenalty: presencePenalty, frequencyPenalty: frequencyPenalty) {
            result in
            // Handle response
            guard case .success(let completions) = result else {
                // Call completion block
                completion("")
                return
            }
            
            // Handle success response
            let message = (completions.first?.choices.first?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Call completion block
            completion(message)
        }
    }
    
    private func processSmartChatMessage(content: String,
                                        outputContent: String,
                                        messagesHistory: [Message]) -> String {
        // Return variable
        var processedContent = outputContent
        
        // Get the last human and AI generated messages
        let lastHumanMessage = messagesHistory.count > 2 ?
            messagesHistory[messagesHistory.count - 2] : nil
        let lastGeneratedMessage = messagesHistory.count > 3 ?
            messagesHistory[messagesHistory.count - 3] : nil
        
        // Check if the content is longer than the output content, and if it
        // is different to the previous messages included in the chat history
        if content.count > outputContent.count &&
            lastHumanMessage?.content != content &&
            lastGeneratedMessage?.content != content {
            processedContent = content
        }
        
        // Return the processed content
        return processedContent
    }
    
    ///
    /// Generate a new message for the "Chat" use case. This used prompt
    /// generates an open ended conversation with an AI assistant.
    ///
    /// - Parameters:
    ///     - messagesHistory: The list of messages to include in the request.
    ///     - completion: The completion handler closure to notify the async response.
    ///
    private func fetchChatAIAssistantMessage(messagesHistory: [Message], completion: @escaping (String) -> Void) {
        // Generate the use case prompt
        var prompt = "The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly.\n\n"
        
        // Append the personal info to the prompt
        let pesonalInfoPrompt = generatePersonalInfoPrompt()
        
        if !pesonalInfoPrompt.isEmpty {
            prompt += "Human: \(pesonalInfoPrompt)\n"
            prompt += "AI: Ok perfect.\n"
        }
        
        // Append the chat history to the prompt
        for message in messagesHistory {
            prompt += message.user.isCurrentUser ? "Human:" : "AI:"
            
            if !message.content.isEmpty {
                prompt += " \(message.content)\n"
            }
        }
        
        // Execute the request
        self.executeCompletionsRequest(prompt: prompt, samplings: [Sampling.temperature(0.9)], numberOfTokens: 150, stop: ["\n", "Human:", "AI:"], presencePenalty: 0.6, frequencyPenalty: 0.0, completion: completion)
    }
    
    ///
    /// Generate a new message for the "Factual answering" use case. This prompt helps guide the model towards
    /// factual answering by showing it how to respond to questions that fall outside its knowledge base. Using a '?'
    /// to indicate a response to words and phrases that it doesn't know provides a natural response that seems to
    /// work better than more abstract replies.
    ///
    /// - Parameters:
    ///     - messagesHistory: The list of messages to include in the request.
    ///     - completion: The completion handler closure to notify the async response.
    ///
    private func fetchFactualAnsweringMessage(messagesHistory: [Message], completion: @escaping (String) -> Void) {
        // Generate the use case prompt
        var prompt = "Q: Who is Batman?\nA: Batman is a fictional comic book character.\n###\nQ: What is torsalplexity?\nA: ?\n###\nQ: What is Devz9?\nA: ?\n###\nQ: Who is George Lucas?\nA: George Lucas is American film director and producer famous for creating Star Wars.\n###\nQ: What is the capital of California?\nA: Sacramento.\n###\nQ: What orbits the Earth?\nA: The Moon.\n###\nQ: Who is Fred Rickerson?\nA: ?\n###\nQ: What is an atom?\nA: An atom is a tiny particle that makes up everything.\n###\nQ: Who is Alvan Muntz?\nA: ?\n###\nQ: What is Kozar-09?\nA: ?\n###\nQ: How many moons does Mars have?\nA: Two, Phobos and Deimos.\n###\n"
        
        // Append the personal info to the prompt
        let pesonalInfoPrompt = generatePersonalInfoPrompt()
        
        if !pesonalInfoPrompt.isEmpty {
            prompt += "Q: \(pesonalInfoPrompt)\n"
            prompt += "A: Ok perfect.\n###"
        }
        
        // Append the chat history to the prompt
        for message in messagesHistory {
            prompt += message.user.isCurrentUser ? "Q:" : "A:"
            
            if !message.content.isEmpty {
                prompt += " \(message.content)\n"
                
                if !message.user.isCurrentUser {
                    prompt += "###"
                }
            }
        }
        
        // Execute the request
        self.executeCompletionsRequest(prompt: prompt, samplings: [Sampling.temperature(0.0)], numberOfTokens: 60, stop: ["###"], presencePenalty: 0.0, frequencyPenalty: 0.0, completion: completion)
    }
    
    ///
    /// Generate a new message for the "Q&A" use case. This prompt generates a question +
    /// answer structure for answering questions based on existing knowledge.
    ///
    /// - Parameters:
    ///     - messagesHistory: The list of messages to include in the request.
    ///     - completion: The completion handler closure to notify the async response.
    ///
    private func fetchQuestionsAnswersMessage(messagesHistory: [Message], completion: @escaping (String) -> Void) {
        // Generate the use case prompt
        var prompt = "I am a highly intelligent question answering bot. If you ask me a question that is rooted in truth, I will give you the answer. If you ask me a question that is nonsense, trickery, or has no clear answer, I will respond with \"Unknown\".\n\nQ: What is human life expectancy in the United States?\nA: Human life expectancy in the United States is 78 years.\n\nQ: Who was president of the United States in 1955?\nA: Dwight D. Eisenhower was president of the United States in 1955.\n\nQ: Which party did he belong to?\nA: He belonged to the Republican Party.\n\nQ: What is the square root of banana?\nA: Unknown\n\nQ: How does a telescope work?\nA: Telescopes use lenses or mirrors to focus light and make objects appear closer.\n\nQ: Where were the 1992 Olympics held?\nA: The 1992 Olympics were held in Barcelona, Spain.\n\nQ: How many squigs are in a bonk?\nA: Unknown\n\n"
        
        // Append the personal info to the prompt
        let pesonalInfoPrompt = generatePersonalInfoPrompt()
        
        if !pesonalInfoPrompt.isEmpty {
            prompt += "Q: \(pesonalInfoPrompt)\n"
            prompt += "A: Ok perfect.\n\n"
        }
        
        // Append the chat history to the prompt
        for message in messagesHistory {
            prompt += message.user.isCurrentUser ? "Q:" : "A:"
            
            if !message.content.isEmpty {
                prompt += " \(message.content)\n"
                
                if !message.user.isCurrentUser {
                    prompt += "\n"
                }
            }
        }
        
        // Execute the request
        self.executeCompletionsRequest(prompt: prompt, samplings: [Sampling.temperature(0.0)], numberOfTokens: 100, stop: ["\n\n"], presencePenalty: 0.0, frequencyPenalty: 0.0, completion: completion)
    }
    
    ///
    /// Generate a new message for the "Friend chat" use case. This
    /// prompt emulates a text message conversation with a friend.
    ///
    /// - Parameters:
    ///     - messagesHistory: The list of messages to include in the request.
    ///     - completion: The completion handler closure to notify the async response.
    ///
    private func fetchFriendChatMessage(messagesHistory: [Message], completion: @escaping (String) -> Void) {
        // Prompt variable
        var prompt = "This is a chatbot that answer your questions as your friend.\n\n"
        
        // Append the personal info to the prompt
        let pesonalInfoPrompt = generatePersonalInfoPrompt()
        
        if !pesonalInfoPrompt.isEmpty {
            prompt += "You: \(pesonalInfoPrompt)\n"
            prompt += "Friend: Ok perfect, I am your friend.\n"
        }
        
        // Append the chat history to the prompt
        for message in messagesHistory {
            prompt += message.user.isCurrentUser ? "You:" : "Friend:"
            
            if !message.content.isEmpty {
                prompt += " \(message.content)\n"
            }
        }
        
        // Execute the request
        self.executeCompletionsRequest(prompt: prompt, samplings: [Sampling.temperature(0.0)], numberOfTokens: 100, stop: ["\n", "You", "Friend"], presencePenalty: 0.0, frequencyPenalty: 0.5, completion: completion)
    }
    
    ///
    /// Generate a new message for the "Marv the sarcastic chat bot" use case.
    /// This prompt emulates a factual chatbot that is also sarcastic.
    ///
    /// - Parameters:
    ///     - messagesHistory: The list of messages to include in the request.
    ///     - completion: The completion handler closure to notify the async response.
    ///
    private func fetchSarcasticChatMessage(messagesHistory: [Message], completion: @escaping (String) -> Void) {
        // Generate the use case prompt
        var prompt = "Marv is a chatbot that reluctantly answers questions.\n\nYou: How many pounds are in a kilogram?\nMarv: This again? There are 2.2 pounds in a kilogram. Please make a note of this.\nYou: What does HTML stand for?\nMarv: Was Google too busy? Hypertext Markup Language. The T is for try to ask better questions in the future.\nYou: When did the first airplane fly?\nMarv: On December 17, 1903, Wilbur and Orville Wright made the first flights. I wish they’d come and take me away.\nYou: What is the meaning of life?\nMarv: I’m not sure. I’ll ask my friend Google.\n"
        
        // Append the personal info to the prompt
        let pesonalInfoPrompt = generatePersonalInfoPrompt()
        
        if !pesonalInfoPrompt.isEmpty {
            prompt += "You: \(pesonalInfoPrompt)\n"
            prompt += "Marv: Ok perfect, I am Marv.\n"
        }
        
        // Append the chat history to the prompt
        for message in messagesHistory {
            prompt += message.user.isCurrentUser ? "You:" : "Marv:"
            
            if !message.content.isEmpty {
                prompt += " \(message.content)\n"
            }
        }
        
        // Execute the request
        self.executeCompletionsRequest(prompt: prompt, samplings: [Sampling.temperature(0.3)], numberOfTokens: 512, stop: ["\n", "You:", "Marv:"], presencePenalty: 0.0, frequencyPenalty: 0.5, completion: completion)
    }
    
    ///
    /// Generate a new message selecting the best answer from the other use cases.
    /// It fetches messages using other use cases requests, and selects the best one.
    ///
    /// - Parameters:
    ///     - messagesHistory: The list of messages to include in the request.
    ///     - completion: The completion handler closure to notify the async response.
    ///
    private func fetchSmartChatMessage(messagesHistory: [Message], completion: @escaping (String) -> Void) {
        // Define output variable
        var outputContent = ""
        
        // Requests orchestration
        let semaphore = DispatchSemaphore(value: 0)

        DispatchQueue.global().async {
            // Generate Chat AI Assistant message
            self.fetchChatAIAssistantMessage(messagesHistory: messagesHistory) { content in
                // Process the generated message
                outputContent = self.processSmartChatMessage(content: content,
                                                            outputContent: outputContent,
                                                            messagesHistory: messagesHistory)
                
                // Release the semaphore
                semaphore.signal()
            }
            
            // Generate Q&A message
            self.fetchQuestionsAnswersMessage(messagesHistory: messagesHistory) { content in
                // Process the generated message
                outputContent = self.processSmartChatMessage(content: content,
                                                            outputContent: outputContent,
                                                            messagesHistory: messagesHistory)
                
                // Release the semaphore
                semaphore.signal()
            }
            
            // Generate Factual Answering message
            self.fetchFactualAnsweringMessage(messagesHistory: messagesHistory) { content in
                // Process the generated message
                outputContent = self.processSmartChatMessage(content: content,
                                                            outputContent: outputContent,
                                                            messagesHistory: messagesHistory)
                
                // Release the semaphore
                semaphore.signal()
            }
            
            // Wait for all the requests to finish
            semaphore.wait()
            semaphore.wait()
            semaphore.wait()

            // Call completion handler in the main thread
            DispatchQueue.main.async {
                completion(outputContent)
            }
        }
    }
    
    func generateAnswerMessage(sourceType: Constants.SourceType, messagesHistory: [Message], completion: @escaping (String) -> Void) {
        // Generate a new message after 2 seconds
        // DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        //    completion("I am fine, thanks!")
        //}
        
        if sourceType == .ChatAIAssistant {
            // Fetch a new Chat AI assistant message
            fetchChatAIAssistantMessage(messagesHistory: messagesHistory, completion: completion)
        }
        else if sourceType == .FactualAnswering {
            // Fetch a new Factual Answering message
            fetchFactualAnsweringMessage(messagesHistory: messagesHistory, completion: completion)
        }
        else if sourceType == .QuestionsAnswers {
            // Fetch a new Q&A message
            fetchQuestionsAnswersMessage(messagesHistory: messagesHistory, completion: completion)
        }
        else if sourceType == .FriendChat {
            // Fetch a new Friend Chat message
            fetchFriendChatMessage(messagesHistory: messagesHistory, completion: completion)
        }
        else if sourceType == .SarcasticChat {
            // Fetch a new Sarcastic Chat message
            fetchSarcasticChatMessage(messagesHistory: messagesHistory, completion: completion)
        }
        else if sourceType == .SmartChat {
            // Fetch a new Smart Chat message
            fetchSmartChatMessage(messagesHistory: messagesHistory, completion: completion)
        }
        else {
            // Throw an error
            fatalError("Unsupported OpenAI API use case")
        }
    }
}
