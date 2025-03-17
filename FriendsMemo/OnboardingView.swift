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
    
    let onboardingPages: [OnboardingPage] = [
        OnboardingPage(imageName: "BookCover", title: "Find the Best Memories", description: "Save your most precious moments and organize them easily."),
        OnboardingPage(imageName: "BookCover", title: "Customize Your Books", description: "Choose unique colors and personalize your memory books."),
        OnboardingPage(imageName: "BookCover", title: "Preserve your special moments", description: "Let your friends see and interact with your favorite stories."),
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.93, green: 0.98, blue: 0.95)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        OnboardingPageView(page: onboardingPages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // INDICATORI (DOTS)
                HStack {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.vertical, 20)
                
                // BOTTONI SKIP / NEXT
                HStack {
                    Button("SKIP") {
                        hasSeenOnboarding = true
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button(currentPage == onboardingPages.count - 1 ? "START" : "NEXT") {
                        if currentPage == onboardingPages.count - 1 {
                            hasSeenOnboarding = true
                        } else {
                            currentPage += 1
                        }
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.green)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
            
            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text(page.description)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct OnboardingPage {
    let imageName: String
    let title: String
    let description: String
}
