import SwiftUI

struct BookView: View {
    let book: MemoryBook

    var body: some View {
        NavigationLink(destination: BookDetailView(book: book)) {
            VStack(spacing: 8) {
                Image("BookCover")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 320, height: 420)
                    .colorMultiply(book.color.toSwiftUIColor())
                    .shadow(radius: 10)

                Text(book.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct BookDetailView: View {
    let book: MemoryBook
    @State private var currentPage = 0
    
    let pages = ["Page 1: Introduction", "Page 2: Memories", "Page 3: More Details"]

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)

            VStack {
                Text(book.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Text(pages[index])
                            .font(.title)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(book.color.toSwiftUIColor().opacity(0.2))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))

                Button(action: {
                    currentPage = (currentPage + 1) % pages.count
                }) {
                    Text("Next Page")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}


struct AddNewMemoryBookView: View {
    var onSave: (MemoryBook) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var bookName = ""
    @State private var selectedColor = Color.blue

    var body: some View {
        VStack {
            Text("Add New Book")
                .font(.title)
                .bold()
                .padding()

            TextField("Enter book name", text: $bookName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            ColorPicker("Select Book Color", selection: $selectedColor)
                .padding()

            Button(action: saveBook) {
                Text("Save")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }

    func saveBook() {
        let newBook = MemoryBook(name: bookName, color: CodableColor(selectedColor))
        onSave(newBook)
        presentationMode.wrappedValue.dismiss()
    }
}

struct FriendsView: View {
    @State private var isAddFriendModalPresented = false
    @State private var isShowingDeleteAlert = false
    @State private var books: [MemoryBook] = []
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Memory Library")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 10)
                
                if books.isEmpty {
                    VStack {
                        Image("BookCover")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 250)
                            .opacity(0.9)

                        Text("No Memories Yet")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                            .padding(.top, 30)
                    }
                    .frame(height: 400)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(books.indices, id: \.self) { index in
                                GeometryReader { geometry in
                                    let minX = geometry.frame(in: .global).minX
                                    let rotationAngle = Angle(degrees: Double(minX - 100) / -15.0)
                                    let scale = max(0.8, 1.0 - abs(Double(minX - 100)) / 500.0)  // Adjusted scale
                                    let opacity = max(0.6, 1.2 - abs(Double(minX - 100)) / 300.0) // Adjusted opacity
                                    let offsetX = minX / 15

                                    NavigationLink(destination: BookDetailView(book: books[index])) {
                                        BookView(book: books[index])
                                            .frame(width: 250, height: 300)
                                    }
                                        .rotation3DEffect(rotationAngle, axis: (x: 0, y: 1.0, z: 0))
                                        .scaleEffect(scale)
                                        .opacity(opacity)
                                        .offset(x: offsetX)
                                    
                                }
                                .frame(width: 250, height: 350)
                            }
                        }
                        .padding(.horizontal, 60)
                    }
                }
            }
            .navigationBarItems(
                leading: Button(action: { isShowingDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .font(.title2)
                        .foregroundColor(.black)
                },
                trailing: Button(action: { isAddFriendModalPresented.toggle() }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.black)
                }
            )
            .alert(isPresented: $isShowingDeleteAlert) {
                Alert(
                    title: Text("Delete Book"),
                    message: Text("Are you sure you want to delete this book?"),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteCurrentBook()
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $isAddFriendModalPresented) {
                AddNewMemoryBookView { newBook in
                    books.append(newBook)
                    saveBooks()
                }
            }
            .onAppear {
                loadBooks()
            }
        }
    }
    
    func deleteCurrentBook() {
        if !books.isEmpty {
            books.remove(at: 0)
            saveBooks()
        }
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
