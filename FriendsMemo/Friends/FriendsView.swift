//
//  ContentView.swift
//  FriendsMemo
//
//  Created by Gizem Coskun on 27/02/25.
//

import SwiftUI

struct FriendsView: View {

    private let iconName = "person.circle"
    private let iconColor: Color = .black
    private let numberOfFriends = 9
    
    @State private var isAddFriendModalPresented = false

    var body: some View {
        NavigationView {
            VStack {
                FriendsGrid(iconName: iconName, iconColor: iconColor, count: numberOfFriends)
                    .padding(.horizontal)
                Spacer()
            }
            .navigationTitle("Friends")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isAddFriendModalPresented.toggle()
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(iconColor)
                    }
                }
            }
            .sheet(isPresented: $isAddFriendModalPresented) {
                AddFriendView()
            }
        }
    }
}

struct FriendsGrid: View {
    let iconName: String
    let iconColor: Color
    let count: Int
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 15) {
            ForEach(0..<count, id: \.self) { _ in
                FriendCircle(iconName: iconName, color: iconColor)
            }
        }
    }
}

struct FriendCircle: View {
    let iconName: String
    let color: Color

    var body: some View {
        Image(systemName: iconName)
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
            .foregroundColor(color)
            .background(Circle().fill(color.opacity(0.2)))
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .shadow(radius: 3)
    }
}

struct AddFriendView: View {
    var body: some View {
        VStack {
            Text("Add a New Friend")
                .font(.largeTitle)
                .padding()
            Spacer()
            Button("Close") {
            }
            .padding()
            .background(Capsule().fill(Color.blue))
            .foregroundColor(.white)
        }
        .padding()
        .navigationTitle("Add Friend")
    }
}

// MARK: - Preview
struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView()
    }
}
