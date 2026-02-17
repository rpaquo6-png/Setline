import Foundation
import SwiftData

@Observable
final class StartSessionViewModel {
    var draftSession: WorkoutSession?
    var templates: [Template] = []

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func load() {
        loadDraftSession()
        loadTemplates()
    }

    func loadDraftSession() {
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate<WorkoutSession> { $0.isFinished == false },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        draftSession = try? modelContext.fetch(descriptor).first
    }

    func loadTemplates() {
        let descriptor = FetchDescriptor<Template>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        templates = (try? modelContext.fetch(descriptor)) ?? []
    }

    func startEmptySession() -> WorkoutSession {
        let session = WorkoutSession()
        modelContext.insert(session)
        draftSession = session
        return session
    }

    func startFromTemplate(_ template: Template) -> WorkoutSession {
        let historyService = ExerciseHistoryService(modelContext: modelContext)
        let session = WorkoutSession(
            sourceTemplateId: template.id,
            sourceTemplateName: template.name
        )
        modelContext.insert(session)

        let sortedExercises = template.sortedExercises

        for (groupIndex, templateExercise) in sortedExercises.enumerated() {
            guard let exercise = templateExercise.exercise else { continue }

            session.setRestSeconds(templateExercise.restSeconds, for: exercise.id)

            for setNumber in 1...templateExercise.plannedSetsCount {
                let (prefillReps, prefillLoad) = historyService.lastKnownValues(
                    for: exercise, setNumber: setNumber
                )
                let workoutSet = WorkoutSet(
                    exercise: exercise,
                    exerciseOrderIndex: groupIndex,
                    setNumber: setNumber,
                    reps: prefillReps,
                    load: prefillLoad
                )
                workoutSet.session = session
                modelContext.insert(workoutSet)
            }
        }

        draftSession = session
        return session
    }

    func deleteSession(_ session: WorkoutSession) {
        modelContext.delete(session)
        if draftSession?.id == session.id {
            draftSession = nil
        }
    }
}
