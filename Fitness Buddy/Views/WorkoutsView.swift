import SwiftData
import SwiftUI

struct WorkoutsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.loggedAt, order: .forward) private var entries: [JournalEntry]
    @FocusState private var isComposerFocused: Bool

    @State private var selectedDate = Date()
    @State private var workoutText = ""

    private var todayWorkouts: [JournalEntry] {
        entries.filter {
            $0.section == .workout && Calendar.current.isDate($0.loggedAt, inSameDayAs: selectedDate)
        }
        .sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 26) {
                        workoutHeader

                        if todayWorkouts.isEmpty {
                            Text("No workout logged yet")
                                .font(.system(size: 22, weight: .regular, design: .rounded))
                                .foregroundStyle(AppStyle.muted.opacity(0.62))
                                .padding(.top, 20)
                        } else {
                            VStack(spacing: 14) {
                                ForEach(todayWorkouts) { entry in
                                    SwipeToDeleteRow {
                                        WorkoutEntryRow(
                                            entry: entry,
                                            lastText: previousWorkoutText(for: entry)
                                        )
                                    } onDelete: {
                                        deleteWorkout(entry)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 18)
                    .padding(.bottom, 116)
                }

                workoutComposer
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
        }
    }

    private var workoutHeader: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(selectedDate.formatted(.dateTime.month(.abbreviated).day()))
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(AppStyle.ink)
                    .padding(.horizontal, 22)
                    .frame(height: 50)
                    .background(.white.opacity(0.9))
                    .clipShape(Capsule())

                Spacer()

                Text("\(todayWorkouts.count) logged")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(AppStyle.workout)
                    .padding(.horizontal, 18)
                    .frame(height: 50)
                    .background(.white.opacity(0.9))
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(selectedDate.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppStyle.muted)

                Text("Workouts")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(AppStyle.ink)
            }
        }
    }

    private var workoutComposer: some View {
        HStack(spacing: 10) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(AppStyle.workout)
                .frame(width: 44, height: 44)
                .background(.white.opacity(0.92))
                .clipShape(Circle())

            TextField("Type workout...", text: $workoutText, axis: .vertical)
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .lineLimit(1...4)
                .focused($isComposerFocused)
                .submitLabel(.done)
                .onSubmit {
                    saveWorkout(keepFocus: true)
                }
                .onKeyPress(.return) {
                    guard !trimmedWorkoutText.isEmpty else { return .ignored }
                    saveWorkout(keepFocus: true)
                    return .handled
                }

            if !trimmedWorkoutText.isEmpty {
                Button {
                    saveWorkout()
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(AppStyle.workout)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .padding(.leading, 8)
        .padding(.trailing, 6)
        .padding(.vertical, 7)
        .background(.white.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 20, y: 10)
    }

    private var trimmedWorkoutText: String {
        workoutText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func saveWorkout(keepFocus: Bool = false) {
        guard !trimmedWorkoutText.isEmpty else { return }

        modelContext.insert(
            JournalEntry(
                section: .workout,
                text: trimmedWorkoutText,
                loggedAt: Calendar.current.isDateInToday(selectedDate) ? .now : selectedDate,
                createdAt: .now,
                updatedAt: .now
            )
        )
        try? modelContext.save()
        workoutText = ""
        isComposerFocused = keepFocus
    }

    private func deleteWorkout(_ entry: JournalEntry) {
        modelContext.delete(entry)
        try? modelContext.save()
    }

    private func previousWorkoutText(for entry: JournalEntry) -> String? {
        let currentName = exerciseName(from: entry.text)
        guard !currentName.isEmpty else { return nil }

        return entries
            .filter { candidate in
                candidate.section == .workout &&
                candidate.id != entry.id &&
                candidate.createdAt < entry.createdAt &&
                exerciseName(from: candidate.text) == currentName
            }
            .sorted { $0.createdAt > $1.createdAt }
            .first?
            .text
    }

    private func exerciseName(from text: String) -> String {
        let prefix = text.prefix { !$0.isNumber }
        let name = String(prefix)
            .replacingOccurrences(of: "-", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if !name.isEmpty {
            return name
        }

        return text
            .split(separator: " ")
            .prefix(2)
            .joined(separator: " ")
            .lowercased()
    }
}

struct WorkoutEntryRow: View {
    let entry: JournalEntry
    let lastText: String?

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "checkmark")
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(AppStyle.workout)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 5) {
                Text(entry.text)
                    .font(.system(size: 21, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppStyle.ink)
                    .lineSpacing(5)

                Text(lastText.map { "Last: \($0)" } ?? "Workout note")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppStyle.muted)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(18)
        .background(.white.opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 16, y: 8)
    }
}
