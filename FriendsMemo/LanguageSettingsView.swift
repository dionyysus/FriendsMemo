//
//  LanguageSettingsView.swift
//  FriendsMemo
//
//  Created by Gizem Coskun on 18/03/25.
//


import SwiftUI

struct LanguageSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var languageManager = LanguageManager.shared
    @State private var selectedLanguage: String
    @State private var showRestartAlert = false
    
    init() {
        _selectedLanguage = State(initialValue: LanguageManager.shared.currentLanguage)
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(LanguageManager.availableLanguages, id: \.0) { languageCode, languageName in
                    Button(action: {
                        selectedLanguage = languageCode
                    }) {
                        HStack {
                            Text(languageName)
                            Spacer()
                            if selectedLanguage == languageCode {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle(Text(LocalizedStringKey("Language")))
            .navigationBarItems(leading: Button(LocalizedStringKey("Cancel")) {
                dismiss()
            }, trailing: Button(LocalizedStringKey("Save")) {
                if languageManager.currentLanguage != selectedLanguage {
                    languageManager.changeLanguage(selectedLanguage)
                    showRestartAlert = true
                } else {
                    dismiss()
                }
            })
            .alert(isPresented: $showRestartAlert) {
                Alert(
                    title: Text(LocalizedStringKey("Language Changed")),
                    message: Text(LocalizedStringKey("Please restart the app for the changes to take effect.")),
                    dismissButton: .default(Text(LocalizedStringKey("OK"))) {
                        dismiss()
                    }
                )
            }
        }
    }
}