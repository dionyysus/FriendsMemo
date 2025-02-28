//
//  FriendDetailView.swift
//  FriendsMemo
//
//  Created by Gizem Coskun on 27/02/25.
//

import SwiftUI

struct FriendDetailView: View {
    let friend: Friend
    @StateObject private var viewModel = FriendDetailViewModel()

    var body: some View {
        VStack {
            // Memory page view
            PageViewController(memories: $viewModel.memories)
                .navigationTitle("Memories of \(friend.name)")
                .edgesIgnoringSafeArea(.all)
        }
        .navigationBarItems(trailing: addButton)
    }
    
    // Add button in the navigation bar
    private var addButton: some View {
        NavigationLink(destination: AddMemoryView(viewModel: viewModel)) {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.blue)
        }
    }
}

// ViewModel for FriendDetailView
final class FriendDetailViewModel: ObservableObject {
    @Published var memories: [String] = ["Test memory", "Another test memory", ":)"]
}

struct PageViewController: UIViewControllerRepresentable {
    @Binding var memories: [String]

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: .pageCurl,
            navigationOrientation: .horizontal,
            options: nil
        )

        pageViewController.dataSource = context.coordinator
        pageViewController.setViewControllers(
            [context.coordinator.viewController(for: 0)],
            direction: .forward,
            animated: true
        )
        
        return pageViewController
    }

    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
        if let currentViewController = uiViewController.viewControllers?.first,
           let currentIndex = currentViewController.view.tag as? Int {
            // Update the view if the index is changed
        }
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource {
        var parent: PageViewController

        init(_ parent: PageViewController) {
            self.parent = parent
        }

        func viewController(for index: Int) -> UIViewController {
            guard index >= 0, index < parent.memories.count else {
                return UIViewController()
            }
            let memory = parent.memories[index]
            let memoryVC = MemoryPageController(memory: memory, index: index)
            return memoryVC
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let memoryVC = viewController as? MemoryPageController else {
                return nil
            }
            return memoryVC.index > 0 ? self.viewController(for: memoryVC.index - 1) : nil
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let memoryVC = viewController as? MemoryPageController else {
                return nil
            }
            return memoryVC.index < parent.memories.count - 1 ? self.viewController(for: memoryVC.index + 1) : nil
        }
    }
}

class MemoryPageController: UIHostingController<MemoryPage> {
    var memory: String
    var index: Int

    init(memory: String, index: Int) {
        self.memory = memory
        self.index = index
        super.init(rootView: MemoryPage(memory: memory))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct MemoryPage: View {
    let memory: String

    var body: some View {
        VStack {
            Text(memory)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

struct AddMemoryView: View {
    @ObservedObject var viewModel: FriendDetailViewModel
    @State private var newMemory: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            TextField("Add new memory", text: $newMemory)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                addMemory()
            }) {
                Text("Add")
                    .fontWeight(.bold)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .navigationTitle("Add Memory")
    }

    private func addMemory() {
        guard !newMemory.isEmpty else { return }
        viewModel.memories.append(newMemory)
        newMemory = ""
        presentationMode.wrappedValue.dismiss()
    }
}
