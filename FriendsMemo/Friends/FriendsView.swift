import SwiftUI

struct AddNewMemoryBookView: View {
    var onSave: (MemoryBook) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var bookName = ""
    @State private var selectedColor = Color.blue
    
    func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: Date())
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.93, green: 0.91, blue: 0.88)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Text("New Memory")
                    .font(.system(size: 22, weight: .medium))
                    .kerning(1.5)
                    .foregroundColor(Color(red: 0.25, green: 0.25, blue: 0.25))
                    .padding(.top, 20)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white)
                        .frame(width: 240, height: 280)
                        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                    
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(selectedColor)
                            .frame(height: 120)
                    }
                    .frame(width: 240, height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Spacer()
                        
                        Text(bookName.isEmpty ? "Book Title" : bookName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)
                            .frame(width: 240, alignment: .leading)
                        
                        HStack {
                            Text("Memory Book")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Spacer()
                            
                            Text(formattedDate())
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .frame(width: 240, height: 280, alignment: .bottom)
                }
                .padding(.vertical, 20)
                
                VStack(spacing: 25) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TITLE")
                            .font(.system(size: 10, weight: .medium))
                            .kerning(1.5)
                            .foregroundColor(Color.black.opacity(0.2))
                        
                        TextField("Enter book name", text: $bookName)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(4)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            .accentColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("COLOR")
                            .font(.system(size: 10, weight: .medium))
                            .kerning(1.5)
                            .foregroundColor(Color.gray.opacity(0.8))
                        
                        HStack(spacing: 15) {
                            ForEach([
                                Color.blue,
                                Color.red,
                                Color.green,
                                Color.orange,
                                Color.purple,
                                Color.pink
                            ], id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(color == selectedColor ? Color.white : Color.clear, lineWidth: 2)
                                            .padding(3)
                                    )
                                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                            }
                            
                            // Standard color picker as the last option
                            ColorPicker("", selection: $selectedColor)
                                .labelsHidden()
                                .frame(width: 30, height: 30)
                        }
                    }
                }
                .padding(.horizontal, 25)
                
                Spacer()
                
                // Save button with minimal style
                Button(action: saveBook) {
                    Text("SAVE")
                        .font(.system(size: 14, weight: .medium))
                        .kerning(1)
                        .padding()
                        .frame(width: 200)
                        .background(bookName.isEmpty ? Color.gray.opacity(0.3) : selectedColor)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
                .disabled(bookName.isEmpty)
                .padding(.bottom, 40)
                
            }
            .padding()
        }
        .overlay(
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                    .padding(10)
            }
                .padding(12),
            alignment: .topTrailing
        )
    }
    
    func saveBook() {
        guard !bookName.isEmpty else { return }
        let newBook = MemoryBook(name: bookName, color: CodableColor(selectedColor))
        onSave(newBook)
        presentationMode.wrappedValue.dismiss()
    }
}

import SwiftUI

struct CodableColor: Codable {
    var red: Double
    var green: Double
    var blue: Double
    
    init(_ color: Color) {
        if let components = UIColor(color).cgColor.components {
            self.red = Double(components[0])
            self.green = Double(components[1])
            self.blue = Double(components[2])
        } else {
            self.red = 0
            self.green = 0
            self.blue = 0
        }
    }
    
    // Renkleri çok daha canlı hale getirmek için toSwiftUIColor fonksiyonunu güncelliyoruz
    func toSwiftUIColor() -> Color {
        // RGB değerlerini HSV'ye çevirip saturasyonu ve parlaklığı artıran yardımcı fonksiyon
        func enhanceColor(r: Double, g: Double, b: Double) -> (Double, Double, Double) {
            // RGB to HSV dönüşümü
            let cmax = max(r, max(g, b))
            let cmin = min(r, min(g, b))
            let delta = cmax - cmin
            
            var h: Double = 0
            if delta != 0 {
                if cmax == r {
                    h = 60 * (((g - b) / delta).truncatingRemainder(dividingBy: 6))
                } else if cmax == g {
                    h = 60 * (((b - r) / delta) + 2)
                } else {
                    h = 60 * (((r - g) / delta) + 4)
                }
                if h < 0 {
                    h += 360
                }
            }
            
            let s: Double = cmax == 0 ? 0 : delta / cmax
            let v: Double = cmax
            
            // Saturasyonu daha fazla artır (2.0 ile çarp)
            let newS = min(s * 2.0, 1.0)
            // Parlaklığı daha güçlü artır
            let newV = min(v * 1.2, 1.0)
            
            // HSV to RGB dönüşümü
            let c = newV * newS
            let x = c * (1 - abs((h / 60).truncatingRemainder(dividingBy: 2) - 1))
            let m = newV - c
            
            var r1, g1, b1: Double
            
            if h < 60 {
                r1 = c; g1 = x; b1 = 0
            } else if h < 120 {
                r1 = x; g1 = c; b1 = 0
            } else if h < 180 {
                r1 = 0; g1 = c; b1 = x
            } else if h < 240 {
                r1 = 0; g1 = x; b1 = c
            } else if h < 300 {
                r1 = x; g1 = 0; b1 = c
            } else {
                r1 = c; g1 = 0; b1 = x
            }
            
            return (r1 + m, g1 + m, b1 + m)
        }
        
        // Renkleri geliştir
        let enhancedColors = enhanceColor(r: red, g: green, b: blue)
        
        return Color(red: enhancedColors.0, green: enhancedColors.1, blue: enhancedColors.2)
    }
}

