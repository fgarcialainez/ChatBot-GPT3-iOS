//
//  ContentView.swift
//  ChatBot GPT-3
//
//  Created by Félix Garcia Lainez on 8/7/21.
//  Copyright © 2022 Felix Garcia. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                ChatView(.ChatAIAssistant)
            }
            .tabItem {
                Label(NSLocalizedString("Chat AI", comment: ""),
                      systemImage: "message")
            }
            NavigationView {
                ChatView(.FactualAnswering)
            }
            .tabItem {
                Label(NSLocalizedString("Factual Answering", comment: ""),
                      systemImage: "questionmark.circle")
            }
            /*
            NavigationView {
                ChatView(.QuestionsAnswers)
            }
            .tabItem {
                Label(NSLocalizedString("Q&A", comment: ""),
                      systemImage: "questionmark.square")
            }
            */
            NavigationView {
                ChatView(.FriendChat)
            }
            .tabItem {
                Label(NSLocalizedString("Friend Chat", comment: ""),
                      systemImage: "text.bubble")
            }
            NavigationView {
                ChatView(.SarcasticChat)
            }
            .tabItem {
                Label(NSLocalizedString("Sarcastic Chat", comment: ""),
                      systemImage: "face.smiling")
            }
            NavigationView {
                ChatView(.SmartChat)
            }
            .tabItem {
                Label(NSLocalizedString("Smart Chat", comment: ""),
                      systemImage: "wand.and.stars")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
