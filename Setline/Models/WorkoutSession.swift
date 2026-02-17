import Foundation
import SwiftData

@Model
final class WorkoutSession {
    @Attribute(.unique) var id: UUID
    var startedAt: Date
    var endedAt: Date?
    var sourceTemplateId: UUID?
    var sourceTemplateName: String?
    var status: SessionStatus
    var isFinished: Bool
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.session)
    var sets: [WorkoutSet]
    var exerciseRestSeconds: [String: Int]

    init(sourceTemplateId: UUID? = nil, sourceTemplateName: String? = nil) {
        self.id = UUID()
        self.startedAt = Date()
        self.endedAt = nil
        self.sourceTemplateId = sourceTemplateId
        self.sourceTemplateName = sourceTemplateName
        self.status = .inProgress
        self.isFinished = false
        self.sets = []
        self.exerciseRestSeconds = [:]
    }

    func restSeconds(for exerciseId: UUID) -> Int {
        exerciseRestSeconds[exerciseId.uuidString] ?? 90
    }

    func setRestSeconds(_ seconds: Int, for exerciseId: UUID) {
        exerciseRestSeconds[exerciseId.uuidString] = seconds
    }
}
