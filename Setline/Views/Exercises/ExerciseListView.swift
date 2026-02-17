import SwiftUI
import SwiftData

struct ExerciseListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ExerciseListViewModel?
    @State private var showingAddSheet = false
    @State private var exerciseToEdit: Exercise?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    if viewModel.filteredExercises.isEmpty {
                        if viewModel.exercises.isEmpty {
                            EmptyStateView(
                                icon: "dumbbell",
                                title: "Aucun exercice",
                                message: "Ajoutez votre premier exercice pour commencer."
                            )
                        } else {
                            EmptyStateView(
                                icon: "magnifyingglass",
                                title: "Aucun résultat",
                                message: "Aucun exercice ne correspond à votre recherche."
                            )
                        }
                    } else {
                        List {
                            ForEach(viewModel.filteredExercises, id: \.id) { exercise in
                                ExerciseRow(exercise: exercise)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        exerciseToEdit = exercise
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            viewModel.deleteExercise(exercise)
                                        } label: {
                                            Label("Supprimer", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Exercices")
            .searchable(text: Binding(
                get: { viewModel?.searchText ?? "" },
                set: { viewModel?.searchText = $0 }
            ), prompt: "Rechercher un exercice")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button("Tous") {
                            viewModel?.filterBodyPart = nil
                        }
                        ForEach(BodyPart.allCases) { part in
                            Button(part.rawValue) {
                                viewModel?.filterBodyPart = part
                            }
                        }
                    } label: {
                        Label(
                            viewModel?.filterBodyPart?.rawValue ?? "Filtre",
                            systemImage: "line.3.horizontal.decrease.circle"
                        )
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                if let viewModel {
                    ExerciseFormView(viewModel: viewModel, mode: .create)
                }
            }
            .sheet(item: $exerciseToEdit) { exercise in
                if let viewModel {
                    ExerciseFormView(viewModel: viewModel, mode: .edit(exercise))
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = ExerciseListViewModel(modelContext: modelContext)
                }
                viewModel?.loadExercises()
            }
        }
    }
}

private struct ExerciseRow: View {
    let exercise: Exercise

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exercise.name)
                .font(.body.weight(.medium))
            HStack(spacing: 8) {
                Text(exercise.bodyPart.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.15))
                    .cornerRadius(4)
                Text(exercise.exerciseType.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if exercise.isUnilateral {
                    Text("Unilatéral")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.15))
                        .foregroundStyle(.orange)
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 2)
    }
}
