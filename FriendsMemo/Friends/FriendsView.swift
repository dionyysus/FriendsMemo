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

struct BookView: View {
    let book: MemoryBook
    let offset: CGFloat
    
    var scale: CGFloat {
        let maxScale: CGFloat = 1.0
        let minScale: CGFloat = 0.85
        return max(minScale, maxScale - abs(offset) / 1200)
    }
    
    var opacity: CGFloat {
        return 1.0 - abs(offset) / 1500
    }
    
    func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: Date())
    }
    
    var body: some View {
        NavigationLink(destination: BookDetailView(book: book)) {
            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white)
                        .frame(width: 240, height: 280)
                        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                    
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(book.color.toSwiftUIColor())
                            .frame(height: 120)
                    }
                    .frame(width: 240, height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Spacer()
                        
                        Text(book.name)
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
                            
                            Text("\(formattedDate())")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.white.opacity(0.8))
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
            .opacity(opacity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FriendsView: View {
    @State private var isAddFriendModalPresented = false
    @State private var isShowingDeleteAlert = false
    @State private var books: [MemoryBook] = []
    @State private var bookToDelete: MemoryBook?
    
    // Format current date in DD.MM.YYYY format for footer
    func formattedCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: Date())
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.93, green: 0.91, blue: 0.88)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 25) {
                    Text("Memory Library")
                        .font(.system(size: 22, weight: .medium))
                        .kerning(1.5)
                        .foregroundColor(Color(red: 0.25, green: 0.25, blue: 0.25))
                        .padding(.top, 40)
                    
                    if books.isEmpty {
                        Spacer()
                        
                        VStack(spacing: 16) {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                .frame(width: 240, height: 280)
                            
                            Text("No memory books")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(Color.gray.opacity(0.7))
                                .kerning(0.5)
                        }
                        
                        Spacer()
                    } else {
                        
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
                                            
                                            BookView(
                                                book: book,
                                                offset: offsetFromCenter
                                            )
                                            .onTapGesture {
                                                hapticFeedback(style: .light)
                                            }
                                            .onLongPressGesture {
                                                bookToDelete = book
                                                isShowingDeleteAlert = true
                                                hapticFeedback(style: .medium)
                                            }
                                        }
                                        .frame(width: 240, height: 360)
                                    }
                                    
                                    // Right padding
                                    Spacer()
                                        .frame(width: geometry.size.width / 2 - 120)
                                }
                                .padding(.bottom, 20)
                            }
                        }
                        .padding(.top, 10)
                        .frame(height: 400)
                        
                        
                    }
                }
                .navigationBarItems(
                    leading: Button(action: {
                        if !books.isEmpty {
                            withAnimation(.spring()) {
                                isShowingDeleteAlert = true
                                hapticFeedback(style: .medium)
                            }
                        }
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(!books.isEmpty ? Color(red: 0.3, green: 0.3, blue: 0.3) : Color.gray.opacity(0.3))
                            .frame(width: 36, height: 36)
                    }
                        .disabled(books.isEmpty),
                    
                    trailing: Button(action: {
                        isAddFriendModalPresented.toggle()
                        hapticFeedback()
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                            .frame(width: 36, height: 36)
                    }
                )
                .alert(isPresented: $isShowingDeleteAlert) {
                    Alert(
                        title: Text("Delete Book"),
                        message: Text("Are you sure you want to delete this memory book?"),
                        primaryButton: .destructive(Text("Delete")) {
                            deleteBook()
                        },
                        secondaryButton: .cancel()
                    )
                }
                .sheet(isPresented: $isAddFriendModalPresented) {
                    AddNewMemoryBookView { newBook in
                        withAnimation(.spring()) {
                            books.append(newBook)
                            saveBooks()
                            hapticFeedback()
                        }
                    }
                }
                .onAppear {
                    loadBooks()
                }
            }
        }
    }
    
    func deleteBook() {
        if let bookToDelete = bookToDelete, let index = books.firstIndex(where: { $0.id == bookToDelete.id }) {
            withAnimation(.spring()) {
                books.remove(at: index)
                saveBooks()
            }
        } else if !books.isEmpty {
            withAnimation(.spring()) {
                books.removeFirst()
                saveBooks()
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
struct CodableColor: Codable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double
    
    init(_ color: Color) {
        if let components = UIColor(color).cgColor.components {
            self.red = Double(components[0])
            self.green = Double(components[1])
            self.blue = Double(components[2])
            self.opacity = Double(components.count > 3 ? components[3] : 1.0)
        } else {
            self.red = 0
            self.green = 0
            self.blue = 0
            self.opacity = 1.0
        }
    }
    
    func toSwiftUIColor() -> Color {
        return Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}
