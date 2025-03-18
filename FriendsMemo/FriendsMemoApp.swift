//
//  FriendsMemoApp.swift
//  FriendsMemo
//
//  Created by Gizem Coskun on 27/02/25.
//

import SwiftUI

//@main
//struct FriendsMemoApp: App {
//    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
//
//    var body: some Scene {
//        WindowGroup {
//            if hasSeenOnboarding {
//                FriendsView()
//            } else {
//                OnboardingView()
//            }
//        }
//    }
//}

@main
struct FriendsMemoApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var showSplash: Bool = true
    
    init() {
        // Initialize the app's language based on user preference
        Bundle.initializeLanguage()
    }
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                FriendsView()
                    .environment(\.locale, .init(identifier: L10n.currentLanguage))
            } else {
                OnboardingView()
                    .environment(\.locale, .init(identifier: L10n.currentLanguage))
            }
        }
    }
}
