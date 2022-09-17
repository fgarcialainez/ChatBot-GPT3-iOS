//
//  ChatView.swift
//  ChatBot GPT-3
//
//  Created by Félix Garcia Lainez on 9/7/21.
//  Copyright © 2022 Felix Garcia. All rights reserved.
//

import SwiftUI

struct ChatView: View {
    
    // MARK: - Properties
    @State var typingMessage: String = ""
    @State var settingsLinkActive = false
    @State var showOptionsActionSheet = false
    @State var showConfirmationDialog = false
    
    @ObservedObject var model: MessagesListViewModel
    @ObservedObject var keyboard = KeyboardResponder()
    
    init(_ sourceType: Constants.SourceType) {
        // Initialize model
        self.model = MessagesListViewModel(sourceType: sourceType)
    }
    
    var body: some View {
        VStack {
            // Problem on hidding separators in iOS 14
            /*
            List {
                ForEach(model.messages, id: \.self) { msg in
                    MessageView(message: msg)
                }
            }
            .listSeparatorStyleNone()
            */
            
            // Same behaviour than List component
            ScrollViewReader { value in
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(self.model.messages, id: \.self) { msg in
                            MessageView(message: msg)
                                .padding(EdgeInsets(top: 10, leading: 15, bottom: 0, trailing: 15))
                                .id(self.model.messages.firstIndex(of: msg))
                        }
                    }
                }
                .onChange(of: self.model.messages.count) { count in
                    withAnimation {
                        // Scroll to last item in the list passing the ID
                        value.scrollTo(count - 1, anchor: .bottom)
                    }
                }
            }
            
            // Bottom actions toolbar
            VStack(spacing: 0) {
                Divider()
                HStack {
                    TextField(NSLocalizedString("Message...", comment: ""), text: self.$typingMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(height: CGFloat(30))
                    Button(action: self.sendMessage) {
                        Image(systemName: "paperplane").imageScale(.large)
                    }
                }
                .frame(height: CGFloat(30)).padding()
                .background(Color(UIColor.secondarySystemBackground))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(NSLocalizedString("ChatBot GPT-3", comment: "")).bold()
            }
        }
        .navigationBarItems(
            leading:
                Button(action: {
                }, label: {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .imageScale(.large)
                     }
                }),
            trailing:
                Button(action: {
                    // Show options action sheet
                    self.showOptionsActionSheet = true
                }) {
                    Image(systemName: "ellipsis.circle").imageScale(.large)
                }
        )
        .actionSheet(isPresented: $showOptionsActionSheet) {
            ActionSheet(
                title: Text(NSLocalizedString("Conversation Options", comment: "")),
                buttons: [
                    .default(Text(NSLocalizedString("Share", comment: ""))) {
                        // Show standard share dialog
                        shareConversation()
                    },
                    .destructive(Text(NSLocalizedString("Restart", comment: ""))) {
                        // Show confirmation dialog
                        self.showConfirmationDialog = true
                    },
                    .cancel(Text(NSLocalizedString("Cancel", comment: ""))) {
                        // Do nothing
                    }
                ]
            )
        }
        .alert(isPresented: self.$showConfirmationDialog, content: {
            Alert(
                title: Text(NSLocalizedString("Warning", comment: "")),
                message: Text(NSLocalizedString("Are you sure you want to restart this conversation?", comment: "")),
                primaryButton: .destructive(Text(NSLocalizedString("Yes", comment: ""))) {
                    // Restart the conversation
                    self.model.clearMessages()
                },
                secondaryButton: .cancel()
            )
        })
        .padding(.bottom, self.keyboard.currentHeight)
        .edgesIgnoringSafeArea(self.keyboard.currentHeight == 0.0 ? .leading: .bottom)
        .background(Color(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, opacity: 1.0))
        .onTapGesture {
            endEditing(true)
        }
    }
    
    func endEditing(_ force: Bool) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        windowScene?.windows.forEach { $0.endEditing(force)}
    }
    
    func shareConversation() {
        // Define output variable
        var outputText = ""
        
        // Set header
        switch model.sourceType {
        case .ChatAIAssistant:
            outputText = NSLocalizedString("Chat AI Assistant", comment: "")
        case .FactualAnswering:
            outputText = NSLocalizedString("Factual Answering", comment: "")
        case .QuestionsAnswers:
            outputText = NSLocalizedString("Questions & Answers", comment: "")
        case .FriendChat:
            outputText = NSLocalizedString("Friend Chat", comment: "")
        case .SarcasticChat:
            outputText = NSLocalizedString("Sarcastic Chat", comment: "")
        case .SmartChat:
            outputText = NSLocalizedString("Smart Chat", comment: "")
        }
        
        outputText += "\n\n"
        
        // Iterate over all the messages
        for message in model.messages {
            outputText += message.user.isCurrentUser ? "You:" : "AI:"
            
            if !message.content.isEmpty {
                outputText += " \(message.content)\n"
            }
        }
        
        // Show the share dialog
        let activityItems = [outputText]
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        windowScene?.windows.first?.rootViewController!.present(activityController, animated: true, completion: nil)
    }
    
    func sendMessage() {
        // Send the message
        if !self.typingMessage.isEmpty {
            self.model.sendMessage(self.typingMessage)
        }
        
        // Reset state
        self.typingMessage = ""
        
        // Call end editing method
        endEditing(true)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(.ChatAIAssistant)
    }
}
