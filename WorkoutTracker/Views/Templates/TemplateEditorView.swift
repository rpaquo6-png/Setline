import SwiftUI
import SwiftData

struct TemplateEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let template: Template?

    @State private var viewModel: TemplateEditorViewModel?
    @State private var showingExercisePicker = false
    @State private var didInitialize = false

    var body: some View {
        content
            .onAppear {
                initializeIfNeeded()
            }
    }

    @ViewBuilder
    private var content: some View {
        if let viewModel {
            Form {
                Section("Nom du modèle") {
                    TextField("Ex : Push, Pull, Legs...", text: Binding(
                        get: { viewModel.templateName },
                        set: { viewModel.templateName = $0 }
                    ))
                    .autocorrectionDisabled()
                }

                Section {
                    if viewModel.sortedTemplateExercises.isEmpty {
                        Text("Aucun exercice ajouté")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.sortedTemplateExercises, id: \.id) { te in
                            TemplateExerciseRow(templateExercise: te)
                        }
                        .onMove { source, destination in
                            viewModel.moveExercise(from: source, to: destination)
                        }
                        .onDelete { offsets in
                            viewModel.removeExercise(at: offsets)
                        }
                    }

                    Button {
                        viewModel.loadAllExercises()
                        showingExercisePicker = true
                    } label: {
                        Label("Ajouter des exercices", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Exercices")
                }

                Section {
                    Button {
                        viewModel.save()
                        dismiss()
                    } label: {
                        Text("Enregistrer")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .navigationTitle(viewModel.isEditing ? "Modifier" : "Nouveau modèle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if template == nil {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annuler") {
                            dismiss()
                        }
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("OK") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerView(viewModel: viewModel)
            }
        } else {
            ProgressView()
                .onAppear {
                    initializeIfNeeded()
                }
        }
    }

    private func initializeIfNeeded() {
        guard !didInitialize else { return }
        didInitialize = true
        let vm = TemplateEditorViewModel(modelContext: modelContext, template: template)
        vm.loadAllExercises()
        viewModel = vm
    }
}
