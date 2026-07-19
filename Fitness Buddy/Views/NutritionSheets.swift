import SwiftData
import SwiftUI

struct FoodCaptureSheet: View {
    @Environment(\.dismiss) private var dismiss

    let source: AutoFoodSource

    private var title: String {
        switch source {
        case .describe:
            return "Describe food"
        case .photo:
            return "Photo estimate"
        case .barcode:
            return "Barcode scan"
        }
    }

    private var message: String {
        switch source {
        case .describe:
            return "Describe entry is handled on the main note page."
        case .photo:
            return "Camera capture will connect here. For now, use Auto mode text entry or Manual macros."
        case .barcode:
            return "Barcode scanning will connect here. For now, use Manual entry if you know the label."
        }
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(alignment: .leading, spacing: 22) {
                Image(systemName: source.systemImage)
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(source.color)
                    .frame(width: 58, height: 58)
                    .background(.white.opacity(0.9))
                    .clipShape(Circle())

                Text(title)
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(AppStyle.ink)

                Text(message)
                    .font(.system(size: 19, weight: .regular, design: .rounded))
                    .foregroundStyle(AppStyle.muted)
                    .lineSpacing(6)

                Spacer(minLength: 0)

                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(AppStyle.action)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 34)
        }
    }
}

struct NutritionEntryDetailSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let entry: JournalEntry

    @State private var text: String
    @State private var mode: FoodEntryMode
    @State private var meal: MealAssignment
    @State private var calories: String
    @State private var protein: String
    @State private var carbs: String
    @State private var fat: String

    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        !trimmedText.isEmpty
    }

    init(entry: JournalEntry) {
        self.entry = entry
        _text = State(initialValue: entry.text)
        _mode = State(initialValue: entry.entryMode == .manual ? .manual : .auto)
        _meal = State(initialValue: MealAssignment(section: entry.section))
        _calories = State(initialValue: Self.numberString(entry.calories))
        _protein = State(initialValue: Self.numberString(entry.proteinGrams))
        _carbs = State(initialValue: Self.numberString(entry.carbsGrams))
        _fat = State(initialValue: Self.numberString(entry.fatGrams))
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    header
                    noteEditor
                    modePicker
                    mealPicker
                    macroEditor
                }
                .padding(.horizontal, 24)
                .padding(.top, 26)
                .padding(.bottom, 34)
            }
        }
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 19, weight: .black))
                    .foregroundStyle(AppStyle.ink)
                    .frame(width: 46, height: 46)
                    .background(.white.opacity(0.88))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Food")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(AppStyle.ink)

            Spacer()

            Button {
                save()
            } label: {
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(canSave ? AppStyle.action : AppStyle.muted.opacity(0.35))
                    .clipShape(Circle())
            }
            .disabled(!canSave)
            .buttonStyle(.plain)
        }
    }

    private var noteEditor: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text("What did you eat?")
                    .font(.system(size: 28, weight: .regular, design: .rounded))
                    .foregroundStyle(AppStyle.muted.opacity(0.52))
                    .padding(.top, 8)
            }

            TextField("", text: $text, axis: .vertical)
                .font(.system(size: 28, weight: .regular, design: .rounded))
                .foregroundStyle(AppStyle.ink)
                .lineLimit(4...10)
                .lineSpacing(8)
                .padding(.vertical, 4)
        }
        .frame(minHeight: 150, alignment: .topLeading)
    }

    private var modePicker: some View {
        HStack(spacing: 0) {
            ForEach(FoodEntryMode.allCases) { option in
                let isSelected = mode == option

                Button {
                    mode = option
                } label: {
                    Text(option.title)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(isSelected ? .white : AppStyle.ink)
                        .frame(width: 68, height: 32)
                        .background(isSelected ? option.color : .clear)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(.white.opacity(0.86))
        .clipShape(Capsule())
    }

    private var mealPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Optional group")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(AppStyle.muted)
                .textCase(.uppercase)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(MealAssignment.allCases) { option in
                    let isSelected = meal == option

                    Button {
                        meal = option
                    } label: {
                        Text(option.title)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(isSelected ? .white : AppStyle.ink)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(isSelected ? option.color : .white.opacity(0.84))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var macroEditor: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Macros")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(AppStyle.muted)
                .textCase(.uppercase)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                MacroNumberField(title: "Calories", value: $calories, color: AppStyle.calories, suffix: "cal")
                MacroNumberField(title: "Protein", value: $protein, color: AppStyle.protein, suffix: "g")
                MacroNumberField(title: "Carbs", value: $carbs, color: AppStyle.carbs, suffix: "g")
                MacroNumberField(title: "Fat", value: $fat, color: AppStyle.fat, suffix: "g")
            }
        }
    }

    private func save() {
        let savedCalories = Int(calories)
        let savedProtein = Int(protein)
        let savedCarbs = Int(carbs)
        let savedFat = Int(fat)
        let hasNutrition = savedCalories != nil || savedProtein != nil || savedCarbs != nil || savedFat != nil

        entry.text = trimmedText
        entry.entryModeRawValue = mode.rawValue
        entry.sectionRawValue = meal.section.rawValue
        entry.calories = savedCalories
        entry.proteinGrams = savedProtein
        entry.carbsGrams = savedCarbs
        entry.fatGrams = savedFat
        entry.statusRawValue = status(hasNutrition: hasNutrition).rawValue
        entry.updatedAt = .now

        try? modelContext.save()
        dismiss()
    }

    private func status(hasNutrition: Bool) -> JournalEntryStatus {
        if mode == .manual {
            return .manual
        }

        return hasNutrition ? .estimated : .thinking
    }

    private static func numberString(_ value: Int?) -> String {
        guard let value else { return "" }
        return "\(value)"
    }
}

enum MealAssignment: String, CaseIterable, Identifiable {
    case unassigned
    case breakfast
    case lunch
    case dinner
    case snacks

    var id: String { rawValue }

    init(section: JournalSection) {
        switch section {
        case .breakfast:
            self = .breakfast
        case .lunch:
            self = .lunch
        case .dinner:
            self = .dinner
        case .snacks:
            self = .snacks
        case .workout, .notes:
            self = .unassigned
        }
    }

    var title: String {
        switch self {
        case .unassigned:
            return "Not set"
        case .breakfast:
            return "Breakfast"
        case .lunch:
            return "Lunch"
        case .dinner:
            return "Dinner"
        case .snacks:
            return "Snacks"
        }
    }

    var section: JournalSection {
        switch self {
        case .unassigned:
            return .notes
        case .breakfast:
            return .breakfast
        case .lunch:
            return .lunch
        case .dinner:
            return .dinner
        case .snacks:
            return .snacks
        }
    }

    var color: Color {
        switch self {
        case .unassigned:
            return AppStyle.ink
        case .breakfast:
            return AppStyle.calories
        case .lunch:
            return AppStyle.protein
        case .dinner:
            return AppStyle.carbs
        case .snacks:
            return AppStyle.fat
        }
    }
}
