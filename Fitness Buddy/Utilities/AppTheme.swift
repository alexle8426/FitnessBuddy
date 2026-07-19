//
//  AppTheme.swift
//  Fitness Buddy
//
//  Created by Codex on 2026-05-26.
//

import SwiftUI

enum AppTheme {
    enum Colors {
        static let ink = Color(hex: 0x121619)
        static let muted = Color(hex: 0x6F787B)
        static let cream = Color(hex: 0xFBF7F0)
        static let surface = Color.white.opacity(0.86)
        static let line = Color(hex: 0xE5E1D8)
        static let teal = Color(hex: 0x176B63)
        static let tealSoft = Color(hex: 0xE4F4F1)
        static let green = Color(hex: 0x2F6F4E)
        static let violet = Color(hex: 0x8B83C9)
        static let blue = Color(hex: 0x79A7D3)
        static let gold = Color(hex: 0xBE8A3F)
        static let coral = Color(hex: 0xD7733D)
    }

    enum Spacing {
        static let xsmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 24
        static let xxlarge: CGFloat = 32
    }

    enum Radius {
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 22
        static let pill: CGFloat = 999
    }

    enum Typography {
        static let hero = Font.system(size: 34, weight: .semibold, design: .serif)
        static let title = Font.system(size: 28, weight: .bold, design: .default)
        static let heading = Font.system(size: 22, weight: .bold, design: .default)
        static let body = Font.system(size: 15, weight: .regular, design: .default)
        static let callout = Font.system(size: 13, weight: .medium, design: .default)
        static let caption = Font.system(size: 11, weight: .semibold, design: .default)
    }

    static let shadow = Color.black.opacity(0.08)
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: alpha
        )
    }
}
