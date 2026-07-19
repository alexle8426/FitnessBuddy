import SwiftData
import SwiftUI

struct MacroBreakdownSheet: View {
    let totals: MacroTargetSummary
    let target: MacroTargetSummary

    var body: some View {
        ZStack {
            AppBackground()

            VStack(alignment: .leading, spacing: 28) {
                Text("Goals")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(AppStyle.ink)

                VStack(spacing: 28) {
                    MacroGoalRow(
                        title: "Calories",
                        value: totals.calories,
                        target: target.calories,
                        suffix: "",
                        symbol: .system("flame.fill"),
                        color: AppStyle.calories
                    )

                    MacroGoalRow(
                        title: "Carbs",
                        value: totals.carbs,
                        target: target.carbs,
                        suffix: "g",
                        symbol: .letter("C"),
                        color: AppStyle.carbs
                    )

                    MacroGoalRow(
                        title: "Protein",
                        value: totals.protein,
                        target: target.protein,
                        suffix: "g",
                        symbol: .letter("P"),
                        color: AppStyle.protein
                    )

                    MacroGoalRow(
                        title: "Fat",
                        value: totals.fat,
                        target: target.fat,
                        suffix: "g",
                        symbol: .letter("F"),
                        color: AppStyle.fat
                    )
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 30)
            .padding(.top, 36)
            .padding(.bottom, 20)
        }
    }
}

struct ProfileSettingsSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MacroTarget.createdAt, order: .reverse) private var macroTargets: [MacroTarget]
    @AppStorage("aiEstimateBias") private var aiEstimateBias: Double = 0

    let target: MacroTargetSummary
    @State private var calorieTarget = ""
    @State private var carbTarget = ""
    @State private var proteinTarget = ""
    @State private var fatTarget = ""
    @State private var didLoadTargets = false
    @State private var saveMessage: String?

    private var biasLabel: String {
        if aiEstimateBias < -0.25 {
            return "Underestimate"
        }

        if aiEstimateBias > 0.25 {
            return "Overestimate"
        }

        return "Balanced"
    }

    private var activeTarget: MacroTargetSummary {
        guard let macroTarget = macroTargets.first else { return target }

        return MacroTargetSummary(
            calories: macroTarget.dailyCalories,
            protein: macroTarget.proteinGrams,
            carbs: macroTarget.carbsGrams,
            fat: macroTarget.fatGrams
        )
    }

    private var hasValidMacroDraft: Bool {
        parsedDraft != nil
    }

    private var parsedDraft: MacroTargetSummary? {
        guard
            let calories = Int(calorieTarget),
            let carbs = Int(carbTarget),
            let protein = Int(proteinTarget),
            let fat = Int(fatTarget),
            calories > 0,
            carbs >= 0,
            protein >= 0,
            fat >= 0
        else {
            return nil
        }

        return MacroTargetSummary(calories: calories, protein: protein, carbs: carbs, fat: fat)
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    Text("Settings")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(AppStyle.ink)

                    VStack(alignment: .leading, spacing: 18) {
                        SettingsSectionTitle("AI estimates")

                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("Estimate bias")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppStyle.ink)

                                Spacer()

                                Text(biasLabel)
                                    .font(.system(size: 15, weight: .black, design: .rounded))
                                    .foregroundStyle(AppStyle.action)
                            }

                            Slider(value: $aiEstimateBias, in: -1...1)
                                .tint(AppStyle.action)

                            HStack {
                                Text("Lower")
                                Spacer()
                                Text("Higher")
                            }
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(AppStyle.muted)
                        }
                        .padding(18)
                        .background(.white.opacity(0.88))
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 18) {
                        SettingsSectionTitle("Macro plan")

                        macroPlanEditor
                    }

                    VStack(alignment: .leading, spacing: 18) {
                        SettingsSectionTitle("Later")

                        VStack(alignment: .leading, spacing: 10) {
                            Text("AI macro plan")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(AppStyle.ink)

                            Text("Onboarding will collect goals, stats, and preferences. AI can later suggest a plan, then save it here for local tracking.")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundStyle(AppStyle.muted)
                                .lineSpacing(5)
                        }
                        .padding(18)
                        .background(.white.opacity(0.88))
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                }
                .padding(.horizontal, 26)
                .padding(.top, 34)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            loadTargetsIfNeeded()
        }
    }

    private var macroPlanEditor: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 0) {
                MacroPillItem(symbol: "flame.fill", title: nil, value: calorieTarget.isEmpty ? "\(activeTarget.calories)" : calorieTarget, color: AppStyle.calories)
                MacroPillDivider()
                MacroPillItem(symbol: nil, title: "C", value: carbTarget.isEmpty ? "\(activeTarget.carbs)" : carbTarget, color: AppStyle.carbs)
                MacroPillDivider()
                MacroPillItem(symbol: nil, title: "P", value: proteinTarget.isEmpty ? "\(activeTarget.protein)" : proteinTarget, color: AppStyle.protein)
                MacroPillDivider()
                MacroPillItem(symbol: nil, title: "F", value: fatTarget.isEmpty ? "\(activeTarget.fat)" : fatTarget, color: AppStyle.fat)
            }
            .padding(.horizontal, 14)
            .frame(height: 52)
            .background(AppStyle.background.opacity(0.82))
            .clipShape(Capsule())

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                SettingsMacroField(title: "Calories", value: $calorieTarget, color: AppStyle.calories, suffix: "cal")
                SettingsMacroField(title: "Carbs", value: $carbTarget, color: AppStyle.carbs, suffix: "g")
                SettingsMacroField(title: "Protein", value: $proteinTarget, color: AppStyle.protein, suffix: "g")
                SettingsMacroField(title: "Fat", value: $fatTarget, color: AppStyle.fat, suffix: "g")
            }

            if let saveMessage {
                Text(saveMessage)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppStyle.action)
            }

            HStack(spacing: 12) {
                Button {
                    resetDraftToActiveTarget()
                } label: {
                    Text("Reset")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppStyle.ink)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(AppStyle.background.opacity(0.86))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Button {
                    saveMacroTargets()
                } label: {
                    Text("Save")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(hasValidMacroDraft ? AppStyle.action : AppStyle.muted.opacity(0.4))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(!hasValidMacroDraft)
            }
        }
        .padding(18)
        .background(.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func loadTargetsIfNeeded() {
        guard !didLoadTargets else { return }
        resetDraftToActiveTarget()
        didLoadTargets = true
    }

    private func resetDraftToActiveTarget() {
        calorieTarget = "\(activeTarget.calories)"
        carbTarget = "\(activeTarget.carbs)"
        proteinTarget = "\(activeTarget.protein)"
        fatTarget = "\(activeTarget.fat)"
        saveMessage = nil
    }

    private func saveMacroTargets() {
        guard let draft = parsedDraft else { return }
        let now = Date()

        if let macroTarget = macroTargets.first {
            macroTarget.dailyCalories = draft.calories
            macroTarget.carbsGrams = draft.carbs
            macroTarget.proteinGrams = draft.protein
            macroTarget.fatGrams = draft.fat
            macroTarget.isCustom = true
            macroTarget.calculationMethodRawValue = CalculationMethod.custom.rawValue
            macroTarget.updatedAt = now
        } else {
            modelContext.insert(
                MacroTarget(
                    dailyCalories: draft.calories,
                    proteinGrams: draft.protein,
                    carbsGrams: draft.carbs,
                    fatGrams: draft.fat,
                    isCustom: true,
                    calculationMethod: .custom,
                    createdAt: now,
                    updatedAt: now
                )
            )
        }

        try? modelContext.save()
        saveMessage = "Saved macro targets"
    }
}

