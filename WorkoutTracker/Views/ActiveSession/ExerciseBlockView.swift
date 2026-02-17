import SwiftUI

struct ExerciseBlockView: View {
    let group: ActiveSessionViewModel.ExerciseGroup
    let onAddSet: () -> Void
    let onDeleteSet: (WorkoutSet) -> Void
    let onToggleSet: (WorkoutSet) -> Void
    let onRemoveExercise: () -> Void
    let onUpdateRestSeconds: (Int) -> Void
    let onShowHistory: () -> Void

    @State private var showRestEditor = false
    @State private var restSecondsText = ""

    var body: some View {
        Section {
            // Column headers
            HStack(spacing: 8) {
                Text("Série")
                    .frame(width: 24)
                Text("Précédent")
                    .frame(width: 72)
                Text("Reps")
                    .frame(width: 60)
                Text("Charge")
                    .frame(width: 70)
                Spacer()
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            ForEach(group.sets, id: \.id) { set in
                SetRowView(
                    set: set,
                    previousText: group.previousPerformance[set.setNumber]
                ) {
                    onToggleSet(set)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        onDeleteSet(set)
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                }
            }

            Button {
                onAddSet()
            } label: {
                Label("Ajouter une série", systemImage: "plus")
                    .font(.subheadline)
                    .foregroundStyle(Color.accentColor)
            }
        } header: {
            HStack {
                Button {
                    onShowHistory()
                } label: {
                    HStack(spacing: 4) {
                        Text(group.exercise.name)
                            .font(.headline)
                            .textCase(nil)
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.caption)
                    }
                    .foregroundStyle(.primary)
                }

                Spacer()

                // Rest time display (tappable to edit)
                Button {
                    restSecondsText = "\(group.restSeconds)"
                    showRestEditor = true
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "timer")
                            .font(.caption2)
                        Text(formatRestTime(group.restSeconds))
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }

                // Remove exercise button
                Button(role: .destructive) {
                    onRemoveExercise()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .alert("Temps de repos", isPresented: $showRestEditor) {
            TextField("Secondes", text: $restSecondsText)
                .keyboardType(.numberPad)
            Button("OK") {
                if let val = Int(restSecondsText), val > 0 {
                    onUpdateRestSeconds(val)
                }
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Temps de repos en secondes pour \(group.exercise.name)")
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
