//
//  BookDetailView.swift
//  FriendsMemo
//
//  Created by Gizem Coskun on 11/03/25.
//

import SwiftUI
import PencilKit

// MARK: - BookDetailView
struct BookDetailView: View {
    let book: MemoryBook
    
    @State private var currentPage = 0
    @State private var pages: [PageData] = []
    @State private var animatePageChange = false
    @State private var isEditing = false
    @State private var editingPageIndex: Int?
    @State private var isDeleting = false
    @State private var showClearAlert = false
    @State private var showToolPicker = false
    @State private var showMoreOptions = false
    
    private var pagesKey: String {
        return "bookPages_\(book.id.uuidString)"
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.93, green: 0.91, blue: 0.88)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text(book.name)
                    .font(.system(size: 20, weight: .medium))
                    .kerning(1)
                    .foregroundColor(Color(red: 0.25, green: 0.25, blue: 0.25))
                    .padding(.top, 15)
                
                pagesTabView
                    .padding(.bottom, 80)
                
                Spacer()
            }
            
            if !showToolPicker {
                unifiedToolbarView
                    .zIndex(100)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadPagesFromUserDefaults()
        }
    }
    
    // MARK: Views
    private var pagesTabView: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    VStack {
                        pageContentView(for: index)
                    }
                    .tag(index)
                    .transition(.opacity)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .animation(.easeInOut(duration: 0.3), value: animatePageChange)
            .overlay(
                Group {
                    if pages.isEmpty {
                        emptyStateView
                    }
                }
            )
        }
    }
    
    private func pageContentView(for index: Int) -> some View {
        ZStack {
            VStack {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 350, height: 500)
                    .cornerRadius(4)
                    .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                
                Spacer().frame(height: 0)
            }
            
            VStack {
                Spacer()
                Rectangle()
                    .fill(book.color.toSwiftUIColor())
                    .frame(height: 20)
            }
            .frame(width: 350, height: 500)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            
            // Direct editing view with safe index checking
            if pages.indices.contains(index) {
                FreeformNoteView1(
                    book: book,
                    pageContent: pages[index].title,
                    savedDrawing: pages[index].drawing,
                    savedTextItems: pages[index].textItems,
                    savedImages: pages[index].images,
                    isEditMode: .constant(true),  // Always in edit mode
                    showToolPicker: Binding(
                        get: { pages[index].showToolPicker },
                        set: { newValue in
                            // Add safe index check
                            if pages.indices.contains(index) {
                                pages[index].showToolPicker = newValue
                                showToolPicker = newValue
                                savePagesToUserDefaults()
                            }
                        }
                    ),
                    showImagePicker: Binding(
                        get: { pages.indices.contains(index) ? pages[index].showImagePicker : false },
                        set: { newValue in
                            if pages.indices.contains(index) {
                                pages[index].showImagePicker = newValue
                            }
                        }
                    ),
                    enterTextPlacement: Binding(
                        get: { pages.indices.contains(index) ? pages[index].enterTextPlacementMode : false },
                        set: { newValue in
                            if pages.indices.contains(index) {
                                pages[index].enterTextPlacementMode = newValue
                            }
                        }
                    ),
                    onSave: { drawing, textItems, images in
                        // Add safe index check before trying to save
                        if pages.indices.contains(index) {
                            pages[index].drawing = drawing
                            pages[index].textItems = textItems
                            pages[index].images = images
                            pages[index].showToolPicker = showToolPicker
                            savePagesToUserDefaults()
                        }
                    },
                    onDone: {
                        // Add safe index check
                        if pages.indices.contains(index) {
                            savePage(at: index)
                        }
                    },
                    onDelete: deleteCurrentPage,
                    onAddPage: addNewPage
                )
                .frame(width: 350, height: 500)
            }
            
            VStack {
                Spacer()
                HStack {
                    Text("Page \(index + 1)")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 2)
            }
            .frame(width: 350, height: 500)
        }
    }
    // MARK: - Improved Toolbar Design
    private var unifiedToolbarView: some View {
        VStack {
            Spacer()
            
            if !showToolPicker {
                VStack(spacing: 0) {
                    // Main toolbar with frequently used actions
                    HStack(spacing: 20) {
                        
                        // Add button
                        Button(action: addNewPage) {
                            Image(systemName: "plus")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                                .frame(width: 40, height: 40)
                        }
                        
                        // Drawing tools button
                        Button(action: toggleDrawingMode) {
                            Image(systemName: "pencil.tip")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                                .frame(width: 40, height: 40)
                        }
                        .disabled(pages.isEmpty)
                        .opacity(pages.isEmpty ? 0.3 : 1.0)
                        
                        // Text button
                        Button(action: addTextToPage) {
                            Image(systemName: "text.alignleft")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                                .frame(width: 40, height: 40)
                        }
                        .disabled(pages.isEmpty)
                        .opacity(pages.isEmpty ? 0.3 : 1.0)
                        
                        // Photo button
                        Button(action: showImagePickerForPage) {
                            Image(systemName: "photo")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                                .frame(width: 40, height: 40)
                        }
                        .disabled(pages.isEmpty)
                        .opacity(pages.isEmpty ? 0.3 : 1.0)
                        
                       
//                        // Show more button
//                        Button(action: {
//                            withAnimation {
//                                showMoreOptions.toggle()
//                            }
//                        }) {
//                            Image(systemName: showMoreOptions ? "chevron.down" : "ellipsis")
//                                .font(.system(size: 16))
//                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
//                                .frame(width: 40, height: 40)
//                        }
                        
                        // Delete page button
                        Button(action: deleteCurrentPage) {
                            Image(systemName: "trash")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                                .frame(width: 40, height: 40)
                        }
                        .disabled(pages.isEmpty)
                        .opacity(pages.isEmpty ? 0.3 : 1.0)
                        
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                    )
                    
                    // Extended options when "Show more" is clicked
                    if showMoreOptions {
                        HStack(spacing: 20) {
                            // Save button
                            Button(action: {
                                savePage(at: currentPage)
                            }) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                                    .frame(width: 40, height: 40)
                            }
                            .disabled(pages.isEmpty)
                            .opacity(pages.isEmpty ? 0.3 : 1.0)
                            
                            // Clear page button
                            Button(action: {
                                showClearAlert = true
                            }) {
                                Image(systemName: "trash.slash")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                                    .frame(width: 40, height: 40)
                            }
                            .disabled(pages.isEmpty)
                            .opacity(pages.isEmpty ? 0.3 : 1.0)
                            
//                            // Delete page button
//                            Button(action: deleteCurrentPage) {
//                                Image(systemName: "trash")
//                                    .font(.system(size: 16))
//                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
//                                    .frame(width: 40, height: 40)
//                            }
//                            .disabled(pages.isEmpty)
//                            .opacity(pages.isEmpty ? 0.3 : 1.0)
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.top, 8)
                    }
                }
                .padding(.bottom, 30)
                .alert(isPresented: $showClearAlert) {
                    Alert(
                        title: Text("Clear Page Content"),
                        message: Text("Are you sure you want to clear all content from this page?"),
                        primaryButton: .destructive(Text("Clear")) {
                            clearPageContent()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
    }
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .frame(width: 240, height: 280)
            
            Text("No memories yet")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.gray.opacity(0.7))
                .kerning(0.5)
            
            Text("Tap + to add your first page")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.gray.opacity(0.5))
                .kerning(0.5)
        }
    }
    
    // MARK: Actions
    // Also update the functions that modify pages to include bounds checking
    private func addTextToPage() {
        guard !pages.isEmpty else { return }
        
        // Only proceed if current page index is valid
        guard pages.indices.contains(currentPage) else {
            // Handle invalid index - adjust currentPage if needed
            currentPage = min(currentPage, pages.count - 1)
            return
        }
        
        pages[currentPage].enterTextPlacementMode = true
        savePagesToUserDefaults()
    }
    
    private func showImagePickerForPage() {
        guard !pages.isEmpty else { return }
        
        // Only proceed if current page index is valid
        guard pages.indices.contains(currentPage) else {
            // Handle invalid index - adjust currentPage if needed
            currentPage = min(currentPage, pages.count - 1)
            return
        }
        
        pages[currentPage].showImagePicker = true
        savePagesToUserDefaults()
    }
    
    private func toggleDrawingMode() {
        guard !pages.isEmpty else { return }
        
        // Only proceed if current page index is valid
        guard pages.indices.contains(currentPage) else {
            // Handle invalid index - adjust currentPage if needed
            currentPage = min(currentPage, pages.count - 1)
            return
        }
        
        pages[currentPage].showToolPicker = true
        showToolPicker = true
        savePagesToUserDefaults()
    }

    
    private func addNewPage() {
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
    }
    
    private func deleteCurrentPage() {
        guard !pages.isEmpty else { return }
        
        // Check if we need to adjust the page index before deletion
        let pageToDelete = currentPage
        let newPageIndex = currentPage >= pages.count - 1 ? max(0, pages.count - 2) : currentPage
        
        // Show deletion animation
        withAnimation(.easeInOut(duration: 0.3)) {
            isDeleting = true
        }
        
        // Perform deletion with a short delay to allow animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                // Remove the page
                pages.remove(at: pageToDelete)
                
                // Update page index based on deletion conditions
                if pages.isEmpty {
                    // If we deleted the last page, there's no current page
                    currentPage = 0
                } else {
                    // Otherwise, set to the calculated new index
                    currentPage = newPageIndex
                }
                
                isDeleting = false
                savePagesToUserDefaults()
                
                // Add empty state check
                if pages.isEmpty {
                    // If all pages were deleted, we might want to add a new empty page
                    // or simply leave it empty for the user to add a new one
                    print("All pages deleted")
                }
            }
        }
    }
    
    private func savePage(at index: Int) {
        // Check if the index is valid before saving
        if pages.indices.contains(index) {
            savePagesToUserDefaults()
        } else {
            print("Attempted to save a page at invalid index: \(index)")
        }
    }

    
    
    // MARK: Data Management
    private func loadPagesFromUserDefaults() {
        if let savedData = UserDefaults.standard.data(forKey: pagesKey) {
            if let decodedPages = try? JSONDecoder().decode([PageData].self, from: savedData) {
                pages = decodedPages
            } else {
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
    
    private func clearPageContent() {
        guard !pages.isEmpty else { return }
        
        // Only proceed if current page index is valid
        guard pages.indices.contains(currentPage) else {
            // Handle invalid index - adjust currentPage if needed
            currentPage = min(currentPage, pages.count - 1)
            return
        }
        
        pages[currentPage].drawing = PKDrawing()
        pages[currentPage].textItems = []
        pages[currentPage].images = []
        pages[currentPage].showToolPicker = false
        showToolPicker = false
        
        savePagesToUserDefaults()
    }
}

// MARK: - FreeformNoteView1
struct FreeformNoteView1: View {
    // MARK: Properties
    let book: MemoryBook
    let pageContent: String
    var savedDrawing: PKDrawing
    var savedTextItems: [TextItem]
    var savedImages: [ImageItem]
    
    @Binding var isEditMode: Bool
    @Binding var showToolPicker: Bool
    @Binding var showImagePicker: Bool
    @Binding var enterTextPlacement: Bool
    
    var onSave: (PKDrawing, [TextItem], [ImageItem]) -> Void
    var onDone: () -> Void
    var onDelete: () -> Void
    var onAddPage: () -> Void
    
    @State private var textItems: [TextItem] = []
    @State private var images: [ImageItem] = []
    @State private var selectedImage: UIImage?
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var selectedPenColor: UIColor = .black
    @State private var selectedPenType: PKInkingTool.InkType = .pen
    @State private var isInteractionEnabled = true
    
    // Text editing state
    @State private var editingTextItem: UUID? = nil
    @State private var editingText: String = ""
    
    // Text placement state
    @State private var isPlacingNewText = false
    @State private var pendingTextItem: TextItem?
    
    // Content dimensions
    private let contentWidth: CGFloat = 350
    private let contentHeight: CGFloat = 500
    
    // Format current date
    func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: Date())
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                // Clean white background
                Rectangle()
                    .fill(Color.white)
                    .frame(width: contentWidth, height: contentHeight)
                
                CanvasView(
                    canvasView: $canvasView,
                    toolPicker: $toolPicker,
                    showingToolPicker: $showToolPicker,
                    selectedPenColor: $selectedPenColor,
                    selectedPenType: $selectedPenType,
                    isInteractionEnabled: $isInteractionEnabled
                )
                .frame(width: contentWidth, height: contentHeight)
                
                TextItemsLayer(
                    textItems: $textItems,
                    editingTextItem: $editingTextItem,
                    editingText: $editingText,
                    contentWidth: contentWidth,
                    contentHeight: contentHeight,
                    onSave: saveChanges
                )
                .allowsHitTesting(!showToolPicker)
                
                ImageItemsLayer(
                    images: $images,
                    contentWidth: contentWidth,
                    contentHeight: contentHeight,
                    onSave: saveChanges
                )
                .allowsHitTesting(!showToolPicker)
                
                // Text placement overlay
                if isPlacingNewText {
                    textPlacementOverlay
                }
                
                // Page info overlay at the bottom
                VStack {
                    Spacer()
                    
                    // Bottom color band with date
                    ZStack {
                        Rectangle()
                            .fill(book.color.toSwiftUIColor())
                            .frame(height: 20)
                        
                        HStack {
//                            Text(isEditMode ? "Editing" : "Viewing")
//                                .font(.system(size: 12, weight: .regular))
//                                .foregroundColor(.white)
//                            
                            Spacer()
                            
                            Text(formattedDate())
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .frame(width: contentWidth, height: contentHeight)
                .allowsHitTesting(false)
                
                if showToolPicker {
                    VStack {
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                toolPicker.setVisible(false, forFirstResponder: canvasView)
                                isInteractionEnabled = false
                                showToolPicker = false
                                
                                saveChanges()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    onSave(canvasView.drawing, textItems, images)
                                }
                            }) {
                                Text("Done")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(Color.white.opacity(0.9))
                                            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                                    )
                            }
                            .padding(.trailing, 10)
                            .padding(.top, 10)
                        }
                        
                        Spacer()
                    }
                    .frame(width: contentWidth, height: contentHeight)
                    .allowsHitTesting(true)
                    .zIndex(100)
                }
            }
            .frame(width: contentWidth, height: contentHeight)
            .cornerRadius(4)
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { newImage in
            if let newImage = newImage {
                let newImageItem = ImageItem(
                    image: newImage,
                    position: CGPoint(x: contentWidth / 2, y: contentHeight / 2)
                )
                images.append(newImageItem)
                saveChanges()
                selectedImage = nil
                showImagePicker = false
            }
        }
        .onAppear(perform: configureOnAppear)
        .onDisappear {
            toolPicker.setVisible(false, forFirstResponder: canvasView)
            saveChanges()
        }
        .onChange(of: showToolPicker) { newValue in
            isInteractionEnabled = newValue
            updateToolPickerVisibility()
        }
        .onChange(of: enterTextPlacement) { newValue in
            if newValue {
                isPlacingNewText = true
                pendingTextItem = TextItem(
                    text: "Tap to edit",
                    position: CGPoint(x: contentWidth / 2, y: contentHeight / 2)
                )
                enterTextPlacement = false
            }
        }
    }
    
    // MARK: Views
    private var textPlacementOverlay: some View {
        ZStack {
            Color.black.opacity(0.001)
                .frame(width: contentWidth, height: contentHeight)
                .contentShape(Rectangle())
                .onTapGesture { location in
                    placeText(at: location)
                }
            
            if let item = pendingTextItem {
                Text(item.text)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .padding(8)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(4)
                    .position(item.position)
                    .allowsHitTesting(false)
            }
        }
    }
    
    // MARK: Helper Methods
    private func placeText(at location: CGPoint) {
        if let item = pendingTextItem {
            var newItem = item
            newItem.position = location
            textItems.append(newItem)
            saveChanges()
            
            editingTextItem = newItem.id
            editingText = newItem.text
            
            isPlacingNewText = false
            pendingTextItem = nil
        }
    }
    
    private func configureOnAppear() {
        // Initialize with saved data
        canvasView.drawing = savedDrawing
        textItems = savedTextItems
        images = savedImages
        
        // Initialize the tool picker
        toolPicker = PKToolPicker()
        toolPicker.addObserver(canvasView)
        configurePenTool()
        setupToolPicker()
        
        // Make sure interaction state matches tool picker state
        isInteractionEnabled = showToolPicker
        
        if showToolPicker {
            updateToolPickerVisibility()
        }
    }
    
    private func configurePenTool() {
        let tool = PKInkingTool(selectedPenType, color: selectedPenColor, width: 5)
        canvasView.tool = tool
    }
    
    private func saveChanges() {
        onSave(canvasView.drawing, textItems, images)
    }
    
    private func setupToolPicker() {
        toolPicker.colorUserInterfaceStyle = .light
        
        toolPicker.selectedTool = PKInkingTool(selectedPenType, color: selectedPenColor, width: 5)
        
        toolPicker.showsDrawingPolicyControls = false
    }
    
    private func setToolPickerFrameSize() {
        DispatchQueue.main.async {
            if let window = UIApplication.shared.windows.first {
                let toolbarHeight: CGFloat = 100
                
                let toolbarFrame = CGRect(
                    x: 0,
                    y: window.bounds.height - toolbarHeight - window.safeAreaInsets.bottom,
                    width: window.bounds.width,
                    height: toolbarHeight + window.safeAreaInsets.bottom
                )
                
                if #available(iOS 14.0, *) {
                    self.toolPicker.frameObscured(in: self.canvasView)
                    
                    self.canvasView.contentInset = UIEdgeInsets(
                        top: 0,
                        left: 0,
                        bottom: toolbarHeight + window.safeAreaInsets.bottom,
                        right: 0
                    )
                } else {
                    // For iOS 13
                    let obscuredInsets = UIEdgeInsets(
                        top: 0,
                        left: 0,
                        bottom: toolbarHeight + window.safeAreaInsets.bottom,
                        right: 0
                    )
                    self.canvasView.contentInset = obscuredInsets
                    self.toolPicker.frameObscured(in: window)
                }
                
                self.canvasView.becomeFirstResponder()
            }
        }
    }
    
    private func updateToolPickerVisibility() {
        DispatchQueue.main.async {
            if self.showToolPicker {
                // Full screen drawing mode
                self.setToolPickerFrameSize()
                self.canvasView.becomeFirstResponder()
                self.toolPicker.setVisible(true, forFirstResponder: self.canvasView)
            } else {
                // Hide drawing tools
                self.toolPicker.setVisible(false, forFirstResponder: self.canvasView)
            }
        }
    }
}

