//
//  SplashScreenView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 25.06.2026.
//

import SwiftUI

struct SplashScreenView: View {
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color("AppIconRed"),
                    Color("AppIconPink")
                ],
                startPoint: .top,
                endPoint: .bottom)
            .ignoresSafeArea()
            
            Image("AppIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 150)
            
        }
        .ignoresSafeArea(.all)
    }
}

#Preview {
    SplashScreenView()
}
