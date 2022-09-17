//
//  MessageTextView.swift
//  ChatBot GPT-3
//
//  Created by Félix Garcia Lainez on 9/7/21.
//  Copyright © 2022 Felix Garcia. All rights reserved.
//

import SwiftUI

struct MessageTextView: View {
    var message: String
    var isCurrentUser: Bool
    
    var body: some View {
        if message.isEmpty && !isCurrentUser {
            Text(NSLocalizedString("Typing...", comment: ""))
                .padding(10)
                .foregroundColor(Color.gray)
                .background(Color(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)))
                .cornerRadius(10)
                .font(.body.italic())
        }
        else {
            Text(message)
                .padding(10)
                .foregroundColor(isCurrentUser ? Color.white : Color.black)
                .background(isCurrentUser ? Color.blue : Color(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)))
                .cornerRadius(10)
        }
    }
}

struct MessageTextView_Previews: PreviewProvider {
    static var previews: some View {
        MessageTextView(message: "Hi, testing MessageTextView component!", isCurrentUser: false)
    }
}
