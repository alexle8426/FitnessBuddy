//
//  MacroTarget.swift
//  Fitness Buddy
//
//  Created by Codex on 2026-05-30.
//

import Foundation
import SwiftData

@Model
final class MacroTarget {
    var id: UUID
    var dailyCalories: Int
    var proteinGrams: Int
    var carbsGrams: Int
    var fatGrams: Int
    var isCustom: Bool
    var calculationMethodRawValue: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        dailyCalories: Int,
        proteinGrams: Int,
        carbsGrams: Int,
        fatGrams: Int,
        isCustom: Bool = false,
        calculationMethod: CalculationMethod = .formula,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.dailyCalories = dailyCalories
        self.proteinGrams = proteinGrams
        self.carbsGrams = carbsGrams
        self.fatGrams = fatGrams
        self.isCustom = isCustom
        self.calculationMethodRawValue = calculationMethod.rawValue
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
