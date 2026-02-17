import SwiftUI
import SwiftData

struct ExerciseHistoryView: View {
    let exercise: Exercise
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var entries: [ExerciseHistoryService.HistoryEntry] = []

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("Aucun historique")
                            .font(.headline)
                        Text("Terminez un entraînement avec cet exercice pour voir l'historique.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(40)
                } else {
                    List {
                        ForEach(entries) { entry in
                            Section {
                                ForEach(entry.sets) { setRecord in
                                    HStack {
                                        Text("Série \(setRecord.setNumber)")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .frame(width: 60, alignment: .leading)

                                        Spacer()

                                        if let reps = setRecord.reps {
                                            Text("\(reps) reps")
                                                .font(.subheadline)
                                        } else {
                                            Text("– reps")
                                                .font(.subheadline)
                                                .foregroundStyle(.tertiary)
                                        }

                                        Spacer()

                                        if let load = setRecord.load {
                                            Text("\(load, specifier: "%.1f") kg")
                                                .font(.subheadline.weight(.medium))
                                        } else {
                                            Text("– kg")
                                                .font(.subheadline)
                                                .foregroundStyle(.tertiary)
                                        }
                                    }
                                }
                            } header: {
                                HStack {
                                    Text(formattedDate(entry.date))
                                        .font(.subheadline.weight(.semibold))
                                        .textCase(nil)
                                    Spacer()
                                    if let name = entry.templateName {
                                        Text(name)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .textCase(nil)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle(exercise.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                let service = ExerciseHistoryService(modelContext: modelContext)
                entries = service.history(for: exercise)
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
