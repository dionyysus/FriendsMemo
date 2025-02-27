//
//  FriendDetailView.swift
//  FriendsMemo
//
//  Created by Gizem Coskun on 27/02/25.
//

import SwiftUI
import UIKit

struct FriendDetailView: View {
    let friend: Friend
    @State private var memories: [String] = ["İlk tanışmamız 🥰", "Birlikte en güzel gün!", "Unutulmaz tatil anımız"]

    var body: some View {
        PageViewController(memories: memories)
            .navigationTitle("Memories of \(friend.name)")
            .edgesIgnoringSafeArea(.all)
    }
}

struct PageViewController: UIViewControllerRepresentable {
    var memories: [String]

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
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

    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {}

    class Coordinator: NSObject, UIPageViewControllerDataSource {
        var parent: PageViewController

        init(_ parent: PageViewController) {
            self.parent = parent
        }
        
        // Fonksiyon adını değiştirmeden self kullanarak çağırıyoruz:
        func viewController(for index: Int) -> UIViewController {
            let vc = UIHostingController(rootView: MemoryPage(memory: parent.memories[index]))
            vc.view.backgroundColor = .white // Sayfa arka planı
            vc.view.tag = index
            return vc
        }

        func presentationIndex(for pageViewController: UIPageViewController) -> Int {
            0
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            let index = viewController.view.tag
            return index > 0 ? self.viewController(for: index - 1) : nil
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            let index = viewController.view.tag
            return index < parent.memories.count - 1 ? self.viewController(for: index + 1) : nil
        }
    }
}

// Sayfa içeriği tasarımı
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
