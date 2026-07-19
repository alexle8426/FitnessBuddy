//
//  Fitness_BuddyApp.swift
//  Fitness Buddy
//
//  Created by Alex Le on 2026-05-26.
//

import SwiftUI
import SwiftData

@main
struct Fitness_BuddyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            UserProfile.self,
            FitnessGoal.self,
            MacroTarget.self,
            SavedFood.self,
            JournalEntry.self
        ])
    }
}
