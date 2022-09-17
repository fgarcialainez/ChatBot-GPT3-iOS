//
//  Message.swift
//  ChatBot GPT-3
//
//  Created by Félix Garcia Lainez on 9/7/21.
//  Copyright © 2022 Felix Garcia. All rights reserved.
//

import Foundation

struct Message: Hashable {
    var user: User
    var content: String
}
