//
//  NutritionCalculator.swift
//  Fitness Buddy
//
//  Created by Codex on 2026-05-30.
//

import Foundation

struct NutritionCalculationResult {
    let dailyCalories: Int
    let proteinGrams: Int
    let carbsGrams: Int
    let fatGrams: Int
    let proteinPercent: Int
    let carbsPercent: Int
    let fatPercent: Int
    let weeklyRate: Double
    let isAggressivePace: Bool
}

struct NutritionCalculator {
    func calculate(
        goalType: GoalType,
        age: Int,
        sex: Sex,
        heightValue: Double,
        heightUnit: HeightUnit,
        weightValue: Double,
        weightUnit: WeightUnit,
        activityLevel: ActivityLevel,
        targetWeightChangeValue: Double,
        targetDate: Date,
        now: Date = .now
    ) -> NutritionCalculationResult {
        let heightCentimeters = convertHeightToCentimeters(heightValue, unit: heightUnit)
        let weightKilograms = convertWeightToKilograms(weightValue, unit: weightUnit)
        let weeks = max(targetDate.timeIntervalSince(now) / 604_800, 1)
        let weeklyRate = goalType == .bodyRecomposition ? 0 : abs(targetWeightChangeValue) / weeks
        let weeklyRateInPounds = weightUnit == .pounds ? weeklyRate : weeklyRate * 2.20462

        let baseMetabolicRate = calculateBMR(
            age: age,
            sex: sex,
            heightCentimeters: heightCentimeters,
            weightKilograms: weightKilograms
        )

        let maintenanceCalories = baseMetabolicRate * activityLevel.multiplier
        let calorieAdjustment = calorieAdjustment(
            goalType: goalType,
            weeklyRateInPounds: weeklyRateInPounds
        )
        let rawTargetCalories = maintenanceCalories + calorieAdjustment
        let upperGuardrail = goalType == .buildMuscle ? maintenanceCalories + 400 : maintenanceCalories + 150
        let targetCalories = min(max(Int(rawTargetCalories.rounded()), 1_200), Int(upperGuardrail.rounded()))
        let split = macroSplit(for: goalType)
        let protein = Int(((Double(targetCalories) * Double(split.protein) / 100) / 4).rounded())
        let carbs = Int(((Double(targetCalories) * Double(split.carbs) / 100) / 4).rounded())
        let fat = Int(((Double(targetCalories) * Double(split.fat) / 100) / 9).rounded())
        let aggressiveLimit = goalType == .buildMuscle ? 0.75 : 1.25

        return NutritionCalculationResult(
            dailyCalories: targetCalories,
            proteinGrams: protein,
            carbsGrams: carbs,
            fatGrams: fat,
            proteinPercent: split.protein,
            carbsPercent: split.carbs,
            fatPercent: split.fat,
            weeklyRate: weeklyRate,
            isAggressivePace: goalType == .bodyRecomposition ? false : weeklyRate > aggressiveLimit
        )
    }

    private func calculateBMR(
        age: Int,
        sex: Sex,
        heightCentimeters: Double,
        weightKilograms: Double
    ) -> Double {
        let base = (10 * weightKilograms) + (6.25 * heightCentimeters) - (5 * Double(age))

        switch sex {
        case .male:
            return base + 5
        case .female:
            return base - 161
        case .preferNotToSay:
            return base - 78
        }
    }

    private func calorieAdjustment(goalType: GoalType, weeklyRateInPounds: Double) -> Double {
        switch goalType {
        case .loseWeight:
            return -weeklyRateInPounds * 500
        case .buildMuscle:
            return min(weeklyRateInPounds * 500, 350)
        case .bodyRecomposition:
            return -100
        }
    }

    private func macroSplit(for goalType: GoalType) -> (protein: Int, carbs: Int, fat: Int) {
        switch goalType {
        case .loseWeight:
            return (35, 35, 30)
        case .buildMuscle:
            return (30, 45, 25)
        case .bodyRecomposition:
            return (35, 35, 30)
        }
    }

    private func convertHeightToCentimeters(_ value: Double, unit: HeightUnit) -> Double {
        switch unit {
        case .centimeters:
            return value
        case .feetInches:
            return value * 2.54
        }
    }

    private func convertWeightToKilograms(_ value: Double, unit: WeightUnit) -> Double {
        switch unit {
        case .kilograms:
            return value
        case .pounds:
            return value * 0.453592
        }
    }
}

private extension ActivityLevel {
    var multiplier: Double {
        switch self {
        case .sedentary:
            return 1.2
        case .lightlyActive:
            return 1.375
        case .moderatelyActive:
            return 1.55
        case .veryActive:
            return 1.725
        }
    }
}
