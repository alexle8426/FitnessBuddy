//
//  JournalEntry.swift
//  Fitness Buddy
//
//  Created by Codex on 2026-06-22.
//

import Foundation
import SwiftData

@Model
final class JournalEntry {
    var id: UUID
    var sectionRawValue: String
    var text: String
    var calories: Int?
    var proteinGrams: Int?
    var carbsGrams: Int?
    var fatGrams: Int?
    var statusRawValue: String
    var entryModeRawValue: String
    var estimationBias: Double
    var loggedAt: Date
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        section: JournalSection,
        text: String,
        calories: Int? = nil,
        proteinGrams: Int? = nil,
        carbsGrams: Int? = nil,
        fatGrams: Int? = nil,
        status: JournalEntryStatus = .thinking,
        entryMode: JournalEntryMode = .auto,
        estimationBias: Double = 0,
        loggedAt: Date = .now,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.sectionRawValue = section.rawValue
        self.text = text
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbsGrams = carbsGrams
        self.fatGrams = fatGrams
        self.statusRawValue = status.rawValue
        self.entryModeRawValue = entryMode.rawValue
        self.estimationBias = estimationBias
        self.loggedAt = loggedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum JournalEntryStatus: String, Codable, CaseIterable {
    case thinking
    case estimated
    case manual
    case needsInfo
}

enum JournalEntryMode: String, Codable, CaseIterable {
    case auto
    case manual
}

extension JournalEntry {
    var section: JournalSection {
        JournalSection(rawValue: sectionRawValue) ?? .notes
    }

    var status: JournalEntryStatus {
        JournalEntryStatus(rawValue: statusRawValue) ?? .thinking
    }

    var entryMode: JournalEntryMode {
        JournalEntryMode(rawValue: entryModeRawValue) ?? .auto
    }

    var hasNutrition: Bool {
        calories != nil || proteinGrams != nil || carbsGrams != nil || fatGrams != nil
    }
}
