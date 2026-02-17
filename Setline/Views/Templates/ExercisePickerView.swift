import SwiftUI

struct ExercisePickerView: View {
    var viewModel: TemplateEditorViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.allExercises.isEmpty {
                    EmptyStateView(
                        icon: "dumbbell",
                        title: "Aucun exercice",
                        message: "Créez d'abord des exercices dans l'onglet Exercices."
                    )
                } else {
                    List {
                        ForEach(filteredExercises, id: \.id) { exercise in
                            Button {
                                viewModel.toggleExercise(exercise)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(exercise.name)
                                            .font(.body)
                                            .foregroundStyle(.primary)
                                        Text(exercise.bodyPart.rawValue)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    if viewModel.isExerciseInTemplate(exercise) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Color.accentColor)
                                            .font(.title3)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundStyle(.secondary)
                                            .font(.title3)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Ajouter des exercices")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Rechercher")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return viewModel.allExercises
        }
        return viewModel.allExercises.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
}
