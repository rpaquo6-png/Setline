import Foundation
import SwiftData

@Observable
final class TemplateListViewModel {
    var templates: [Template] = []

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func loadTemplates() {
        let descriptor = FetchDescriptor<Template>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        templates = (try? modelContext.fetch(descriptor)) ?? []
    }

    func deleteTemplate(_ template: Template) {
        modelContext.delete(template)
        loadTemplates()
    }
}