struct SettingsMacroField: View {
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
                    .font(.system(size: 23, weight: .black, design: .rounded))
                    .keyboardType(.numberPad)

                Text(suffix)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppStyle.muted)
            }
        }
        .padding(16)
        .background(AppStyle.background.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct SettingsSectionTitle: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(AppStyle.muted)
            .textCase(.uppercase)
    }
}

struct MealHistorySheet: View {
    let date: Date
    let entries: [JournalEntry]
    let totals: MacroTargetSummary

    private let meals: [MealAssignment] = [.breakfast, .lunch, .dinner, .snacks]

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(date.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppStyle.muted)

                        Text("Meal history")
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundStyle(AppStyle.ink)
                    }

                    HStack(spacing: 0) {
                        MacroPillItem(symbol: "flame.fill", title: nil, value: "\(totals.calories)", color: AppStyle.calories)
                        MacroPillDivider()
                        MacroPillItem(symbol: nil, title: "C", value: "\(totals.carbs)", color: AppStyle.carbs)
                        MacroPillDivider()
                        MacroPillItem(symbol: nil, title: "P", value: "\(totals.protein)", color: AppStyle.protein)
                        MacroPillDivider()
                        MacroPillItem(symbol: nil, title: "F", value: "\(totals.fat)", color: AppStyle.fat)
                    }
                    .padding(.horizontal, 18)
                    .frame(height: 54)
                    .background(.white.opacity(0.9))
                    .clipShape(Capsule())

                    ForEach(meals) { meal in
                        MealHistorySection(meal: meal, entries: entries(for: meal))
                    }

                    let unassigned = entries.filter { MealAssignment(section: $0.section) == .unassigned }
                    if !unassigned.isEmpty {
                        MealHistorySection(meal: .unassigned, entries: unassigned)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 34)
                .padding(.bottom, 40)
            }
        }
    }

    private func entries(for meal: MealAssignment) -> [JournalEntry] {
        entries.filter { MealAssignment(section: $0.section) == meal }
    }
}

