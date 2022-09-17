//
//  SettingsView.swift
//  ChatBot GPT-3
//
//  Created by Félix Garcia Lainez on 22/7/21.
//  Copyright © 2022 Felix Garcia. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - Properties

    @ObservedObject var model = SettingsViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            Section(header: Text(NSLocalizedString("Profile", comment: ""))) {
                TextField(NSLocalizedString("Username", comment: ""), text: $model.username)
            }
            Section(header: Text(NSLocalizedString("Biography", comment: ""))) {
                TextEditor(text: $model.biography)
                    .frame(minHeight: 100, alignment: .leading)
            }
            Section(header: Text(NSLocalizedString("Text to Speech", comment: ""))) {
                Toggle(NSLocalizedString("Activate", comment: ""), isOn: $model.ttsEnabled)
            }
            Section {
                HStack {
                    Spacer()
                    Button("Save") {
                        // Save data
                        model.save()
                        
                        // Dismiss the view
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    Spacer()
                }
            }
        }
        .navigationBarTitle(NSLocalizedString("Settings", comment: ""))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
