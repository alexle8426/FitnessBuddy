import SwiftUI

enum FoodEntryMode: String, CaseIterable, Identifiable {
    case auto
    case manual

    var id: String { rawValue }

    var title: String {
        switch self {
        case .auto:
            return "Auto"
        case .manual:
            return "Manual"
        }
    }

    var systemImage: String {
        switch self {
        case .auto:
            return "sparkles"
        case .manual:
            return "number"
        }
    }

    var color: Color {
        switch self {
        case .auto:
            return AppStyle.action
        case .manual:
            return AppStyle.ink
        }
    }
}

enum AutoFoodSource: String, CaseIterable, Identifiable {
    case describe
    case photo
    case barcode

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .describe:
            return "text.alignleft"
        case .photo:
            return "camera.fill"
        case .barcode:
            return "barcode.viewfinder"
        }
    }

    var color: Color {
        switch self {
        case .describe:
            return AppStyle.action
        case .photo:
            return AppStyle.calories
        case .barcode:
            return AppStyle.workout
        }
    }
}

struct CompactCaptureButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .padding(.horizontal, 13)
                .frame(height: 34)
                .background(.white.opacity(0.86))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct MacroNumberField: View {
    let title: String
    @Binding var value: String
    let color: Color
    let suffix: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(color)

            HStack(alignment: .firstTextBaseline, spacing: 5) {
                TextField("0", text: $value)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .keyboardType(.numberPad)

                Text(suffix)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppStyle.muted)
            }
        }
        .padding(16)
        .background(.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                AppStyle.background,
                Color(hex: 0xFFF7F9),
                Color(hex: 0xFFFDF8)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

enum AppStyle {
    static let background = Color(hex: 0xFFFBF7)
    static let ink = Color(hex: 0x101010)
    static let muted = Color(hex: 0x929094)
    static let calories = Color(hex: 0xFF9718)
    static let carbs = Color(hex: 0xFF0A45)
    static let protein = Color(hex: 0xF5BE00)
    static let fat = Color(hex: 0xD20CE6)
    static let workout = Color(hex: 0x7B4DFF)
    static let action = Color(hex: 0x1686E8)
}

struct MacroTargetSummary {
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
}

struct MacroPillItem: View {
    let symbol: String?
    let title: String?
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            if let symbol {
                Image(systemName: symbol)
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(color)
            }

            if let title {
                Text(title)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(color)
            }

            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(AppStyle.ink)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.72)
        .accessibilityElement(children: .combine)
    }
}

struct MacroPillDivider: View {
    var body: some View {
        Circle()
            .fill(AppStyle.muted.opacity(0.5))
            .frame(width: 5, height: 5)
            .padding(.horizontal, 12)
    }
}

struct EntryStatus {
    let text: String
    let icon: String?
    let color: Color
}

struct EntryStatusView: View {
    let status: EntryStatus

    var body: some View {
        HStack(spacing: 5) {
            if let icon = status.icon {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .black))
            }

            Text(status.text)
                .font(.system(size: 19, weight: .bold, design: .rounded))
        }
        .foregroundStyle(status.color)
        .lineLimit(1)
        .minimumScaleFactor(0.72)
        .frame(minWidth: 86, alignment: .trailing)
    }
}

struct InlineMacroText: View {
    let label: String
    let value: Int?
    let color: Color

    var body: some View {
        if let value {
            HStack(spacing: 3) {
                Text(label)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(color)

                Text("\(value)g")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppStyle.muted)
            }
        }
    }
}

extension JournalSection {
    var title: String {
        switch self {
        case .breakfast:
            return "Breakfast"
        case .lunch:
            return "Lunch"
        case .dinner:
            return "Dinner"
        case .snacks:
            return "Snacks"
        case .workout:
            return "Workout"
        case .notes:
            return "Notes"
        }
    }

    var emptyText: String {
        switch self {
        case .breakfast:
            return "No breakfast yet"
        case .lunch:
            return "No lunch yet"
        case .dinner:
            return "No dinner yet"
        case .snacks:
            return "No snacks yet"
        case .workout:
            return "No workout logged yet"
        case .notes:
            return "No notes yet"
        }
    }

    var shortTitle: String {
        switch self {
        case .breakfast:
            return "Breakfast"
        case .lunch:
            return "Lunch"
        case .dinner:
            return "Dinner"
        case .snacks:
            return "Snack"
        case .workout:
            return "Workout"
        case .notes:
            return "Note"
        }
    }

    var accentColor: Color {
        switch self {
        case .breakfast:
            return AppStyle.calories
        case .lunch:
            return AppStyle.carbs
        case .dinner:
            return AppStyle.protein
        case .snacks:
            return AppStyle.fat
        case .workout:
            return AppStyle.workout
        case .notes:
            return AppStyle.muted
        }
    }
}
