import SwiftUI
import SwiftData

struct StartSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: StartSessionViewModel?
    @Binding var activeSession: WorkoutSession?
    @State private var showDeleteConfirmation = false
    @State private var selectedTemplate: Template?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Draft session banner
                    if let draft = viewModel?.draftSession {
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Séance en cours")
                                        .font(.headline)
                                    Text(draft.startedAt, style: .relative)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    if let templateName = draft.sourceTemplateName {
                                        Text(templateName)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                            }

                            HStack(spacing: 12) {
                                Button {
                                    activeSession = draft
                                } label: {
                                    Text("Reprendre")
                                        .font(.body.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                }
                                .buttonStyle(.borderedProminent)

                                Button(role: .destructive) {
                                    showDeleteConfirmation = true
                                } label: {
                                    Image(systemName: "trash")
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 16)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    // Start empty session
                    Button {
                        if let vm = viewModel {
                            let session = vm.startEmptySession()
                            activeSession = session
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("Séance vide")
                                .font(.body.weight(.semibold))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                    .disabled(viewModel?.draftSession != nil)

                    // Templates
                    if let templates = viewModel?.templates, !templates.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Depuis un modèle")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(templates, id: \.id) { template in
                                Button {
                                    selectedTemplate = template
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(template.name)
                                                .font(.body.weight(.medium))
                                            let names = template.sortedExercises.compactMap(\.exercise?.name)
                                            if !names.isEmpty {
                                                Text(names.joined(separator: ", "))
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                    .lineLimit(1)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal)
                                .disabled(viewModel?.draftSession != nil)
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Entraînement")
            .confirmationDialog(
                "Supprimer la séance en cours ?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Supprimer", role: .destructive) {
                    if let draft = viewModel?.draftSession {
                        viewModel?.deleteSession(draft)
                    }
                }
            } message: {
                Text("Cette action est irréversible. Toutes les séries seront perdues.")
            }
            .sheet(item: $selectedTemplate) { template in
                TemplatePreviewSheet(template: template) {
                    if let vm = viewModel {
                        let session = vm.startFromTemplate(template)
                        activeSession = session
                    }
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = StartSessionViewModel(modelContext: modelContext)
                }
                viewModel?.load()
            }
            .onChange(of: activeSession) { _, newValue in
                if newValue == nil {
                    // Session was dismissed (finished or cancelled) — reload data
                    viewModel?.load()
                }
            }
        }
    }
}
