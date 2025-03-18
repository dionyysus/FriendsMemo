import SwiftUI

struct AddNewMemoryBookView: View {
    var onSave: (MemoryBook) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var bookName = ""
    @State private var selectedColor = Color(red: 0.2, green: 0.4, blue: 0.3)
    
    func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: Date())
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.95, blue: 0.93)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Text("New Memory")
                    .font(.system(size: 20, weight: .light))
                    .kerning(2)
                    .foregroundColor(Color(red: 0.25, green: 0.25, blue: 0.25))
                    .padding(.top, 20)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color(red: 0.98, green: 0.96, blue: 0.94))
                        .frame(width: 160, height: 220)
                        .offset(x: -1.5, y: -1.5)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(selectedColor)
                        .frame(width: 160, height: 220)
                        .overlay(
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.03),
                                            Color.white.opacity(0.05),
                                            Color.white.opacity(0.03)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: Color.black.opacity(0.25), radius: 3, x: 3, y: 3)
                    
                    Rectangle()
                        .fill(selectedColor.opacity(0.85))
                        .frame(width: 8, height: 220)
                        .offset(x: -76, y: 0)
                        .overlay(
                            Rectangle()
                                .fill(Color.black.opacity(0.15))
                                .frame(width: 1)
                                .offset(x: 4, y: 0),
                            alignment: .leading
                        )
                    
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 70)
                        
                        Text(bookName.isEmpty ? "Book Title" : bookName)
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(Color.white.opacity(0.8))
                            .tracking(1)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(width: 120)
                        
                        Spacer()
                  
                    }
                    .frame(width: 160, height: 220)
                }
                .padding(.vertical, 20)
                
                VStack(spacing: 25) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TITLE")
                            .font(.system(size: 10, weight: .medium))
                            .kerning(1.5)
                            .foregroundColor(Color.black.opacity(0.3))
                        
                        TextField("Enter Book Name", text: $bookName)
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(.black)
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(4)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            .accentColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Book Cover")
                            .font(.system(size: 10, weight: .medium))
                            .kerning(1.5)
                            .foregroundColor(Color.black.opacity(0.3))
                        
                        HStack(spacing: 15) {
                            ForEach([
                                Color(red: 0.2, green: 0.4, blue: 0.3),
                                Color(red: 0.6, green: 0.25, blue: 0.3),
                                Color(red: 0.25, green: 0.3, blue: 0.45),
                                Color(red: 0.5, green: 0.4, blue: 0.3),
                                Color(red: 0.2, green: 0.2, blue: 0.2),
                                Color(red: 0.4, green: 0.15, blue: 0.15)
                            ], id: \.self) { color in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 1)
                                        .fill(color)
                                        .frame(width: 30, height: 36)
                                        .overlay(
                                            Rectangle()
                                                .fill(color.opacity(0.85))
                                                .frame(width: 4)
                                                .overlay(
                                                    Rectangle()
                                                        .fill(Color.black.opacity(0.15))
                                                        .frame(width: 1)
                                                ),
                                            alignment: .leading
                                        )
                                        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 1, y: 1)
                                    
                                    if color == selectedColor {
                                        RoundedRectangle(cornerRadius: 1)
                                            .stroke(Color.white, lineWidth: 1.5)
                                            .frame(width: 30, height: 36)
                                    }
                                }
                                .onTapGesture {
                                    selectedColor = color
                                }
                            }
                            
                            ColorPicker("", selection: $selectedColor)
                                .labelsHidden()
                                .frame(width: 30, height: 36)
                        }
                    }
                }
                .padding(.horizontal, 25)
                
                Spacer()
                
                Button(action: saveBook) {
                    Text("Done")
                        .font(.system(size: 14, weight: .medium))
                        .kerning(1)
                        .padding()
                        .frame(width: 180)
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
    
    func toSwiftUIColor() -> Color {
        func createBookColor(r: Double, g: Double, b: Double) -> (Double, Double, Double) {
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
            
            // Kitaplara özgü daha mat ve derin renkler
            let newS = min(s * 0.95, 0.8)
            let newV = min(v * 0.85, 0.75)
            
            // HSV'den RGB'ye dönüşüm
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
        
        // Kitap benzeri renk oluştur
        let bookColor = createBookColor(r: red, g: green, b: blue)
        
        return Color(red: bookColor.0, green: bookColor.1, blue: bookColor.2)
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
    
    var shadowOffset: CGFloat {
        return max(3, min(8, 4 + abs(offset) / 150))
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color(red: 0.98, green: 0.96, blue: 0.94))
                        .frame(width: 220, height: 300)
                        .offset(x: -2, y: -2)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(book.color.toSwiftUIColor())
                        .frame(width: 220, height: 300)
                        .overlay(
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.03),
                                            Color.white.opacity(0.05),
                                            Color.white.opacity(0.03)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .overlay(
                            VStack {
                                Spacer()
                                    .frame(height: 20)
                                
                                Rectangle()
                                    .fill(Color.black.opacity(0.04))
                                    .frame(height: 0.5)
                                
                                Spacer()
                                    .frame(height: 260)
                                
                                Rectangle()
                                    .fill(Color.black.opacity(0.05))
                                    .frame(height: 0.5)
                                
                                Spacer()
                                    .frame(height: 20)
                            }
                        )
                    .shadow(color: Color.black.opacity(0.45), radius: 4, x: shadowOffset, y: shadowOffset)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: shadowOffset * 1.5, y: shadowOffset * 1.5)
                    
                    Rectangle()
                        .fill(book.color.toSwiftUIColor().opacity(0.85))
                        .frame(width: 12, height: 300)
                        .offset(x: -104, y: 0)
                        .overlay(
                            Rectangle()
                                .fill(Color.black.opacity(0.15))
                                .frame(width: 1.5)
                                .offset(x: 6, y: 0),
                            alignment: .leading
                        )
                    
                    Rectangle()
                        .fill(Color.black.opacity(0.1))
                        .frame(width: 3, height: 300)
                        .offset(x: -98, y: 0)
                    
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 100)
                
                        Text(book.name)
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(Color.white.opacity(0.8))
                            .tracking(1)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(width: 180)
                        
                        Spacer()

                    }
                    .frame(width: 220, height: 300)
                }
            }
            .rotation3DEffect(
                .degrees(Double(offset) / 30.0),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.3
            )
            .scaleEffect(scale)
            
            if isEditMode {
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: onDelete) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 24, height: 24)
                                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                                .overlay(
                                    Image(systemName: "minus")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(Color.black.opacity(0.7))
                                )
                        }
                        .offset(x: 12, y: -12)
                    }
                    
                    Spacer()
                }
                .frame(width: 220, height: 300)
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
    @State private var showLanguageSettings = false  // Dil ayarları için durum değişkeni
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.96, green: 0.95, blue: 0.93)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack {
                            Text(LocalizedStringKey("Memory Library"))
                                .font(.system(size: 20, weight: .light))
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                                .tracking(2)
                            
                            Spacer()
                            
                            // Dil değiştirme düğmesi
                            Button(action: {
                                showLanguageSettings = true
                            }) {
                                Image(systemName: "globe")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                            }
                            .padding(.trailing, 10)
                            
                            if !books.isEmpty {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isEditMode.toggle()
                                        hapticFeedback(style: .light)
                                    }
                                }) {
                                    Text(LocalizedStringKey(isEditMode ? "Done" : "Edit"))
                                        .font(.system(size: 14, weight: .light))
                                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                                        .tracking(1)
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 60)
                        .padding(.bottom, 40)
                    }
                    
                    ScrollView {
                        VStack(spacing: 25) {
                            if books.isEmpty {
                                Spacer(minLength: 100)
                                
                                VStack(spacing: 20) {
                                    Text("No memories yet")
                                        .font(.system(size: 16, weight: .light))
                                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                                        .tracking(1)
                                }
                                .padding(.vertical, 50)
                                
                                Spacer(minLength: 100)
                            } else {
                                GeometryReader { geometry in
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 35) {
                                            Spacer()
                                                .frame(width: geometry.size.width / 2 - 110)
                                            
                                            ForEach(books) { book in
                                                GeometryReader { itemGeometry in
                                                    let midX = itemGeometry.frame(in: .global).midX
                                                    let screenMidX = UIScreen.main.bounds.width / 2
                                                    let offsetFromCenter = midX - screenMidX
                                                    
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
                                                .frame(width: 220, height: 340)
                                            }
                                            
                                            Spacer()
                                                .frame(width: geometry.size.width / 2 - 110)
                                        }
                                        .padding(.vertical, 30)
                                    }
                                }
                                .frame(height: 380)
                                .padding(.top, 20)
                            }
                        }
                    }
                    
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            
                            
                            Button(action: {
                                if !isEditMode {
                                    isAddFriendModalPresented = true
                                    hapticFeedback()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 14, weight: .light))
                                    
                                    Text("Add Memory")
                                        .font(.system(size: 14, weight: .light))
                                        .tracking(0.5)
                                }
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color(red: 0.3, green: 0.3, blue: 0.3), lineWidth: 0.5)
                                )
                            }
                            .disabled(isEditMode)
                            .opacity(isEditMode ? 0.5 : 1.0)
                        }
                        .padding(.trailing, 30)
                        .padding(.bottom, 40)
                    }
                }
            }
            .sheet(isPresented: $showLanguageSettings) { 
                          LanguageSettingsView()
                      }
            .alert(isPresented: $isShowingDeleteAlert) {
                Alert(
                    title: Text("Delete"),
                    message: Text("Are you sure you want to delete this book?"),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteBook()
                    },
                    secondaryButton: .cancel(Text("Cancel"))
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