struct TextItemsLayer: View {
    @Binding var textItems: [TextItem]
    @Binding var editingTextItem: UUID?
    @Binding var editingText: String
    let contentWidth: CGFloat
    let contentHeight: CGFloat
    let onSave: () -> Void
    
    var body: some View {
        ZStack {
            ForEach(textItems) { item in
                if editingTextItem == item.id {
                    // Text editor with minimal style
                    ZStack(alignment: .center) {
                        TextField("", text: $editingText, onCommit: finishEditingText)
                            .font(.system(size: 16))
                            .foregroundColor(.black) // Metin rengini siyah yapma
                            .multilineTextAlignment(.center)
                            .padding(4)
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(4)
                            .frame(width: min(CGFloat(editingText.count * 12), 280))
                    }
                    .position(item.position)
                } else {
                    Text(item.text)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .position(item.position)
                        .onTapGesture {
                            startEditingText(item)
                        }
                        .gesture(textDragGesture(for: item))
                }
            }
        }
        .frame(width: contentWidth, height: contentHeight)
    }
    
    private func textDragGesture(for item: TextItem) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if let index = textItems.firstIndex(where: { $0.id == item.id }) {
                    let touchLocation = value.location
                    
                    // Constrain within bounds
                    let constrainedX = min(max(touchLocation.x, 50), contentWidth - 50)
                    let constrainedY = min(max(touchLocation.y, 50), contentHeight - 50)
                    
                    textItems[index].position = CGPoint(x: constrainedX, y: constrainedY)
                }
            }
            .onEnded { _ in
                onSave()
            }
    }
    
    private func startEditingText(_ item: TextItem) {
        editingTextItem = item.id
        editingText = item.text
    }
    
    private func finishEditingText() {
        if let id = editingTextItem, let index = textItems.firstIndex(where: { $0.id == id }) {
            textItems[index].text = editingText
            onSave()
        }
        editingTextItem = nil
    }
}

