//
//  List+Separator.swift
//  ChatBot GPT-3
//
//  Created by Félix Garcia Lainez on 9/7/21.
//  Copyright © 2022 Felix Garcia. All rights reserved.
//

import SwiftUI

extension List {
    @ViewBuilder func listSeparatorStyleNone() -> some View {
        #if swift(>=5.3) // Xcode 12
        if #available(iOS 14.0, *) { // iOS 14
            self.accentColor(Color.secondary)
                .listStyle(SidebarListStyle())
                .onAppear {
                    UITableView.appearance().separatorColor = .clear
                    UITableView.appearance().separatorStyle = .none
                    UITableView.appearance().allowsSelection = false
                    UITableView.appearance().backgroundColor = UIColor.systemBackground
                }
        } else { // iOS 13
            self.listStyle(PlainListStyle())
                .onAppear {
                    UITableView.appearance().separatorStyle = .none
                }
        }
        #else // Xcode 11.5
        self
        .listStyle(PlainListStyle())
        .onAppear {
            UITableView.appearance().separatorStyle = .none
        }
        #endif
    }
}
