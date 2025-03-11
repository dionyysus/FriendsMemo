//
//  FriendsMemoApp.swift
//  FriendsMemo
//
//  Created by Gizem Coskun on 27/02/25.
//

import SwiftUI

@main
struct FriendsMemoApp: App {
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreenView(showSplash: $showSplash)
            } else {
                FriendsView()
            }
        }
    }
}