// ImageItemsLayer.swift - Resim düzenleme katmanı
struct ImageItemsLayer: View {
    @Binding var images: [ImageItem]
    let contentWidth: CGFloat
    let contentHeight: CGFloat
    let onSave: () -> Void
    
    var body: some View {
        ZStack {
            ForEach(images.indices, id: \.self) { index in
                let item = images[index]
                Image(uiImage: item.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .position(item.position)
                    .gesture(imageDragGesture(for: index))
            }
        }
        .frame(width: contentWidth, height: contentHeight)
    }
    
    private func imageDragGesture(for index: Int) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let touchLocation = value.location
                
                // Stay within bounds
                let constrainedX = min(max(touchLocation.x, 60), contentWidth - 60)
                let constrainedY = min(max(touchLocation.y, 60), contentHeight - 60)
                
                images[index].position = CGPoint(x: constrainedX, y: constrainedY)
            }
            .onEnded { _ in
                onSave()
            }
    }
}


struct PagePreviewView: View {
    let pageData: PageData
    
    var body: some View {
        ZStack {
            if !pageData.textItems.isEmpty || !pageData.images.isEmpty || !pageData.drawing.bounds.isEmpty {
                ZStack {
                    if !pageData.drawing.bounds.isEmpty {
                        DrawingPreview(drawing: pageData.drawing)
                            .padding(8)
                    }
                    
                    ForEach(pageData.textItems, id: \.id) { item in
                        Text(item.text)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .position(item.position)
                    }
                    
                    ForEach(pageData.images, id: \.id) { item in
                        Image(uiImage: item.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .position(item.position)
                    }
                }
                .frame(width: 350, height: 500)
            } else {
                Text("Empty page")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.black)
                    .kerning(0.5)
            }
        }
    }
}

