//
//  AddNewFriendView.swift
//  FriendsMemo
//
//  Created by Gizem Coskun on 27/02/25.
//

import SwiftUI
import PhotosUI

struct AddNewFriendView: View {
    @Environment(\.dismiss) var dismiss  // This allows dismissing the modal

    @State private var name: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    
    var onAddFriend: (Friend) -> Void
    
    var body: some View {
        VStack {
            Text("Add a New Friend")
                .font(.largeTitle)
                .padding()
            
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 3))
                    .padding()
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 150, height: 150)
                    .overlay(
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                    )
                    .padding()
            }
            
            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                Text("Select a Photo")
                    .foregroundColor(.blue)
                    .padding(.vertical, 5)
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImage = UIImage(data: data)
                    }
                }
            }
            
            TextField("Enter friend's name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Spacer()
            
            Button("Add Friend") {
                if !name.isEmpty {
                    let newFriend = Friend(name: name, image: selectedImage)
                    onAddFriend(newFriend)  // Add to the list
                    dismiss()  // Dismiss the sheet
                }
            }
            .padding()
            .background(Capsule().fill(Color.blue))
            .foregroundColor(.white)
        }
        .padding()
        .navigationTitle("Add Friend")
    }
}

#Preview {
    AddNewFriendView { _ in }
}
