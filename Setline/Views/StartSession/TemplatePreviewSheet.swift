import SwiftUI

struct TemplatePreviewSheet: View {
    let template: Template
    let onStart: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(template.sortedExercises, id: \.id) { templateExercise in
                    if let exercise = templateExercise.exercise {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text(exercise.name)
                                        .font(.body.weight(.medium))
                                    if exercise.isUnilateral {
                                        Text("×2")
                                            .font(.caption2.weight(.semibold))
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 2)
                                            .background(Color.orange.opacity(0.15))
                                            .foregroundStyle(.orange)
                                            .clipShape(RoundedRectangle(cornerRadius: 4))
                                    }
                                }
                                HStack(spacing: 12) {
                                    Label("\(templateExercise.plannedSetsCount) séries", systemImage: "number")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Label(formatRestTime(templateExercise.restSeconds), systemImage: "timer")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(template.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Démarrer") {
                        dismiss()
                        onStart()
                    }
                }
            }
        }
    }

    private func formatRestTime(_ seconds: Int) -> String {
        if seconds >= 60 {
            let m = seconds / 60
            let s = seconds % 60
            return s > 0 ? "\(m)m\(s)s" : "\(m)m"
        }
        return "\(seconds)s"
    }
}
