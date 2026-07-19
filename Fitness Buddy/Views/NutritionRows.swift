import SwiftUI

struct NutritionEntryRow: View {
    let entry: JournalEntry

    private var meal: MealAssignment {
        MealAssignment(section: entry.section)
    }

    private var status: EntryStatus {
        if let calories = entry.calories {
            let icon = entry.entryMode == .manual ? "flame.fill" : "sparkles"
            let color = entry.entryMode == .manual ? AppStyle.calories : AppStyle.action
            return EntryStatus(text: "\(calories) cal", icon: entry.hasNutrition ? icon : nil, color: entry.hasNutrition ? color : AppStyle.muted)
        }

        if entry.status == .needsInfo {
            return EntryStatus(text: "Needs info", icon: nil, color: AppStyle.muted)
        }

        return EntryStatus(text: "Thinking", icon: nil, color: AppStyle.muted)
    }

    private var hasMacroDetail: Bool {
        entry.hasNutrition && (entry.proteinGrams != nil || entry.carbsGrams != nil || entry.fatGrams != nil)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 16) {
                Text(entry.text)
                    .font(.system(size: 22, weight: .regular, design: .rounded))
                    .foregroundStyle(AppStyle.ink)
                    .lineSpacing(7)
                    .frame(maxWidth: .infinity, alignment: .leading)

                EntryStatusView(status: status)
            }

            if hasMacroDetail {
                HStack(spacing: 18) {
                    if meal != .unassigned {
                        MealMetadataChip(meal: meal)
                    }

                    InlineMacroText(label: "P", value: entry.proteinGrams, color: AppStyle.protein)
                    InlineMacroText(label: "C", value: entry.carbsGrams, color: AppStyle.carbs)
                    InlineMacroText(label: "F", value: entry.fatGrams, color: AppStyle.fat)
                }
            } else if meal != .unassigned {
                MealMetadataChip(meal: meal)
            }
        }
        .contentShape(Rectangle())
    }
}

struct MealMetadataChip: View {
    let meal: MealAssignment

    var body: some View {
        Text(meal.title)
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(meal.color)
            .padding(.horizontal, 10)
            .frame(height: 24)
            .background(meal.color.opacity(0.11))
            .clipShape(Capsule())
    }
}

struct SwipeToDeleteRow<Content: View>: View {
    let content: Content
    let onDelete: () -> Void

    @State private var offset: CGFloat = 0

    private let actionWidth: CGFloat = 72

    init(@ViewBuilder content: () -> Content, onDelete: @escaping () -> Void) {
        self.content = content()
        self.onDelete = onDelete
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            Button(role: .destructive) {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                    offset = 0
                }
                onDelete()
            } label: {
                Image(systemName: "trash.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Color.red)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(.trailing, 4)
            .opacity(offset < -8 ? 1 : 0)
            .allowsHitTesting(offset < -8)

            content
                .padding(.vertical, 2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    Rectangle()
                        .fill(AppStyle.background)
                }
                .offset(x: offset)
                .zIndex(1)
                .gesture(
                    DragGesture(minimumDistance: 18)
                        .onChanged { value in
                            offset = min(0, max(-actionWidth, value.translation.width))
                        }
                        .onEnded { value in
                            let shouldReveal = value.translation.width < -36 || value.predictedEndTranslation.width < -actionWidth
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                                offset = shouldReveal ? -actionWidth : 0
                            }
                        }
                )
        }
        .contentShape(Rectangle())
    }
}
