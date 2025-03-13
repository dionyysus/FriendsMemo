//
//  SplashScreenView.swift
//  FriendsMemo
//
//  Created by zakariaa belhimer on 10/03/25.
//

import SwiftUI

struct SplashScreenView: View {
    @Binding var showSplash: Bool
    @State private var opacity = 0.0
    @State private var scaleEffect = 0.9
    @State private var rotationDegree = -5.0
    
    var body: some View {
        ZStack {
            Color(red: 0.93, green: 0.91, blue: 0.88)
                .edgesIgnoringSafeArea(.all)
            
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white)
                    .frame(width: 120, height: 180)
                    .shadow(color: Color.black.opacity(0.12), radius: 8, x: 4, y: 4)
                
                Rectangle()
                    .fill(Color(red: 0.3, green: 0.3, blue: 0.3))
                    .frame(width: 10, height: 180)
                    .offset(x: -55)
                
                Text("Memories")
                    .font(.system(size: 12, weight: .thin))
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                    .offset(y: -15)
            }
            .scaleEffect(scaleEffect)
            .rotationEffect(.degrees(rotationDegree))
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(Animation.easeOut(duration: 0.8)) {
                opacity = 1.0
                scaleEffect = 1.0
                rotationDegree = 0.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeIn(duration: 0.5)) {
                    opacity = 0.0
                    scaleEffect = 1.1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showSplash = false
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
