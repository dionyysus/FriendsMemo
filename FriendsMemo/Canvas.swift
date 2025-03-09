import SwiftUI
import PencilKit

struct TextItem: Identifiable {
    let id = UUID()
    var text: String
    var position: CGPoint
    var fontSize: CGFloat = 24
    var isEditing: Bool = false
}

struct ImageItem: Identifiable {
    let id = UUID()
    var image: UIImage
    var position: CGPoint
    var scale: CGFloat = 1.0
}

struct SavedDrawing: Identifiable {
    var id = UUID()
    var textItems: [TextItem] // your model for text items
    var images: [ImageItem] // your model for image items
    var coverImage: UIImage? // Add this property for the cover image
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
    @State private var savedDrawings: [SavedDrawing] = []

    var body: some View {
        NavigationView {
            VStack {
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
                                                item.fontSize = max(10, min(item.fontSize * scale.magnitude, 72)) // Fixed font size bounds
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
                
                // Save Button
                Button("Save") {
                    saveDrawing()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
                
                // Navigation to saved drawings
                NavigationLink(destination: MemoryCollectionView(savedDrawings: $savedDrawings)) {
                    Text("View Saved Drawings")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationBarTitle("Freeform Note", displayMode: .inline)
        }
    }
    
    private func saveDrawing() {
        let savedDrawing = SavedDrawing(textItems: textItems, images: images)
        savedDrawings.append(savedDrawing)
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


struct MemoryCollectionView: View {
    @Binding var savedDrawings: [SavedDrawing]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                ForEach(savedDrawings) { drawing in
                    NavigationLink(destination: SavedDrawingDetailView(savedDrawing: drawing)) {
                        VStack {
                            Image(systemName: "heart.fill") 
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.black)
                                .padding()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                }
            }
        }
        .padding()
    }
}


struct SavedDrawingDetailView: View {
    var savedDrawing: SavedDrawing
    
    var body: some View {
        ForEach(savedDrawing.textItems) { item in
            Text(item.text)
                .font(.system(size: item.fontSize))
                .position(item.position)
        }

        ForEach(savedDrawing.images) { item in
            Image(uiImage: item.image)
                .resizable()
                .scaledToFit()
                    .frame(width: 100 * item.scale, height: 100 * item.scale)
                .position(item.position)
        }
    }
}

struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var toolPicker: PKToolPicker
    @Binding var showingToolPicker: Bool
    @Binding var selectedPenColor: UIColor
    @Binding var selectedPenType: PKInkingTool.InkType
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.delegate = context.coordinator
        canvasView.drawingPolicy = .anyInput
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if showingToolPicker {
            toolPicker.setVisible(true, forFirstResponder: uiView)
            uiView.becomeFirstResponder()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // Handle drawing change
        }
    }
}

struct CustomImagePicker: View {
    @Binding var image: UIImage?
    
    var body: some View {
            ImagePicker(image: $image)
        }
}

struct ColorPickerView: View {
    @Binding var selectedColor: UIColor
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            ColorPicker("Pick a color", selection: Binding(
                get: { Color(selectedColor) },
                set: { selectedColor = UIColor($0) }
            ))
            Button("Close") {
                isShowing = false
            }
            .padding()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
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
