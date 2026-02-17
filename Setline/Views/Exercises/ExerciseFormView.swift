import SwiftUI

struct ExerciseFormView: View {
    enum Mode: Identifiable {
        case create
        case edit(Exercise)

        var id: String {
            switch self {
            case .create: return "create"
            case .edit(let exercise): return exercise.id.uuidString
            }
        }
    }

    let viewModel: ExerciseListViewModel
    let mode: Mode

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var bodyPart: BodyPart = .pectoraux
    @State private var exerciseType: ExerciseType = .barreLibre
    @State private var isUnilateral: Bool = false
    @State private var showDuplicateAlert = false

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var editingExercise: Exercise? {
        if case .edit(let exercise) = mode { return exercise }
        return nil
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Nom") {
                    TextField("Nom de l'exercice", text: $name)
                        .autocorrectionDisabled()
                }

                Section("Partie du corps") {
                    Picker("Partie du corps", selection: $bodyPart) {
                        ForEach(BodyPart.allCases) { part in
                            Text(part.rawValue).tag(part)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Type d'exercice") {
                    Picker("Type", selection: $exerciseType) {
                        ForEach(ExerciseType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section {
                    Toggle("Unilatéral", isOn: $isUnilateral)
                } footer: {
                    Text("Le volume sera doublé (×2) pour refléter le travail des deux côtés.")
                }
            }
            .navigationTitle(isEditing ? "Modifier" : "Nouvel exercice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        save()
                    }
                    .disabled(!canSave)
                }
            }
            .alert("Doublon", isPresented: $showDuplicateAlert) {
                Button("Continuer quand même") {
                    forceSave()
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Un exercice avec ce nom existe déjà.")
            }
            .onAppear {
                if let exercise = editingExercise {
                    name = exercise.name
                    bodyPart = exercise.bodyPart
                    exerciseType = exercise.exerciseType
                    isUnilateral = exercise.isUnilateral
                }
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        if viewModel.exerciseNameExists(trimmedName, excluding: editingExercise) {
            showDuplicateAlert = true
            return
        }
        forceSave()
    }

    private func forceSave() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        if let exercise = editingExercise {
            viewModel.updateExercise(exercise, name: trimmedName, bodyPart: bodyPart, exerciseType: exerciseType, isUnilateral: isUnilateral)
        } else {
            viewModel.createExercise(name: trimmedName, bodyPart: bodyPart, exerciseType: exerciseType, isUnilateral: isUnilateral)
        }
        dismiss()
    }
}
