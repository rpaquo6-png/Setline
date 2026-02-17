import Foundation
import SwiftData

@Observable
final class TemplateEditorViewModel {
    var templateName: String = ""
    var templateExercises: [TemplateExercise] = []
    var allExercises: [Exercise] = []

    let isEditing: Bool
    private var existingTemplate: Template?
    private let modelContext: ModelContext

    var canSave: Bool {
        !templateName.trimmingCharacters(in: .whitespaces).isEmpty && !templateExercises.isEmpty
    }

    var sortedTemplateExercises: [TemplateExercise] {
        templateExercises.sorted { $0.orderIndex < $1.orderIndex }
    }

    init(modelContext: ModelContext, template: Template? = nil) {
        self.modelContext = modelContext
        self.isEditing = template != nil
        self.existingTemplate = template

        if let template {
            self.templateName = template.name
            self.templateExercises = template.sortedExercises
        }
    }

    func loadAllExercises() {
        let descriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.name)]
        )
        allExercises = (try? modelContext.fetch(descriptor)) ?? []
    }

    func isExerciseInTemplate(_ exercise: Exercise) -> Bool {
        templateExercises.contains { $0.exercise?.id == exercise.id }
    }

    func toggleExercise(_ exercise: Exercise) {
        if let index = templateExercises.firstIndex(where: { $0.exercise?.id == exercise.id }) {
            let te = templateExercises[index]
            templateExercises.remove(at: index)
            if isEditing {
                modelContext.delete(te)
            }
            reindexExercises()
        } else {
            let te = TemplateExercise(
                exercise: exercise,
                orderIndex: templateExercises.count
            )
            templateExercises.append(te)
        }
    }

    func removeExercise(at offsets: IndexSet) {
        let sorted = sortedTemplateExercises
        for index in offsets {
            let te = sorted[index]
            if let realIndex = templateExercises.firstIndex(where: { $0.id == te.id }) {
                templateExercises.remove(at: realIndex)
                if isEditing {
                    modelContext.delete(te)
                }
            }
        }
        reindexExercises()
    }

    func moveExercise(from source: IndexSet, to destination: Int) {
        var sorted = sortedTemplateExercises
        sorted.move(fromOffsets: source, toOffset: destination)
        for (index, te) in sorted.enumerated() {
            te.orderIndex = index
        }
        templateExercises = sorted
    }

    func save() {
        if let existing = existingTemplate {
            existing.name = templateName
            // Remove exercises not in current list
            let currentIds = Set(templateExercises.map(\.id))
            for te in existing.exercises where !currentIds.contains(te.id) {
                modelContext.delete(te)
            }
            existing.exercises = templateExercises
            for te in templateExercises {
                te.template = existing
            }
            existing.updatedAt = Date()
        } else {
            let template = Template(name: templateName)
            modelContext.insert(template)
            for te in templateExercises {
                te.template = template
                modelContext.insert(te)
            }
            template.exercises = templateExercises
        }
    }

    private func reindexExercises() {
        let sorted = templateExercises.sorted { $0.orderIndex < $1.orderIndex }
        for (index, te) in sorted.enumerated() {
            te.orderIndex = index
        }
    }
}
