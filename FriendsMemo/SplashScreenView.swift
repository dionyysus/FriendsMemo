//
//  SplashScreenView.swift
//  FriendsMemo
//
//  Created by zakariaa belhimer on 10/03/25.
//

import SwiftUI

struct SplashScreenView: View {
    @Binding var showSplash: Bool
    @State private var scaleEffect = 1.0
    @State private var opacity = 1.0
    @State private var stars = [Star]()

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ForEach(stars) { star in
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: star.size, height: star.size)
                    .position(star.position)
                    .opacity(star.opacity)
                    .animation(
                        Animation.easeInOut(duration: star.duration)
                            .repeatForever(autoreverses: true)
                    )
            }
            
            VStack {
                Image("SplashNeon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 300)
                    .shadow(color: .pink.opacity(0.7), radius: 20) // 🌟 Ombra luminosa
                    .scaleEffect(scaleEffect)
                    .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true))
                    .onAppear {
                        scaleEffect = 1.1
                    }
                
                Text("Every memory is a page in our story.") // ✨ Frase animata
                    .font(.title2)
                    .foregroundColor(.white)
                    .opacity(opacity)
                    .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true))
                    .onAppear {
                        opacity = 0.5
                    }
            }
        }
        .onAppear {
            generateStars()

            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation(.easeOut(duration: 1.5)) {
                    showSplash = false
                }
            }
        }
    }
    
    func generateStars() {
        for _ in 0..<30 {
            let size = CGFloat.random(in: 2...6)
            let position = CGPoint(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
            )
            let duration = Double.random(in: 2...4)
            let opacity = Double.random(in: 0.2...1)

            stars.append(Star(size: size, position: position, duration: duration, opacity: opacity))
        }
    }
}
struct Star: Identifiable {
    let id = UUID()
    let size: CGFloat
    let position: CGPoint
    let duration: Double
    let opacity: Double
}
struct ParticleEffectView: View {
    @State private var particles = Array(repeating: CGPoint(x: 0, y: 0), count: 20)

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<particles.count, id: \.self) { index in
                Circle()
                    .fill(Color.blue.opacity(0.5))
                    .frame(width: 6, height: 6)
                    .position(particles[index])
                    .onAppear {
                        withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
                            particles[index] = CGPoint(x: CGFloat.random(in: 0...geo.size.width),
                                                       y: CGFloat.random(in: 0...geo.size.height))
                        }
                    }
            }
        }
    }
}

struct PageTurnEffect: View {
    @State private var angle: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)

                Rectangle()
                    .fill(Color.white)
                    .shadow(radius: 10)
                    .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0), anchor: .trailing)
                    .frame(width: geometry.size.width)
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 1.5)) {
                            angle = -180
                        }
                    }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView(showSplash: .constant(true))
    }
}