// MARK: - CanvasView
struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var toolPicker: PKToolPicker
    @Binding var showingToolPicker: Bool
    @Binding var selectedPenColor: UIColor
    @Binding var selectedPenType: PKInkingTool.InkType
    @Binding var isInteractionEnabled: Bool
    
    init(canvasView: Binding<PKCanvasView>,
         toolPicker: Binding<PKToolPicker>,
         showingToolPicker: Binding<Bool>,
         selectedPenColor: Binding<UIColor>,
         selectedPenType: Binding<PKInkingTool.InkType>) {
        _canvasView = canvasView
        _toolPicker = toolPicker
        _showingToolPicker = showingToolPicker
        _selectedPenColor = selectedPenColor
        _selectedPenType = selectedPenType
        _isInteractionEnabled = .constant(true)  // Default value for legacy calls
    }
    
    init(canvasView: Binding<PKCanvasView>,
         toolPicker: Binding<PKToolPicker>,
         showingToolPicker: Binding<Bool>,
         selectedPenColor: Binding<UIColor>,
         selectedPenType: Binding<PKInkingTool.InkType>,
         isInteractionEnabled: Binding<Bool>) {
        _canvasView = canvasView
        _toolPicker = toolPicker
        _showingToolPicker = showingToolPicker
        _selectedPenColor = selectedPenColor
        _selectedPenType = selectedPenType
        _isInteractionEnabled = isInteractionEnabled
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
        
        canvasView.minimumZoomScale = 1.0
        canvasView.maximumZoomScale = 1.0
        canvasView.bouncesZoom = false
        
        toolPicker = PKToolPicker()
        toolPicker.addObserver(canvasView)
        
        let tool = PKInkingTool(selectedPenType, color: selectedPenColor, width: 5)
        canvasView.tool = tool
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.isUserInteractionEnabled = isInteractionEnabled
        
        if showingToolPicker {
            toolPicker.setVisible(true, forFirstResponder: uiView)
            uiView.becomeFirstResponder()
        } else {
            toolPicker.setVisible(false, forFirstResponder: uiView)
        }
    }
}

