import Foundation
import SwiftData

@Model
final class TemplateExercise {
    @Attribute(.unique) var id: UUID
    var template: Template?
    var exercise: Exercise?
    var orderIndex: Int
    var plannedSetsCount: Int
    var restSeconds: Int

    init(exercise: Exercise, orderIndex: Int, plannedSetsCount: Int = 3, restSeconds: Int = 90) {
        self.id = UUID()
        self.exercise = exercise
        self.orderIndex = orderIndex
        self.plannedSetsCount = plannedSetsCount
        self.restSeconds = restSeconds
    }
}
