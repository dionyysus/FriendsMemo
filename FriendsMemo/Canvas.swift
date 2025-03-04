import SwiftUI
import PencilKit

struct FreeformNoteView: View {
    @State private var textItems: [TextItem] = []
    @State private var images: [ImageItem] = []
    @State private var currentText = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var showingToolPicker = false
    
    var body: some View {
        ZStack {
            CanvasView(canvasView: $canvasView, toolPicker: $toolPicker, showingToolPicker: $showingToolPicker)
            
            ForEach(textItems) { item in
                Text(item.text)
                    .font(.title)
                    .position(item.position)
                    .gesture(DragGesture()
                        .onChanged { value in
                            if let index = textItems.firstIndex(where: { $0.id == item.id }) {
                                textItems[index].position = value.location
                            }
                        }
                    )
            }
            
            ForEach(images) { item in
                Image(uiImage: item.image)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .position(item.position)
                    .gesture(DragGesture()
                        .onChanged { value in
                            if let index = images.firstIndex(where: { $0.id == item.id }) {
                                images[index].position = value.location
                            }
                        }
                    )
            }
            
            // Done butonunun sadece toolPicker görünürken görünmesini sağla
            if showingToolPicker {
                Button("Done") {
                    showingToolPicker = false
                    toolPicker.setVisible(false, forFirstResponder: canvasView)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .position(x: UIScreen.main.bounds.width - 80, y: 40)
                .opacity(showingToolPicker ? 1 : 0)  // Done butonunun yalnızca toolPicker aktifken görünmesini sağla
            }
        }
        .overlay(toolbar, alignment: .bottom)
        .sheet(isPresented: $showingImagePicker) {
            CustomImagePicker(image: $selectedImage)
        }
        .onChange(of: selectedImage) { newImage in
            if let newImage = newImage {
                images.append(ImageItem(image: newImage, position: CGPoint(x: 150, y: 150)))
            }
        }
    }
    
    private var toolbar: some View {
        HStack {
            Button("Add Text") {
                textItems.append(TextItem(text: "New Text", position: CGPoint(x: 100, y: 100)))
            }
            Button("Add Image") {
                showingImagePicker = true
            }
            Button("Pen") {
                showingToolPicker.toggle()  // Tool picker'ı açıp kapatmak için toggle kullanılıyor
            }
            Button("Clear") {
                canvasView.drawing = PKDrawing()
                textItems.removeAll()
                images.removeAll()
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(10)
    }
}

struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var toolPicker: PKToolPicker
    @Binding var showingToolPicker: Bool
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .default
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if showingToolPicker {
            toolPicker.setVisible(true, forFirstResponder: uiView)
            uiView.becomeFirstResponder()
        } else {
            toolPicker.setVisible(false, forFirstResponder: uiView)
        }
    }
}

struct TextItem: Identifiable {
    let id = UUID()
    var text: String
    var position: CGPoint
}

struct ImageItem: Identifiable {
    let id = UUID()
    var image: UIImage
    var position: CGPoint
}

struct CustomImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CustomImagePicker
        
        init(_ parent: CustomImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }
    }
}

struct FreeformNoteView_Previews: PreviewProvider {
    static var previews: some View {
        FreeformNoteView()
    }
}

