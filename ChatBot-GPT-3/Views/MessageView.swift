//
//  MessageView.swift
//  ChatBot GPT-3
//
//  Created by Félix Garcia Lainez on 9/7/21.
//  Copyright © 2022 Felix Garcia. All rights reserved.
//

import SwiftUI

struct MessageView : View {
    var message: Message
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 15) {
            if !message.user.isCurrentUser {
                Image(message.user.avatar)
                    .resizable()
                    .frame(width: 40, height: 40, alignment: .center)
                    .cornerRadius(20)
            } else {
                Spacer()
            }
            
            // Create the message view
            MessageTextView(message: message.content,
                            isCurrentUser: message.user.isCurrentUser)
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(message: Message(user: MockMessages.botUser, content: "Hi, testing MessageView component!"))
    }
}
