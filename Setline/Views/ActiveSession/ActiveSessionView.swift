import SwiftUI
import SwiftData

struct ActiveSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var activeSession: WorkoutSession?

    @State private var viewModel: ActiveSessionViewModel?
    @State private var showingExercisePicker = false
    @State private var showFinishConfirmation = false
    @State private var showCancelConfirmation = false
    @State private var historyExercise: Exercise?
    @State private var exerciseToReplace: UUID?

    let restTimerService: RestTimerService

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                if let viewModel {
                    List {
                        if viewModel.exerciseGroups.isEmpty {
                            Section {
                                VStack(spacing: 12) {
                                    Image(systemName: "figure.strengthtraining.traditional")
                                        .font(.system(size: 40))
                                        .foregroundStyle(.secondary)
                                    Text("Séance vide")
                                        .font(.headline)
                                    Text("Ajoutez un exercice pour commencer.")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 32)
                            }
                        } else {
                            ForEach(viewModel.exerciseGroups, id: \.id) { group in
                                ExerciseBlockView(
                                    group: group,
                                    onAddSet: { viewModel.addSet(for: group.id) },
                                    onDeleteSet: { set in viewModel.deleteSet(set) },
                                    onToggleSet: { set in viewModel.toggleSetCompletion(set) },
                                    onRemoveExercise: { viewModel.removeExercise(group.id) },
                                    onReplaceExercise: { exerciseToReplace = group.id },
                                    onUpdateRestSeconds: { seconds in viewModel.updateRestSeconds(for: group.id, seconds: seconds) },
                                    onShowHistory: { historyExercise = group.exercise }
                                )
                            }
                            .onMove { source, destination in
                                viewModel.moveExercise(from: source, to: destination)
                            }
                        }

                        Section {
                            Button {
                                showingExercisePicker = true
                            } label: {
                                Label("Ajouter un exercice", systemImage: "plus.circle")
                                    .font(.body.weight(.medium))
                            }
                        }

                        // Cancel workout button at the bottom
                        Section {
                            Button(role: .destructive) {
                                showCancelConfirmation = true
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Annuler l'entraînement")
                                        .font(.body.weight(.medium))
                                    Spacer()
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)

                    RestTimerView(restTimerService: restTimerService)
                }
            }
            .navigationTitle("Séance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if let session = viewModel?.session {
                        Text(session.startedAt, style: .timer)
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFinishConfirmation = true
                    } label: {
                        Text("Terminer")
                            .font(.body.weight(.semibold))
                    }
                    .tint(.green)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("OK") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
            // Finish workout confirmation
            .confirmationDialog(
                "Terminer l'entraînement ?",
                isPresented: $showFinishConfirmation,
                titleVisibility: .visible
            ) {
                Button("Terminer") {
                    viewModel?.finishWorkout()
                    // Small delay to let SwiftData propagate the save to @Query observers
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        activeSession = nil
                    }
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Les séries non complétées seront supprimées.")
            }
            // Cancel workout confirmation
            .confirmationDialog(
                "Annuler l'entraînement ?",
                isPresented: $showCancelConfirmation,
                titleVisibility: .visible
            ) {
                Button("Annuler l'entraînement", role: .destructive) {
                    viewModel?.cancelWorkout()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        activeSession = nil
                    }
                }
                Button("Continuer", role: .cancel) {}
            } message: {
                Text("L'entraînement sera supprimé et toutes les séries seront perdues.")
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerSheet(onSelectExercise: { exercise in
                    viewModel?.addExercise(exercise)
                })
            }
            .sheet(isPresented: Binding(
                get: { exerciseToReplace != nil },
                set: { if !$0 { exerciseToReplace = nil } }
            )) {
                ExercisePickerSheet(
                    title: "Remplacer l'exercice",
                    onSelectExercise: { exercise in
                        if let id = exerciseToReplace {
                            viewModel?.substituteExercise(exerciseId: id, newExercise: exercise)
                        }
                        exerciseToReplace = nil
                    }
                )
            }
            .sheet(item: $historyExercise) { exercise in
                ExerciseHistoryView(exercise: exercise)
            }
            .onAppear {
                if viewModel == nil, let session = activeSession {
                    viewModel = ActiveSessionViewModel(
                        session: session,
                        modelContext: modelContext,
                        restTimerService: restTimerService
                    )
                }
            }
        }
    }
}

private struct ExercisePickerSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    var title: String = "Ajouter un exercice"
    let onSelectExercise: (Exercise) -> Void

    @State private var exercises: [Exercise] = []
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredExercises, id: \.id) { exercise in
                    Button {
                        onSelectExercise(exercise)
                        dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(exercise.name)
                                .font(.body)
                                .foregroundStyle(.primary)
                            Text(exercise.bodyPart.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Rechercher")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                let descriptor = FetchDescriptor<Exercise>(
                    sortBy: [SortDescriptor(\.name)]
                )
                exercises = (try? modelContext.fetch(descriptor)) ?? []
            }
        }
    }

    private var filteredExercises: [Exercise] {
        if searchText.isEmpty { return exercises }
        return exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}