struct BookView: View {
    let book: MemoryBook
    let offset: CGFloat
    var isEditMode: Bool
    var onDelete: () -> Void
    
    var scale: CGFloat {
        let maxScale: CGFloat = 1.0
        let minScale: CGFloat = 0.85
        return max(minScale, maxScale - abs(offset) / 1200)
    }
    
    func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: Date())
    }
    
    var body: some View {
        // The ZStack is now INSIDE the NavigationLink
        ZStack {
            // This is now a regular button design that's part of the navigation link
            VStack(spacing: 16) {
                ZStack {
                    // Base card with subtle shadow
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(red: 0.98, green: 0.97, blue: 0.95))
                        .frame(width: 240, height: 280)
                    
                    VStack {
                        Spacer()
                        // Vibrant gradient for the color section
                        LinearGradient(
                            gradient: Gradient(colors: [
                                book.color.toSwiftUIColor(),
                                book.color.toSwiftUIColor()
                            ]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.clear
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 100)
                    }
                    .frame(width: 240, height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Spacer()
                        
                        Text(book.name)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)
                            .frame(width: 240, alignment: .leading)
                            // Add shadow for better text visibility
                            .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 1)
                        
                        HStack {
                            Text("Memory Book")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.white.opacity(0.8))
                                // Add shadow for better text visibility
                                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0, y: 1)
                            
                            Spacer()
                            
                            Text("\(formattedDate())")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.white.opacity(0.8))
                                // Add shadow for better text visibility
                                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0, y: 1)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .frame(width: 240, height: 280, alignment: .bottom)
                }
            }
            .rotation3DEffect(
                .degrees(Double(offset) / 30.0),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.3
            )
            .scaleEffect(scale)
            
            // Delete button - only shown in edit mode
            if isEditMode {
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: onDelete) {
                            Circle()
                                .stroke(Color.black.opacity(0.4), lineWidth: 1)
                                .frame(width: 22, height: 22)
                                .background(Circle().fill(Color.white.opacity(0.6)))
                                .overlay(
                                    Image(systemName: "minus")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(Color.black.opacity(0.7))
                                )
                        }
                        .offset(x: 10, y: -10)
                    }
                    
                    Spacer()
                }
                .frame(width: 240, height: 280)
            }
        }
    }
}

