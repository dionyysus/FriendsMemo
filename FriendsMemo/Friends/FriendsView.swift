import SwiftUI

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
    @State private var selectedBook = 0

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
                    TabView(selection: $selectedBook) {
                        ForEach(books.indices, id: \.self) { index in
                            NavigationLink(destination: FreeformNoteView()) {
                                BookView(book: books[index])
                                    .frame(width: 200, height: 330)
                                    .padding(.horizontal, -20)
                                    .tag(index)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 460)
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
            books.remove(at: selectedBook)
            selectedBook = max(0, selectedBook - 1)
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

struct BookView: View {
    let book: MemoryBook

    var body: some View {
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
                .multilineTextAlignment(.center)
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