struct MealHistorySection: View {
    let meal: MealAssignment
    let entries: [JournalEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(meal.title)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(meal.color)

                Spacer()

                Text("\(entries.count)")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(AppStyle.muted)
            }

            if entries.isEmpty {
                Text("Nothing yet")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundStyle(AppStyle.muted.opacity(0.62))
                    .padding(.vertical, 4)
            } else {
                VStack(spacing: 14) {
                    ForEach(entries) { entry in
                        NutritionEntryRow(entry: entry)
                            .padding(16)
                            .background(.white.opacity(0.84))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                }
            }
        }
    }
}

struct MacroGoalRow: View {
    let title: String
    let value: Int
    let target: Int
    let suffix: String
    let symbol: MacroGoalSymbol
    let color: Color

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(value) / Double(target), 1)
    }

    private var valueText: String {
        if suffix.isEmpty {
            return "\(value) / \(target)"
        }

        return "\(value) / \(target)\(suffix)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 14) {
                MacroGoalSymbolView(symbol: symbol, color: color)

                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppStyle.muted)

                Spacer()

                Text(valueText)
                    .font(.system(size: 27, weight: .black, design: .rounded))
                    .foregroundStyle(AppStyle.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppStyle.muted.opacity(0.18))

                    Capsule()
                        .fill(color)
                        .frame(width: proxy.size.width * progress)
                }
            }
            .frame(height: 12)
        }
    }
}

enum MacroGoalSymbol {
    case system(String)
    case letter(String)
}

struct MacroGoalSymbolView: View {
    let symbol: MacroGoalSymbol
    let color: Color

    var body: some View {
        Group {
            switch symbol {
            case .system(let name):
                Image(systemName: name)
                    .font(.system(size: 26, weight: .black))

            case .letter(let value):
                Text(value)
                    .font(.system(size: 25, weight: .black, design: .rounded))
            }
        }
        .foregroundStyle(color)
        .frame(width: 34)
    }
}