struct FriendsView: View {
    @State private var isAddFriendModalPresented = false
    @State private var isShowingDeleteAlert = false
    @State private var books: [MemoryBook] = []
    @State private var bookToDelete: MemoryBook?
    @State private var isEditMode = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background - soft beige
                Color(red: 0.94, green: 0.92, blue: 0.89)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 0) {
                        HStack {
                            Text("Memory Library")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                                .tracking(1)
                            
                            Spacer()
                            
                            // Edit Button - shown only when books exist
                            if !books.isEmpty {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isEditMode.toggle()
                                        hapticFeedback(style: .light)
                                    }
                                }) {
                                    Text(isEditMode ? "Done" : "Edit")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                                        .tracking(0.5)
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 60)
                        .padding(.bottom, 40)
                    }
                    
                    // Main Content
                    ScrollView {
                        VStack(spacing: 25) {
                            if books.isEmpty {
                                Spacer(minLength: 100)
                                
                                VStack(spacing: 20) {
                                    Text("No memories")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                                        .tracking(1)
                                }
                                .padding(.vertical, 50)
                                
                                Spacer(minLength: 100)
                            } else {
                                // Books ScrollView
                                GeometryReader { geometry in
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 25) {
                                            // Left padding
                                            Spacer()
                                                .frame(width: geometry.size.width / 2 - 120)
                                            
                                            ForEach(books) { book in
                                                GeometryReader { itemGeometry in
                                                    let midX = itemGeometry.frame(in: .global).midX
                                                    let screenMidX = UIScreen.main.bounds.width / 2
                                                    let offsetFromCenter = midX - screenMidX
                                                    
                                                    // In edit mode, don't use NavigationLink
                                                    if isEditMode {
                                                        BookView(
                                                            book: book,
                                                            offset: offsetFromCenter,
                                                            isEditMode: isEditMode,
                                                            onDelete: {
                                                                bookToDelete = book
                                                                isShowingDeleteAlert = true
                                                                hapticFeedback(style: .light)
                                                            }
                                                        )
                                                    } else {
                                                        // When not in edit mode, use NavigationLink
                                                        NavigationLink(destination: BookDetailView(book: book)) {
                                                            BookView(
                                                                book: book,
                                                                offset: offsetFromCenter,
                                                                isEditMode: isEditMode,
                                                                onDelete: {
                                                                    bookToDelete = book
                                                                    isShowingDeleteAlert = true
                                                                    hapticFeedback(style: .light)
                                                                }
                                                            )
                                                        }
                                                        .buttonStyle(PlainButtonStyle())
                                                    }
                                                }
                                                .frame(width: 240, height: 320)
                                            }
                                            
                                            // Right padding
                                            Spacer()
                                                .frame(width: geometry.size.width / 2 - 120)
                                        }
                                        .padding(.vertical, 30)
                                    }
                                }
                                .frame(height: 350)
                                .padding(.top, 20)
                            }
                        }
                    }
                    
                    // Footer with separated buttons
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            // Add Memory button - always shown with the same text
                            Button(action: {
                                if !isEditMode {
                                    isAddFriendModalPresented = true
                                    hapticFeedback()
                                }
                            }) {
                                Text("Add Memory")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                                    .tracking(0.5)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color(red: 0.3, green: 0.3, blue: 0.3), lineWidth: 0.5)
                                    )
                            }
                            .disabled(isEditMode) // Disable when in edit mode
                            .opacity(isEditMode ? 0.5 : 1.0) // Visually indicate disabled state
                            
//                            // Cancel Edit button - only shown in edit mode
//                            if isEditMode {
//                                Button(action: {
//                                    withAnimation {
//                                        isEditMode = false
//                                    }
//                                }) {
//                                    Text("Cancel")
//                                        .font(.system(size: 14, weight: .regular))
//                                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
//                                        .tracking(0.5)
//                                        .padding(.horizontal, 16)
//                                        .padding(.vertical, 8)
//                                        .overlay(
//                                            RoundedRectangle(cornerRadius: 4)
//                                                .stroke(Color(red: 0.3, green: 0.3, blue: 0.3), lineWidth: 0.5)
//                                        )
//                                }
//                                .padding(.leading, 12)
//                            }
                        }
                        .padding(.trailing, 30)
                        .padding(.bottom, 40)
                    }
                }
            }
            .alert(isPresented: $isShowingDeleteAlert) {
                Alert(
                    title: Text("Delete Memory"),
                    message: Text("Are you sure you want to delete this memory?"),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteBook()
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $isAddFriendModalPresented) {
                AddNewMemoryBookView { newBook in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        books.append(newBook)
                        saveBooks()
                        hapticFeedback()
                    }
                }
            }
            .onAppear {
                loadBooks()
            }
            .navigationBarHidden(true)
        }
    }
    
    func deleteBook() {
        if let bookToDelete = bookToDelete, let index = books.firstIndex(where: { $0.id == bookToDelete.id }) {
            withAnimation(.easeInOut(duration: 0.3)) {
                books.remove(at: index)
                saveBooks()
                
                // If we deleted all books, exit edit mode
                if books.isEmpty {
                    isEditMode = false
                }
            }
        }
        self.bookToDelete = nil
    }
    
    func saveBooks() {
        if let encoded = try? JSONEncoder().encode(books) {
            UserDefaults.standard.set(encoded, forKey: "books")
        }
    }
    
    func loadBooks() {
        if let data = UserDefaults.standard.data(forKey: "books"),
           let decoded = try? JSONDecoder().decode([MemoryBook].self, from: data) {
            books = decoded
        }
    }
    
    func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

struct MemoryBook: Identifiable, Codable {
    var id = UUID()
    var name: String
    var color: CodableColor
}

