//
//  FitnessGoal.swift
//  Fitness Buddy
//
//  Created by Codex on 2026-05-30.
//

import Foundation
import SwiftData

@Model
final class FitnessGoal {
    var id: UUID
    var goalTypeRawValue: String
    var startingWeightValue: Double
    var startingWeightUnitRawValue: String
    var targetWeightChangeValue: Double?
    var targetWeightChangeUnitRawValue: String?
    var targetDate: Date?
    var calculatedWeeklyRate: Double?
    var isAggressivePace: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        goalType: GoalType,
        startingWeightValue: Double,
        startingWeightUnit: WeightUnit,
        targetWeightChangeValue: Double? = nil,
        targetWeightChangeUnit: WeightUnit? = nil,
        targetDate: Date? = nil,
        calculatedWeeklyRate: Double? = nil,
        isAggressivePace: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.goalTypeRawValue = goalType.rawValue
        self.startingWeightValue = startingWeightValue
        self.startingWeightUnitRawValue = startingWeightUnit.rawValue
        self.targetWeightChangeValue = targetWeightChangeValue
        self.targetWeightChangeUnitRawValue = targetWeightChangeUnit?.rawValue
        self.targetDate = targetDate
        self.calculatedWeeklyRate = calculatedWeeklyRate
        self.isAggressivePace = isAggressivePace
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
