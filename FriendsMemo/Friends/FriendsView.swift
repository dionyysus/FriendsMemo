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
    
    @State private var isAddFriendModalPresented = false
    @State private var friends: [Friend] = []  // Eklenen arkadaşları saklayan liste
    
    var body: some View {
        NavigationView {
            VStack {
                FriendsGrid(friends: friends)  // Arkadaşları listeleyen grid
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
                AddNewFriendView { newFriend in
                    friends.append(newFriend)  // Yeni arkadaşı listeye ekliyoruz
                }
            }
        }
    }
}

// Arkadaşları gösteren Grid View
struct FriendsGrid: View {
    let friends: [Friend]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 15) {
            ForEach(friends) { friend in
                FriendCircle(friend: friend)
            }
        }
    }
}

struct FriendCircle: View {
    let friend: Friend

    var body: some View {
        VStack {
            if let image = friend.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 3)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
                    .background(Circle().fill(Color.gray.opacity(0.2)))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 3)
            }
            
            Text(friend.name)  // İsmi aşağıya yazdırıyoruz
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.black)
                .frame(maxWidth: 80)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
}

// MARK: - Preview
struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView()
    }
}
