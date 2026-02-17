import SwiftUI
import SwiftData

struct TemplateListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: TemplateListViewModel?
    @State private var showingEditor = false

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    if viewModel.templates.isEmpty {
                        EmptyStateView(
                            icon: "doc.text",
                            title: "Aucun modèle",
                            message: "Créez un modèle pour préparer vos entraînements."
                        )
                    } else {
                        List {
                            ForEach(viewModel.templates, id: \.id) { template in
                                NavigationLink(value: template.id) {
                                    TemplateRow(template: template)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.deleteTemplate(template)
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
            .navigationTitle("Modèles")
            .navigationDestination(for: UUID.self) { templateId in
                if let template = viewModel?.templates.first(where: { $0.id == templateId }) {
                    TemplateEditorView(template: template)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingEditor) {
                viewModel?.loadTemplates()
            } content: {
                TemplateEditorView(template: nil)
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = TemplateListViewModel(modelContext: modelContext)
                }
                viewModel?.loadTemplates()
            }
        }
    }
}

private struct TemplateRow: View {
    let template: Template

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(template.name)
                .font(.body.weight(.medium))
            let exerciseNames = template.sortedExercises.compactMap(\.exercise?.name)
            if !exerciseNames.isEmpty {
                Text(exerciseNames.joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Text("\(template.exercises.count) exercice\(template.exercises.count > 1 ? "s" : "")")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }
}
