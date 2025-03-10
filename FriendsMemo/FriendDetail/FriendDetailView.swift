import SwiftUI
import PencilKit
import PhotosUI

import SwiftUI
import PencilKit

struct FriendDetailView: View {
    let friend: Friend
    @StateObject private var viewModel = FriendDetailViewModel()
    @State private var showAddMemoryView = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                if viewModel.memories.isEmpty {
                    BookCoverView(emoji: friend.emoji)
                } else {
                    MemoryBookView(memories: $viewModel.memories)
                }
            }
            
            Button(action: {
                showAddMemoryView.toggle()
            }) {
                Image(systemName: "plus.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding()
            }
            .padding(.trailing, 20)
            .padding(.top, 20)
        }
        .sheet(isPresented: $showAddMemoryView) {
            AddMemoryView(viewModel: viewModel) {
                showAddMemoryView = false
            }
        }
    }
}

struct BookCoverView: View {
    let emoji: String

    var body: some View {
        VStack {
            Text(emoji)
                .font(.system(size: 150))
                .padding()
            Text("Tap to open the book")
                .font(.title2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cornerRadius(15)
    }
}
struct MemoryBookView: View {
    @Binding var memories: [Memory]
    @State private var currentPage = 0
    
    var body: some View {
        VStack {
            if !memories.isEmpty {
                MemoryPage(memory: memories[currentPage])
                    .transition(.slide)
            }
            HStack {
                Button(action: {
                    if currentPage > 0 { currentPage -= 1 }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.largeTitle)
                        .opacity(currentPage > 0 ? 1 : 0.3)
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    if currentPage < memories.count - 1 { currentPage += 1 }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.largeTitle)
                        .opacity(currentPage < memories.count - 1 ? 1 : 0.3)
                }
                .padding()
            }
        }
        .padding()
    }
}

struct MemoryPage: View {
    let memory: Memory
    
    var body: some View {
        VStack {
            if let image = memory.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            }
            if let text = memory.text {
                Text(text)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            if let drawing = memory.drawing {
                Image(uiImage: drawing)
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}



struct AddMemoryView: View {
    @ObservedObject var viewModel: FriendDetailViewModel
    @State private var text: String = ""
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var canvasView = PKCanvasView()
    @Environment(\.presentationMode) var presentationMode
    var onMemoryAdded: () -> Void

    var body: some View {
        VStack {
            TextField("Write something...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Choose Image") {
                isImagePickerPresented.toggle()
            }
            .padding()
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $selectedImage)
            }

            DrawingView(canvasView: $canvasView)
                .frame(height: 300)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding()

            Button("Save Memory") {
                let newMemory = Memory(
                    text: text.isEmpty ? nil : text,
                    image: selectedImage,
                    drawing: canvasView.drawing.image(from: canvasView.bounds, scale: 1.0)
                )
                viewModel.memories.append(newMemory)

                // Reset fields
                text = ""
                selectedImage = nil
                canvasView.drawing = PKDrawing()

                // Automatically close and switch to MemoryBookView
                onMemoryAdded()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
        .padding()
    }
}


struct Memory {
    var text: String?
    var image: UIImage?
    var drawing: UIImage?
}

final class FriendDetailViewModel: ObservableObject {
    @Published var memories: [Memory] = []
}

struct DrawingView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }
}
