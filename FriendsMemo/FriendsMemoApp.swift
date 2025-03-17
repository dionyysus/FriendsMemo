//
//  FriendsMemoApp.swift
//  FriendsMemo
//
//  Created by Gizem Coskun on 27/02/25.
//

import SwiftUI

@main
struct FriendsMemoApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                FriendsView()
            } else {
                OnboardingView()
            }
        }
    }
}
