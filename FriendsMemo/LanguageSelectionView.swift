//
//  LanguageSelectionView.swift
//  FriendsMemo
//
//  Created by Gizem Coskun on 18/03/25.
//


import SwiftUI

struct LanguageSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLanguage = L10n.currentLanguage
    @State private var needsRestart = false
    
    private let backgroundColor = Color(red: 0.93, green: 0.91, blue: 0.88)
    private let textColor = Color(red: 0.25, green: 0.25, blue: 0.25)
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text("Language Settings")
                        .font(.system(size: 20, weight: .medium))
                        .kerning(1)
                        .foregroundColor(textColor)
                        .padding(.top, 20)
                    
                    // Language selection list
                    List {
                        ForEach(L10n.availableLanguages, id: \.code) { language in
                            Button(action: {
                                selectedLanguage = language.code
                            }) {
                                HStack {
                                    Text(language.name)
                                        .foregroundColor(textColor)
                                    
                                    Spacer()
                                    
                                    if selectedLanguage == language.code {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .listRowBackground(backgroundColor)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    
                    Button(action: {
                        // Save the language selection
                        if L10n.currentLanguage != selectedLanguage {
                            L10n.currentLanguage = selectedLanguage
                            needsRestart = true
                        }
                    }) {
                        Text("Save")
                            .font(.system(size: 14, weight: .medium))
                            .kerning(1)
                            .foregroundColor(.white)
                            .frame(width: 200)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(4)
                    }
                    .padding(.bottom, 20)
                }
                .navigationBarItems(trailing: 
                    Button("Close") {
                        dismiss()
                    }
                )
                .alert(isPresented: $needsRestart) {
                    Alert(
                        title: Text("Language Changed"),
                        message: Text("Please restart the app for the language change to take full effect."),
                        dismissButton: .default(Text("OK")) {
                            dismiss()
                        }
                    )
                }
            }
        }
    }
}

// Add a settings button to your FriendsView or other appropriate place
struct SettingsButton: View {
    @Binding var showLanguageSettings: Bool
    
    var body: some View {
        Button(action: {
            showLanguageSettings = true
        }) {
            Image(systemName: "gear")
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
        }
        .sheet(isPresented: $showLanguageSettings) {
            LanguageSelectionView()
        }
    }
}