struct DrawingPreview: UIViewRepresentable {
    let drawing: PKDrawing
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.isUserInteractionEnabled = false
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawing = drawing
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.drawing = drawing
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
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
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct TextItem: Identifiable, Equatable {
    var id = UUID()
    var text: String
    var position: CGPoint
    
    static func == (lhs: TextItem, rhs: TextItem) -> Bool {
        return lhs.id == rhs.id &&
        lhs.text == rhs.text &&
        lhs.position.x == rhs.position.x &&
        lhs.position.y == rhs.position.y
    }
}

// ImageItem modeli
struct ImageItem: Identifiable, Equatable {
    var id = UUID()
    var image: UIImage
    var position: CGPoint
    
    static func == (lhs: ImageItem, rhs: ImageItem) -> Bool {
        return lhs.id == rhs.id &&
        lhs.position.x == rhs.position.x &&
        lhs.position.y == rhs.position.y
    }
}

// MARK: - TextItem Extension
extension TextItem: Codable {
    enum CodingKeys: String, CodingKey {
        case id, text, positionX, positionY
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
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

// PageData.swift - Sayfa veri modeli
struct PageData: Codable, Identifiable {
    var id = UUID()
    var title: String
    var drawingData: Data?
    var textItems: [TextItem]
    var imagesData: [ImageData]
    var showToolPicker: Bool = false
    var showImagePicker: Bool = false
    var showTextPlacementMode: Bool = false
    
    struct ImageData: Codable, Identifiable {
        var id = UUID()
        var imageData: Data
        var positionX: CGFloat
        var positionY: CGFloat
    }
    
    // Computed property for text placement mode
    var enterTextPlacementMode: Bool {
        get { return showTextPlacementMode }
        set { showTextPlacementMode = newValue }
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
        self.showToolPicker = false
        self.showImagePicker = false
        self.showTextPlacementMode = false
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
    
    // Helper functions for position normalization
    func normalizePosition(_ position: CGPoint, in size: CGSize) -> CGPoint {
        return CGPoint(
            x: position.x / size.width,
            y: position.y / size.height
        )
    }
    
    func denormalizePosition(_ normalizedPosition: CGPoint, to size: CGSize) -> CGPoint {
        return CGPoint(
            x: normalizedPosition.x * size.width,
            y: normalizedPosition.y * size.height
        )
    }
}
