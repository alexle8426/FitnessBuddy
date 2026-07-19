//
//  AppEnums.swift
//  Fitness Buddy
//
//  Created by Codex on 2026-05-30.
//

import Foundation

enum Sex: String, Codable, CaseIterable, Identifiable {
    case male
    case female
    case preferNotToSay

    var id: String { rawValue }
}

enum MetricSystem: String, Codable, CaseIterable, Identifiable {
    case metric
    case imperial

    var id: String { rawValue }
}

enum HeightUnit: String, Codable, CaseIterable, Identifiable {
    case centimeters
    case feetInches

    var id: String { rawValue }
}

enum WeightUnit: String, Codable, CaseIterable, Identifiable {
    case kilograms
    case pounds

    var id: String { rawValue }
}

enum ActivityLevel: String, Codable, CaseIterable, Identifiable {
    case sedentary
    case lightlyActive
    case moderatelyActive
    case veryActive

    var id: String { rawValue }
}

enum ExperienceLevel: String, Codable, CaseIterable, Identifiable {
    case beginner
    case intermediate
    case advanced

    var id: String { rawValue }
}

enum GoalType: String, Codable, CaseIterable, Identifiable {
    case loseWeight
    case buildMuscle
    case bodyRecomposition

    var id: String { rawValue }
}

enum CalculationMethod: String, Codable, CaseIterable, Identifiable {
    case formula
    case custom
    case aiSuggestedLater

    var id: String { rawValue }
}

enum MealType: String, Codable, CaseIterable, Identifiable {
    case breakfast
    case lunch
    case dinner
    case snack

    var id: String { rawValue }
}

enum JournalSection: String, Codable, CaseIterable, Identifiable {
    case breakfast
    case lunch
    case dinner
    case snacks
    case workout
    case notes

    var id: String { rawValue }
}
