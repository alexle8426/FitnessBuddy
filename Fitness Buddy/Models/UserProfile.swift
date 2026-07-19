//
//  UserProfile.swift
//  Fitness Buddy
//
//  Created by Codex on 2026-05-30.
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var name: String?
    var age: Int
    var sexRawValue: String
    var heightValue: Double
    var heightUnitRawValue: String
    var weightValue: Double
    var weightUnitRawValue: String
    var metricSystemRawValue: String
    var activityLevelRawValue: String
    var foodTrackingExperienceRawValue: String
    var gymExperienceRawValue: String
    var weeklyWorkoutTarget: Int
    var hasCompletedOnboarding: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String? = nil,
        age: Int,
        sex: Sex,
        heightValue: Double,
        heightUnit: HeightUnit,
        weightValue: Double,
        weightUnit: WeightUnit,
        metricSystem: MetricSystem,
        activityLevel: ActivityLevel,
        foodTrackingExperience: ExperienceLevel,
        gymExperience: ExperienceLevel,
        weeklyWorkoutTarget: Int,
        hasCompletedOnboarding: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.sexRawValue = sex.rawValue
        self.heightValue = heightValue
        self.heightUnitRawValue = heightUnit.rawValue
        self.weightValue = weightValue
        self.weightUnitRawValue = weightUnit.rawValue
        self.metricSystemRawValue = metricSystem.rawValue
        self.activityLevelRawValue = activityLevel.rawValue
        self.foodTrackingExperienceRawValue = foodTrackingExperience.rawValue
        self.gymExperienceRawValue = gymExperience.rawValue
        self.weeklyWorkoutTarget = weeklyWorkoutTarget
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
