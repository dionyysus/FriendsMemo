//
//  ContentView.swift
//  FriendsMemo
//
//  Created by Gizem Coskun on 27/02/25.
//


import SwiftUI

struct FriendsView: View {
    @State private var isAddFriendModalPresented = false
    @State private var friends: [Friend] = []
    
    var body: some View {
        NavigationView {
            VStack {
                if friends.isEmpty {
                    EmptyStateView()
                } else {
                    FriendsGrid(friends: friends)
                        .padding(.horizontal)
                }
                Spacer()
            }
            .navigationTitle("Friends")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isAddFriendModalPresented.toggle() }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                }
            }
            .sheet(isPresented: $isAddFriendModalPresented) {
                AddNewFriendView { newFriend in
                    friends.append(newFriend)
                }
            }
        }
    }
}


//struct FriendDetailView: View {
//    let friend: Friend
//    @State private var memories: [String] = ["İlk tanışmamız 🥰", "Birlikte en güzel gün!", "Unutulmaz tatil anımız"]
//    @State private var newMemory: String = ""
//
//    var body: some View {
//        VStack {
//            Text(friend.name)
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .padding(.top)
//
//            if memories.isEmpty {
//                EmptyMemoriesView()
//            } else {
//                TabView {
//                    ForEach(memories, id: \.self) { memory in
//                        MemoryPage(memory: memory)
//                    }
//                }
//                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
//                .frame(height: 300)
//                .padding()
//            }
//
//            AddMemoryView(newMemory: $newMemory, memories: $memories)
//        }
//        .navigationTitle("Memories of \(friend.name)")
//        .padding()
//    }
//}
//
//struct MemoryPage: View {
//    let memory: String
//
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 15)
//                .fill(Color.white)
//                .shadow(radius: 5)
//                .padding()
//            
//            Text(memory)
//                .font(.title2)
//                .multilineTextAlignment(.center)
//                .padding()
//        }
//        .frame(width: 300, height: 200)
//    }
//}
//
//struct AddMemoryView: View {
//    @Binding var newMemory: String
//    @Binding var memories: [String]
//
//    var body: some View {
//        VStack {
//            TextField("Yeni anı ekle...", text: $newMemory)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding(.horizontal)
//
//            Button("Ekle") {
//                if !newMemory.isEmpty {
//                    memories.append(newMemory)
//                    newMemory = ""
//                }
//            }
//            .padding()
//            .background(Color.blue)
//            .foregroundColor(.white)
//            .clipShape(Capsule())
//        }
//        .padding()
//    }
//}
//
//struct EmptyMemoriesView: View {
//    var body: some View {
//        VStack {
//            Image(systemName: "book")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 100, height: 100)
//                .foregroundColor(.gray.opacity(0.7))
//
//            Text("Henüz hiç anı yok")
//                .font(.headline)
//                .foregroundColor(.gray)
//
//            Text("Yeni anılar ekleyerek kitabınızı oluşturun!")
//                .font(.subheadline)
//                .foregroundColor(.gray.opacity(0.8))
//                .multilineTextAlignment(.center)
//                .frame(maxWidth: 250)
//        }
//        .padding()
//    }
//}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "person.3.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.gray.opacity(0.7))
                .padding()
            
            Text("No Friends Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Text("Add new friends and keep their memories close!")
                .font(.body)
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 250)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FriendsGrid: View {
    let friends: [Friend]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 3)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 15) {
            ForEach(friends) { friend in
                NavigationLink(destination: FriendDetailView(friend: friend)) {
                    FriendCircle(friend: friend)
                }
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
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
            }
            Text(friend.name)
                .font(.caption)
                .foregroundColor(.black)
        }
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView()
    }
}
