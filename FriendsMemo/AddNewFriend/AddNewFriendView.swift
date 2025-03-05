import SwiftUI
import PhotosUI


struct ContentView: View {
    @State private var friends: [Friend] = []
    @State private var showingAddFriendView: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                List(friends) { friend in
                    HStack {
                        // Display the emoji based on the friend's selected color
                        Text(friend.emoji)
                            .font(.system(size: 30))
                        Text(friend.name)
                    }
                }
                .navigationTitle("Friends List")
                
                Button("New Friend") {
                    showingAddFriendView = true
                }
                .padding()
                .sheet(isPresented: $showingAddFriendView) {
                    AddNewFriendView { newFriend in
                        // Add the new friend to the friends list
                        friends.append(newFriend)
                    }
                }
            }
        }
    }
}

struct AddNewFriendView: View {
    @Environment(\.dismiss) var dismiss  // This allows dismissing the modal
    
    @State private var name: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var selectedColor: Color = .blue
    
    let colors: [(color: Color, emoji: String)] = [
        (.blue, "📘"),
        (.red, "📕"),
        (.green, "📗"),
        (.yellow, "📒")
    ]
    
    var onAddFriend: (Friend) -> Void
    
    var body: some View {
        VStack {
            Text("Add a New Friend")
                .font(.largeTitle)
                .padding()
            
           
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 150, height: 150)
                    .overlay(
                        Text(colors.first(where: { $0.color == selectedColor })?.emoji ?? "📚")
                            .font(.system(size: 50))
                    )
                    .padding()
            
            
            
            
            TextField("Enter friend's name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack {
                ForEach(colors, id: \.color) { color in
                    Circle()
                        .fill(color.color)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(selectedColor == color.color ? Color.black : Color.clear, lineWidth: 3)
                        )
                        .onTapGesture {
                            selectedColor = color.color
                        }
                }
            }
            .padding()
            
            Spacer()
            
            Button("Add Friend") {
                if !name.isEmpty {
                    let newFriend = Friend(name: name, color: selectedColor, emoji: colors.first(where: { $0.color == selectedColor })?.emoji ?? "📚")
                    onAddFriend(newFriend)  // Add to the list
                    dismiss()  // Dismiss the sheet
                }
            }
            .padding()
            .background(Capsule().fill(selectedColor))
            .foregroundColor(.white)
        }
        .padding()
        .navigationTitle("Add Friend")
    }
}
