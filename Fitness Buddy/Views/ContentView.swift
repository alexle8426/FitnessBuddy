//
//  ContentView.swift
//  Fitness Buddy
//
//  Created by Alex Le on 2026-05-26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DailyLogView()
                .tabItem {
                    Label("Nutrition", systemImage: "fork.knife")
                }

            WorkoutsView()
                .tabItem {
                    Label("Workouts", systemImage: "figure.strengthtraining.traditional")
                }
        }
        .tint(Color(hex: 0x101010))
    }
}

#Preview {
    ContentView()
}
