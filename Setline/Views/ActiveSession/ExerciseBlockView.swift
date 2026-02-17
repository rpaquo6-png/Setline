import SwiftUI

struct ExerciseBlockView: View {
    let group: ActiveSessionViewModel.ExerciseGroup
    let onAddSet: () -> Void
    let onDeleteSet: (WorkoutSet) -> Void
    let onToggleSet: (WorkoutSet) -> Void
    let onRemoveExercise: () -> Void
    let onReplaceExercise: () -> Void
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
                .moveDisabled(true)
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
                Text(group.exercise.name)
                    .font(.headline)
                    .textCase(nil)
                    .foregroundStyle(.primary)

                if let percent = group.volumeChangePercent {
                    Text(formatVolumeChange(percent))
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(percent >= 0 ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                        .foregroundStyle(percent >= 0 ? .green : .red)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
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

                // Actions menu
                Menu {
                    Button {
                        onShowHistory()
                    } label: {
                        Label("Historique", systemImage: "clock.arrow.circlepath")
                    }

                    Button {
                        onReplaceExercise()
                    } label: {
                        Label("Remplacer l'exercice", systemImage: "arrow.triangle.2.circlepath")
                    }

                    Divider()

                    Button(role: .destructive) {
                        onRemoveExercise()
                    } label: {
                        Label("Supprimer l'exercice", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
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

    private func formatVolumeChange(_ percent: Double) -> String {
        let rounded = Int(percent.rounded())
        return rounded >= 0 ? "+\(rounded)%" : "\(rounded)%"
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
