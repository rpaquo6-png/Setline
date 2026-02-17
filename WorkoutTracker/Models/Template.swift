import Foundation
import SwiftData

@Model
final class Template {
    @Attribute(.unique) var id: UUID
    var name: String
    @Relationship(deleteRule: .cascade, inverse: \TemplateExercise.template)
    var exercises: [TemplateExercise]
    var createdAt: Date
    var updatedAt: Date

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.exercises = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var sortedExercises: [TemplateExercise] {
        exercises.sorted { $0.orderIndex < $1.orderIndex }
    }
}
