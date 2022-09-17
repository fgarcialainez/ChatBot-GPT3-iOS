//
//  MockMessages.swift
//  ChatBot GPT-3
//
//  Created by Félix Garcia Lainez on 9/7/21.
//  Copyright © 2022 Felix Garcia. All rights reserved.
//

import Foundation

struct MockMessages {
    static let botUser = User(name: "Bot", avatar: "ChatBotAvatar")
    static var felixUser = User(name: "Felix", avatar: "FelixAvatar", isCurrentUser: true)

    static let messages = [
        Message(user: MockMessages.felixUser, content: NSLocalizedString("Hi my friend, how are you?", comment: "")),
        Message(user: MockMessages.botUser, content: NSLocalizedString("Very well, thanks! What about you?", comment: "")),
        Message(user: MockMessages.felixUser, content: NSLocalizedString("Very well too! Glad to talk to you here.", comment: "")),
        Message(user: MockMessages.botUser, content: NSLocalizedString("Likewise 😇 :)", comment: ""))
    ]
}
