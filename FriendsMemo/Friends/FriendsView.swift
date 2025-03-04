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
                        .frame(maxHeight: .infinity, alignment: .center)
                        .padding()
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

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 15) {
            Text("📚")
                .font(.system(size: 120))
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
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(friends) { friend in
                    NavigationLink(destination: FriendDetailView(friend: friend)) {
                        FriendCard(friend: friend)
                            .frame(width: 160, height: 160)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(20)
                    }
                }
            }
            .padding()
        }
    }
}

struct FriendCard: View {
    let friend: Friend
    
    var body: some View {
        VStack {
            Text(friend.color == .blue ? "📘" : friend.color == .red ? "📕" : friend.color == .green ? "📗" : "📒")
                .font(.system(size: 100))
            
            Text(friend.name)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.black)
        }
        .padding()
    }
}

//struct FriendDetailView: View {
//    let friend: Friend
//    
//    var body: some View {
//        VStack {
//            if let image = friend.image {
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 200, height: 200)
//                    .clipShape(Circle())
//            }
//            Text(friend.name)
//                .font(.title)
//                .fontWeight(.bold)
//                .padding()
//            Text("Color: \(friend.color.description)")
//                .font(.body)
//        }
//    }
//}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView()
    }
}
