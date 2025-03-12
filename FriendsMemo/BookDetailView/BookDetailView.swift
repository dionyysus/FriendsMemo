//
//  BookDetailView.swift
//  FriendsMemo
//
//  Created by Gizem Coskun on 11/03/25.
//


import SwiftUI
import PencilKit

struct BookDetailView: View {
    let book: MemoryBook
    @State private var currentPage = 0
    @State private var pages: [PageData] = []
    @State private var animatePageChange = false
    @State private var isEditing = false
    @State private var editingPageIndex: Int?
    
    private var pagesKey: String {
        return "bookPages_\(book.id.uuidString)"
    }
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            if isEditing, let index = editingPageIndex {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            savePage(at: index)
                            isEditing = false
                            editingPageIndex = nil
                        }) {
                            HStack {
                                Text("Done")
                                Image(systemName: "checkmark.circle.fill")
                            }
                            .padding(8)
                            .background(book.color.toSwiftUIColor().opacity(0.3))
                            .cornerRadius(8)
                            .padding()
                        }
                    }
                    
                    FreeformNoteView1(
                        book: book,
                        pageContent: pages[index].title,
                        savedDrawing: pages[index].drawing,
                        savedTextItems: pages[index].textItems,
                        savedImages: pages[index].images,
                        onSave: { drawing, textItems, images in
                            pages[index].drawing = drawing
                            pages[index].textItems = textItems
                            pages[index].images = images
                            savePagesToUserDefaults()
                        }
                    )
                }
                .transition(.move(edge: .bottom))
            } else {
                // Normal view
                VStack {
                    if pages.isEmpty {
                        Text("No Memories")
                            .font(.title)
                            .padding()
                            .foregroundColor(.gray)
                    } else {
                        TabView(selection: $currentPage) {
                            ForEach(0..<pages.count, id: \.self) { index in
                                VStack {
                                    PagePreviewView(pageData: pages[index])
                                        .frame(maxWidth: 350, maxHeight: 600)
                                        .background(book.color.toSwiftUIColor().opacity(0.2))
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                        .tag(index)
                                        .transition(.opacity)
                                    
                                    Button(action: {
                                        editingPageIndex = index
                                        isEditing = true
                                    }) {
                                        HStack {
                                            Image(systemName: "pencil")
                                            Text("Edit")
                                        }
                                        .padding(8)
                                        .background(book.color.toSwiftUIColor().opacity(0.3))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                        .animation(.easeInOut(duration: 0.5), value: animatePageChange)
                    }
                    Spacer()
                }
            }
        }
        .navigationTitle(book.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
                                Button(action: {
            withAnimation {
                let newPage = PageData(
                    title: "Page \(pages.count + 1)",
                    drawing: PKDrawing(),
                    textItems: [],
                    images: []
                )
                pages.append(newPage)
                currentPage = pages.count - 1
                animatePageChange.toggle()
                savePagesToUserDefaults()
            }
        }) {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(book.color.toSwiftUIColor())
        }
        )
        .onAppear {
            loadPagesFromUserDefaults()
        }
    }
    
    private func savePage(at index: Int) {
        savePagesToUserDefaults()
    }
    
    private func loadPagesFromUserDefaults() {
        if let savedData = UserDefaults.standard.data(forKey: pagesKey) {
            if let decodedPages = try? JSONDecoder().decode([PageData].self, from: savedData) {
                pages = decodedPages
            } else {
                // Fallback for older storage format
                if let savedPages = UserDefaults.standard.object(forKey: pagesKey) as? [String] {
                    pages = savedPages.map { PageData(title: $0, drawing: PKDrawing(), textItems: [], images: []) }
                }
            }
        }
    }
    
    private func savePagesToUserDefaults() {
        if let encodedData = try? JSONEncoder().encode(pages) {
            UserDefaults.standard.set(encodedData, forKey: pagesKey)
        }
    }
}

// Preview for a page
struct PagePreviewView: View {
    let pageData: PageData
    
    var body: some View {
        VStack {
            
            if !pageData.textItems.isEmpty || !pageData.images.isEmpty || !pageData.drawing.bounds.isEmpty {
                
                ZStack {
                    if !pageData.drawing.bounds.isEmpty {
                        DrawingPreview(drawing: pageData.drawing)
                            .padding(8)
                    }
                    
                    ForEach(pageData.textItems.prefix(2), id: \.id) { item in
                        Text(item.text)
                            .font(.caption)
                            .foregroundColor(.black)
                            .position(item.position)
                    }
                    
                    ForEach(pageData.images.prefix(2), id: \.id) { item in
                        Image(uiImage: item.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .position(item.position)
                    }
                }
                .frame(width: 350, height: 600)
                .clipped()
            } else {
                Text("Empty page")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(height: 200)
            }
        }
        .padding()
    }
}

struct DrawingPreview: UIViewRepresentable {
    let drawing: PKDrawing
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.isUserInteractionEnabled = false
        canvasView.drawing = drawing
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.drawing = drawing
    }
}

// Updated FreeformNoteView to work with saved data
struct FreeformNoteView1: View {
    let book: MemoryBook
    let pageContent: String
    var savedDrawing: PKDrawing
    var savedTextItems: [TextItem]
    var savedImages: [ImageItem]
    var onSave: (PKDrawing, [TextItem], [ImageItem]) -> Void
    
    @State private var textItems: [TextItem] = []
    @State private var images: [ImageItem] = []
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
                saveChanges()
            }
        }
        .onChange(of: selectedPenColor) { _ in
            configurePenTool()
        }
        .onChange(of: selectedPenType) { _ in
            configurePenTool()
        }
        .onAppear {
            // Initialize with saved data
            canvasView.drawing = savedDrawing
            textItems = savedTextItems
            images = savedImages
        }
        .onDisappear {
            saveChanges()
        }
    }
    
    private var toolbar: some View {
        HStack(spacing: 20) {
            Button(action: {
                textItems.append(TextItem(text: "New Text", position: CGPoint(x: 100, y: 100)))
                saveChanges()
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
                saveChanges()
            }) {
                VStack {
                    Image(systemName: "trash")
                    Text("Clear")
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
    
    private func saveChanges() {
        onSave(canvasView.drawing, textItems, images)
    }
}

// Model for storing page data
struct PageData: Codable, Identifiable {
    var id = UUID()
    var title: String
    var drawingData: Data?
    var textItems: [TextItem]
    var imagesData: [ImageData]
    
    struct ImageData: Codable, Identifiable {
        var id = UUID()
        var imageData: Data
        var positionX: CGFloat
        var positionY: CGFloat
    }
    
    var drawing: PKDrawing {
        get {
            if let data = drawingData, let drawing = try? PKDrawing(data: data) {
                return drawing
            }
            return PKDrawing()
        }
        set {
            drawingData = try? newValue.dataRepresentation()
        }
    }
    
    var images: [ImageItem] {
        get {
            return imagesData.compactMap { imageData in
                if let image = UIImage(data: imageData.imageData) {
                    return ImageItem(
                        image: image,
                        position: CGPoint(x: imageData.positionX, y: imageData.positionY)
                    )
                }
                return nil
            }
        }
        set {
            imagesData = newValue.map { item in
                if let imageData = item.image.jpegData(compressionQuality: 0.7) {
                    return ImageData(
                        imageData: imageData,
                        positionX: item.position.x,
                        positionY: item.position.y
                    )
                }
                return ImageData(
                    imageData: Data(),
                    positionX: item.position.x,
                    positionY: item.position.y
                )
            }
        }
    }
    
    init(title: String, drawing: PKDrawing, textItems: [TextItem], images: [ImageItem]) {
        self.title = title
        self.drawingData = try? drawing.dataRepresentation()
        self.textItems = textItems
        self.imagesData = images.map { item in
            if let imageData = item.image.jpegData(compressionQuality: 0.7) {
                return ImageData(
                    imageData: imageData,
                    positionX: item.position.x,
                    positionY: item.position.y
                )
            }
            return ImageData(
                imageData: Data(),
                positionX: item.position.x,
                positionY: item.position.y
            )
        }
    }
}

// Make TextItem Codable
extension TextItem: Codable {
    enum CodingKeys: String, CodingKey {
        case id, text, positionX, positionY
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        let x = try container.decode(CGFloat.self, forKey: .positionX)
        let y = try container.decode(CGFloat.self, forKey: .positionY)
        position = CGPoint(x: x, y: y)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(position.x, forKey: .positionX)
        try container.encode(position.y, forKey: .positionY)
    }
}
