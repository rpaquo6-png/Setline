import SwiftUI

struct SetRowView: View {
    @Bindable var set: WorkoutSet
    let previousText: String?
    let onToggleComplete: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            // Set number
            Text("\(set.setNumber)")
                .font(.body.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 24)

            // Previous performance
            Text(previousText ?? "–")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .frame(width: 72)
                .lineLimit(1)

            // Reps input
            IntegerTextField(placeholder: "Reps", value: $set.reps)

            // Load input
            DecimalTextField(placeholder: "kg", value: $set.load)

            // Checkmark button
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    onToggleComplete()
                }
            } label: {
                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(set.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .opacity(set.isCompleted ? 0.7 : 1.0)
    }
}
