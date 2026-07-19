//
//  DailyLogView.swift
//  Fitness Buddy
//
//  Created by Codex on 2026-06-22.
//

import SwiftData
import SwiftUI

struct DailyLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.loggedAt, order: .forward) private var entries: [JournalEntry]
    @Query(sort: \MacroTarget.createdAt, order: .reverse) private var macroTargets: [MacroTarget]
    @FocusState private var isFoodNoteFocused: Bool

    @State private var selectedDate = Date()
    @State private var nutritionMode: FoodEntryMode = .auto
    @State private var foodNoteText = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var showingMacroBreakdown = false
    @State private var showingSettings = false
    @State private var showingMealHistory = false
    @State private var selectedNutritionEntry: JournalEntry?
    @State private var captureSource: AutoFoodSource?
    @State private var lastLoggedFoodNote: String?
    @State private var pendingNutritionNotes: [PendingNutritionNote] = []

    private var todayEntries: [JournalEntry] {
        entries.filter { Calendar.current.isDate($0.loggedAt, inSameDayAs: selectedDate) }
    }

    private var todayNutritionEntries: [JournalEntry] {
        todayEntries
            .filter { $0.section != .workout }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private var visiblePendingNutritionNotes: [PendingNutritionNote] {
        pendingNutritionNotes.filter { note in
            !todayNutritionEntries.contains { entry in
                entry.text == note.text && abs(entry.createdAt.timeIntervalSince(note.createdAt)) < 5
            }
        }
    }

    private var hasNutritionLogItems: Bool {
        !todayNutritionEntries.isEmpty || !visiblePendingNutritionNotes.isEmpty
    }

    private var target: MacroTargetSummary {
        if let macroTarget = macroTargets.first {
            return MacroTargetSummary(
                calories: macroTarget.dailyCalories,
                protein: macroTarget.proteinGrams,
                carbs: macroTarget.carbsGrams,
                fat: macroTarget.fatGrams
            )
        }

        return MacroTargetSummary(calories: 2_000, protein: 150, carbs: 200, fat: 65)
    }

    private var totals: MacroTargetSummary {
        MacroTargetSummary(
            calories: todayNutritionEntries.reduce(0) { $0 + ($1.calories ?? 0) } + visiblePendingNutritionNotes.reduce(0) { $0 + ($1.calories ?? 0) },
            protein: todayNutritionEntries.reduce(0) { $0 + ($1.proteinGrams ?? 0) } + visiblePendingNutritionNotes.reduce(0) { $0 + ($1.proteinGrams ?? 0) },
            carbs: todayNutritionEntries.reduce(0) { $0 + ($1.carbsGrams ?? 0) } + visiblePendingNutritionNotes.reduce(0) { $0 + ($1.carbsGrams ?? 0) },
            fat: todayNutritionEntries.reduce(0) { $0 + ($1.fatGrams ?? 0) } + visiblePendingNutritionNotes.reduce(0) { $0 + ($1.fatGrams ?? 0) }
        )
    }

    private var trimmedFoodNote: String {
        foodNoteText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSaveFoodNote: Bool {
        switch nutritionMode {
        case .auto:
            return !trimmedFoodNote.isEmpty
        case .manual:
            return !trimmedFoodNote.isEmpty && Int(calories) != nil
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        header
                        nutritionModePicker
                        nutritionNoteSurface
                        nutritionEntriesList
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 18)
                    .padding(.bottom, 112)
                }

                Button {
                    showingMacroBreakdown = true
                } label: {
                    macroPill
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 18)
                .padding(.bottom, 12)
                .background {
                    LinearGradient(
                        colors: [AppStyle.background.opacity(0), AppStyle.background],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .toolbar {
                keyboardToolbar
            }
            .onAppear {
                isFoodNoteFocused = true
            }
            .sheet(isPresented: $showingMacroBreakdown) {
                MacroBreakdownSheet(totals: totals, target: target)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingSettings) {
                ProfileSettingsSheet(target: target)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingMealHistory) {
                MealHistorySheet(
                    date: selectedDate,
                    entries: todayNutritionEntries,
                    totals: totals
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .sheet(item: $selectedNutritionEntry) { entry in
                NutritionEntryDetailSheet(entry: entry)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $captureSource) { source in
                FoodCaptureSheet(source: source)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text("FB")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(AppStyle.ink)
                .frame(width: 48, height: 48)
                .background(.white.opacity(0.84))
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.88), lineWidth: 1)
                }

            Spacer()

            Button {
                showingMealHistory = true
            } label: {
                Text(isSelectedToday ? "Today" : selectedDate.formatted(.dateTime.month(.abbreviated).day()))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(AppStyle.ink)
                    .padding(.horizontal, 26)
                    .frame(height: 52)
                    .background(.white.opacity(0.9))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                showingSettings = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(AppStyle.calories)
                    Text("\(currentStreak)")
                    Image(systemName: "gearshape.fill")
                }
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(AppStyle.ink)
                .padding(.horizontal, 16)
                .frame(height: 52)
                .background(.white.opacity(0.9))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private var nutritionModePicker: some View {
        HStack(spacing: 0) {
            ForEach(FoodEntryMode.allCases) { mode in
                let isSelected = nutritionMode == mode

                Button {
                    nutritionMode = mode
                    isFoodNoteFocused = true
                } label: {
                    Text(mode.title)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(isSelected ? .white : AppStyle.ink)
                        .frame(width: 68, height: 32)
                        .background(isSelected ? mode.color : .clear)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(.white.opacity(0.86))
        .clipShape(Capsule())
    }

    private var nutritionNoteSurface: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 12) {
                ZStack(alignment: .leading) {
                    if foodNoteText.isEmpty {
                        Text(nutritionMode == .auto ? "Type a meal or food..." : "Food name")
                            .font(.system(size: 28, weight: .regular, design: .rounded))
                            .foregroundStyle(AppStyle.muted.opacity(0.52))
                    }

                    TextField("", text: $foodNoteText)
                        .font(.system(size: 28, weight: .regular, design: .rounded))
                        .foregroundStyle(AppStyle.ink)
                        .focused($isFoodNoteFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            saveFoodNote(keepFocus: true)
                        }
                        .onKeyPress(.return) {
                            guard canSaveFoodNote else { return .ignored }
                            saveFoodNote(keepFocus: true)
                            return .handled
                        }
                        .padding(.vertical, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: noteSurfaceHeight, alignment: .topLeading)

            if nutritionMode == .manual {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    MacroNumberField(title: "Calories", value: $calories, color: AppStyle.calories, suffix: "cal")
                    MacroNumberField(title: "Protein", value: $protein, color: AppStyle.protein, suffix: "g")
                    MacroNumberField(title: "Carbs", value: $carbs, color: AppStyle.carbs, suffix: "g")
                    MacroNumberField(title: "Fat", value: $fat, color: AppStyle.fat, suffix: "g")
                }
            }

            if nutritionMode == .auto {
                HStack(spacing: 10) {
                    CompactCaptureButton(title: "Photo", systemImage: AutoFoodSource.photo.systemImage, color: AutoFoodSource.photo.color) {
                        captureSource = .photo
                    }

                    CompactCaptureButton(title: "Barcode", systemImage: AutoFoodSource.barcode.systemImage, color: AutoFoodSource.barcode.color) {
                        captureSource = .barcode
                    }
                }
            }

            if let lastLoggedFoodNote {
                Text("Logged \(lastLoggedFoodNote)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(AppStyle.action)
                    .lineLimit(1)
                    .transition(.opacity)
            }
        }
    }

    private var noteSurfaceHeight: CGFloat {
        if nutritionMode == .manual {
            return 82
        }

        return hasNutritionLogItems ? 72 : 220
    }

    @ToolbarContentBuilder
    private var keyboardToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()

            Button("Log") {
                saveFoodNote(keepFocus: true)
            }
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .disabled(!canSaveFoodNote)
        }
    }

    private var nutritionEntriesList: some View {
        VStack(alignment: .leading, spacing: 18) {
            if hasNutritionLogItems {
                ForEach(visiblePendingNutritionNotes) { note in
                    SwipeToDeleteRow {
                        PendingNutritionEntryRow(note: note)
                    } onDelete: {
                        deletePendingNote(note)
                    }
                }

                ForEach(todayNutritionEntries) { entry in
                    SwipeToDeleteRow {
                        NutritionEntryRow(entry: entry)
                            .onTapGesture {
                                selectedNutritionEntry = entry
                            }
                    } onDelete: {
                        deleteEntry(entry)
                    }
                }
            } else {
                Text("Nothing logged yet")
                    .font(.system(size: 22, weight: .regular, design: .rounded))
                    .foregroundStyle(AppStyle.muted.opacity(0.62))
                    .padding(.top, 8)
            }
        }
    }

    private var macroPill: some View {
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
        .shadow(color: .black.opacity(0.06), radius: 14, y: 6)
    }

    private var isSelectedToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    private var currentStreak: Int {
        let calendar = Calendar.current
        let loggedDays = Set(entries.map { calendar.startOfDay(for: $0.loggedAt) })
        var cursor = calendar.startOfDay(for: .now)
        var streak = 0

        while loggedDays.contains(cursor) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                break
            }
            cursor = previousDay
        }

        return max(streak, todayEntries.isEmpty ? 0 : 1)
    }

    private func saveFoodNote(keepFocus: Bool = false) {
        guard canSaveFoodNote else { return }
        let savedText = trimmedFoodNote
        let now = Date()
        let loggedAt = isSelectedToday ? now : selectedDate
        let entry = JournalEntry(
            section: .notes,
            text: savedText,
            calories: Int(calories),
            proteinGrams: Int(protein),
            carbsGrams: Int(carbs),
            fatGrams: Int(fat),
            status: nutritionMode == .manual ? .manual : .thinking,
            entryMode: nutritionMode == .manual ? .manual : .auto,
            estimationBias: 0,
            loggedAt: loggedAt,
            createdAt: now,
            updatedAt: now
        )
        let pendingNote = PendingNutritionNote(
            entry: entry,
            text: savedText,
            createdAt: now,
            calories: Int(calories),
            proteinGrams: Int(protein),
            carbsGrams: Int(carbs),
            fatGrams: Int(fat),
            status: nutritionMode == .manual ? .manual : .thinking,
            entryMode: nutritionMode == .manual ? .manual : .auto
        )

        modelContext.insert(entry)
        try? modelContext.save()
        pendingNutritionNotes.insert(pendingNote, at: 0)
        foodNoteText = ""
        calories = ""
        protein = ""
        carbs = ""
        fat = ""
        lastLoggedFoodNote = savedText
        isFoodNoteFocused = keepFocus
    }

    private func deleteEntry(_ entry: JournalEntry) {
        modelContext.delete(entry)
        try? modelContext.save()
    }

    private func deletePendingNote(_ note: PendingNutritionNote) {
        pendingNutritionNotes.removeAll { $0.id == note.id }
        modelContext.delete(note.entry)
        try? modelContext.save()
    }
}

private struct PendingNutritionNote: Identifiable {
    let id = UUID()
    let entry: JournalEntry
    let text: String
    let createdAt: Date
    let calories: Int?
    let proteinGrams: Int?
    let carbsGrams: Int?
    let fatGrams: Int?
    let status: JournalEntryStatus
    let entryMode: JournalEntryMode
}

private struct PendingNutritionEntryRow: View {
    let note: PendingNutritionNote

    private var status: EntryStatus {
        if let calories = note.calories {
            let icon = note.entryMode == .manual ? "flame.fill" : "sparkles"
            let color = note.entryMode == .manual ? AppStyle.calories : AppStyle.action
            return EntryStatus(text: "\(calories) cal", icon: icon, color: color)
        }

        return EntryStatus(text: note.status == .needsInfo ? "Needs info" : "Thinking", icon: nil, color: AppStyle.muted)
    }

    private var hasMacroDetail: Bool {
        note.proteinGrams != nil || note.carbsGrams != nil || note.fatGrams != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 16) {
                Text(note.text)
                    .font(.system(size: 22, weight: .regular, design: .rounded))
                    .foregroundStyle(AppStyle.ink)
                    .lineSpacing(7)
                    .frame(maxWidth: .infinity, alignment: .leading)

                EntryStatusView(status: status)
            }

            if hasMacroDetail {
                HStack(spacing: 18) {
                    InlineMacroText(label: "P", value: note.proteinGrams, color: AppStyle.protein)
                    InlineMacroText(label: "C", value: note.carbsGrams, color: AppStyle.carbs)
                    InlineMacroText(label: "F", value: note.fatGrams, color: AppStyle.fat)
                }
            }
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    DailyLogView()
        .modelContainer(for: [JournalEntry.self, MacroTarget.self], inMemory: true)
}
