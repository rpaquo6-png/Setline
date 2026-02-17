import Foundation
import SwiftData

@Model
final class Exercise: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var bodyPart: BodyPart
    var exerciseType: ExerciseType
    var isUnilateral: Bool
    var createdAt: Date

    init(name: String, bodyPart: BodyPart, exerciseType: ExerciseType, isUnilateral: Bool = false) {
        self.id = UUID()
        self.name = name
        self.bodyPart = bodyPart
        self.exerciseType = exerciseType
        self.isUnilateral = isUnilateral
        self.createdAt = Date()
    }
}
