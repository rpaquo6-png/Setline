import Foundation
import SwiftData

@Model
final class WorkoutSet {
    @Attribute(.unique) var id: UUID
    var session: WorkoutSession?
    var exercise: Exercise?
    var exerciseOrderIndex: Int
    var setNumber: Int
    var reps: Int?
    var load: Double?
    var isCompleted: Bool
    var completedAt: Date?

    init(exercise: Exercise, exerciseOrderIndex: Int, setNumber: Int, reps: Int? = nil, load: Double? = nil) {
        self.id = UUID()
        self.exercise = exercise
        self.exerciseOrderIndex = exerciseOrderIndex
        self.setNumber = setNumber
        self.reps = reps
        self.load = load
        self.isCompleted = false
        self.completedAt = nil
    }
}
