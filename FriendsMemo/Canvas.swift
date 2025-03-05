import SwiftUI
import PencilKit

struct TextItem: Identifiable {
    let id = UUID()
    var text: String
    var position: CGPoint
    var fontSize: CGFloat = 24 // Default font size
    var isEditing: Bool = false
}

struct ImageItem: Identifiable {
    let id = UUID()
    var image: UIImage
    var position: CGPoint
    var scale: CGFloat = 1.0
}

struct FreeformNoteView: View {
    @State private var textItems: [TextItem] = []
    @State private var images: [ImageItem] = []
    @State private var currentText = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var showingToolPicker = false
    @State private var showingColorPicker = false
    @State private var selectedPenColor: UIColor = .black
    @State private var selectedPenType: PKInkingTool.InkType = .pen
    
    var body: some View {
        ZStack {
            CanvasView(
                canvasView: $canvasView,
                toolPicker: $toolPicker,
                showingToolPicker: $showingToolPicker,
                selectedPenColor: $selectedPenColor,
                selectedPenType: $selectedPenType
            )
            
            // Enhanced Text Items with Pinch-to-Zoom and Editing
            ForEach($textItems) { $item in
                ZStack {
                    if item.isEditing {
                        TextField("Edit Text", text: $item.text, onCommit: {
                            item.isEditing = false
                        })
                        .font(.system(size: item.fontSize))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .position(item.position)
                    } else {
                        Text(item.text)
                            .font(.system(size: item.fontSize))
                            .position(item.position)
                            .gesture(
                                TapGesture(count: 2)
                                    .onEnded {
                                        item.isEditing = true
                                    }
                            )
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        item.position = value.location
                                    }
                            )
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { scale in
                                        item.fontSize = max(20, min(item.fontSize * scale.magnitude, 72))
                                    }
                            )
                    }
                }
            }
            
            // Enhanced Image Items with Pinch-to-Zoom
            ForEach(images) { item in
                Image(uiImage: item.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100 * item.scale, height: 100 * item.scale)
                    .position(item.position)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if let index = images.firstIndex(where: { $0.id == item.id }) {
                                    images[index].position = value.location
                                }
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { scale in
                                if let index = images.firstIndex(where: { $0.id == item.id }) {
                                    images[index].scale = max(0.5, min(item.scale * scale.magnitude, 3.0))
                                }
                            }
                    )
            }
            
            if showingToolPicker {
                Button("Done") {
                    showingToolPicker = false
                    toolPicker.setVisible(false, forFirstResponder: canvasView)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .position(x: UIScreen.main.bounds.width - 80, y: 40)
                .opacity(showingToolPicker ? 1 : 0)
            }
            
            // Color picker overlay
            if showingColorPicker {
                ColorPickerView(selectedColor: $selectedPenColor, isShowing: $showingColorPicker)
                    .zIndex(1)
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
        .onChange(of: selectedPenColor) { _ in
            configurePenTool()
        }
        .onChange(of: selectedPenType) { _ in
            configurePenTool()
        }
    }
    
    private func textItemView(_ item: TextItem) -> some View {
        TextField("New Text", text: Binding(
            get: { item.text },
            set: { newValue in
                if let index = textItems.firstIndex(where: { $0.id == item.id }) {
                    textItems[index].text = newValue
                }
            }
        ))
        .font(.system(size: item.fontSize))
        .position(item.position)
        .gesture(dragGesture(for: item))
        .gesture(magnificationGesture(for: item))
    }
    
    private func imageItemView(_ item: ImageItem) -> some View {
        Image(uiImage: item.image)
            .resizable()
            .scaledToFit()
            .frame(width: 100 * item.scale, height: 100 * item.scale)
            .position(item.position)
            .gesture(dragGesture(for: item))
            .gesture(magnificationGesture(for: item))
    }
    
    // Other private methods and code
    private func dragGesture(for item: TextItem) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if let index = textItems.firstIndex(where: { $0.id == item.id }) {
                    textItems[index].position = value.location
                }
            }
    }
    
    private func dragGesture(for item: ImageItem) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if let index = images.firstIndex(where: { $0.id == item.id }) {
                    images[index].position = value.location
                }
            }
    }
    private func magnificationGesture(for item: TextItem) -> some Gesture {
        MagnificationGesture()
            .onChanged { scale in
                if let index = textItems.firstIndex(where: { $0.id == item.id }) {
                    textItems[index].fontSize = max(10, min(item.fontSize * scale.magnitude, 72))
                }
            }
    }
    
    private func magnificationGesture(for item: ImageItem) -> some Gesture {
        MagnificationGesture()
            .onChanged { scale in
                if let index = images.firstIndex(where: { $0.id == item.id }) {
                    images[index].scale = max(0.5, min(item.scale * scale.magnitude, 3.0))
                }
            }
    }
    private var toolbar: some View {
        HStack(spacing: 20) {
            Button(action: {
                textItems.append(TextItem(text: "New Text", position: CGPoint(x: 100, y: 100)))
            }) {
                VStack {
                    Image(systemName: "textbox")
                    Text("Text")
                }
            }
            
            Button(action: {
                showingImagePicker = true
            }) {
                VStack {
                    Image(systemName: "photo")
                    Text("Image")
                }
            }
            
            Button(action: {
                showingToolPicker.toggle()
            }) {
                VStack {
                    Image(systemName: "pencil")
                    Text("Pen")
                }
            }
            
            Button(action: {
                canvasView.drawing = PKDrawing()
                textItems.removeAll()
                images.removeAll()
            }) {
                VStack {
                    Image(systemName: "trash")
                    Text("Clear")
                }
            }
            
            Button(action: {
                showingColorPicker = true
            }) {
                VStack {
                    Image(systemName: "paintpalette")
                    Text("Color")
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(10)
    }
    
    private func configurePenTool() {
        let tool = PKInkingTool(selectedPenType, color: selectedPenColor, width: 5)
        canvasView.tool = tool
        toolPicker.selectedTool = tool
    }
}


struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var toolPicker: PKToolPicker
    @Binding var showingToolPicker: Bool
    @Binding var selectedPenColor: UIColor
    @Binding var selectedPenType: PKInkingTool.InkType
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .default
        canvasView.isOpaque = false
        
        // Initialize tool picker
        toolPicker.setVisible(false, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if showingToolPicker {
            toolPicker.setVisible(true, forFirstResponder: uiView)
            uiView.becomeFirstResponder()
        } else {
            toolPicker.setVisible(false, forFirstResponder: uiView)
        }
        
        // Ensure the correct tool is applied to the canvas
        let tool = PKInkingTool(selectedPenType, color: selectedPenColor, width: 5)
        uiView.tool = tool
        toolPicker.selectedTool = tool
    }
}

struct CustomImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
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

struct ColorPickerView: View {
    @Binding var selectedColor: UIColor
    @Binding var isShowing: Bool
    
    let colors: [UIColor] = [
        .black,
        .red,
        .blue,
        .green,
        .purple,
        .orange,
        .systemPink,
        .brown,
        .gray
    ]
    
    var body: some View {
        VStack {
            Text("Select Pen Color")
                .font(.headline)
                .padding()
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 50))
            ], spacing: 15) {
                ForEach(colors, id: \.self) { color in
                    Button(action: {
                        selectedColor = color
                        isShowing = false
                    }) {
                        Circle()
                            .fill(Color(color))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(color == selectedColor ? Color.white : Color.clear, lineWidth: 3)
                                    .background(
                                        Circle()
                                            .stroke(Color.black.opacity(0.3), lineWidth: 2)
                                    )
                            )
                    }
                }
            }
            .padding()
            
            Button("Cancel") {
                isShowing = false
            }
            .foregroundColor(.red)
            .padding()
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.4))
        .edgesIgnoringSafeArea(.all)
        .zIndex(1)
    }
}

struct SimultaneousGesture: Gesture {
    let first: DragGesture
    let second: MagnificationGesture
    
    init(_ first: DragGesture, _ second: MagnificationGesture) {
        self.first = first
        self.second = second
    }
    
    var body: some Gesture {
        first.simultaneously(with: second)
    }
}

struct FreeformNoteView_Previews: PreviewProvider {
    static var previews: some View {
        FreeformNoteView()
    }
}
