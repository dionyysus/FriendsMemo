//
//  OnboardingView.swift
//  FriendsMemo
//
//  Created by zakariaa belhimer on 17/03/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var currentPage = 0
    
    // Define our 4 onboarding pages with content specific to memory book features
    let onboardingPages: [OnboardingPage] = [
        OnboardingPage(
            image: "create_book",
            title: "Create Memory Books",
            description: "Design personalized memory books with custom colors to organize your special moments"
        ),
        OnboardingPage(
            image: "add_pages",
            title: "Add Pages to Your Books",
            description: "Build your collection by adding new pages to capture every important memory"
        ),
        OnboardingPage(
            image: "draw_memories",
            title: "Draw Your Memories",
            description: "Express yourself through drawing directly on your memory pages"
        ),
        OnboardingPage(
            image: "add_content",
            title: "Add Text and Images",
            description: "Enhance your memories with photos and text to tell your complete story"
        )
    ]
    
    // Main app design colors
    private let backgroundColor = Color(red: 0.93, green: 0.91, blue: 0.88)
    private let textColor = Color(red: 0.25, green: 0.25, blue: 0.25)
    private let secondaryTextColor = Color(red: 0.4, green: 0.4, blue: 0.4)
    
    // Page theme colors
    private let pageColors: [Color] = [
        Color.blue,
        Color.green,
        Color.orange,
        Color.red
    ]
    
    var body: some View {
        ZStack {
            // Using the same background color as your main app
            backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button(action: {
                        hasSeenOnboarding = true
                    }) {
                        Text("Skip")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(textColor)
                            .padding()
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Main content
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        VStack(spacing: 30) {
                            // Image with card-like container (matching your app's card style)
                            ZStack {
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: 350, height: 420)
                                    .cornerRadius(4)
                                    .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                                
                               
                                // Illustration
                                Image(onboardingPages[index].image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 280, height: 280)
                                    .padding(.bottom, 60)
                                
                                // Page number at bottom corner
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
                                .frame(width: 350, height: 420)
                            }
                            
                            // Title and description (matching your app's typography)
                            VStack(spacing: 16) {
                                Text(onboardingPages[index].title)
                                    .font(.system(size: 20, weight: .medium))
                                    .kerning(1)
                                    .foregroundColor(textColor)
                                    .multilineTextAlignment(.center)
                                
                                Text(onboardingPages[index].description)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(secondaryTextColor)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 30)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.top, 10)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 580)
                
                Spacer()
                
                // Custom page indicator dots (matching your design aesthetic)
                HStack(spacing: 8) {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? pageColors[index] : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.vertical, 20)
                
                // Continue/Get Started button (matching your app's button style)
                Button(action: {
                    if currentPage == onboardingPages.count - 1 {
                        hasSeenOnboarding = true
                    } else {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                }) {
                    Text(currentPage == onboardingPages.count - 1 ? "Get Started" : "Continue")
                        .font(.system(size: 14, weight: .medium))
                        .kerning(1)
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .padding()
                        .background(pageColors[currentPage])
                        .cornerRadius(4)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }
}

struct OnboardingPage {
    let image: String
    let title: String
    let description: String
}

// Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
