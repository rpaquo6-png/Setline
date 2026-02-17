import Foundation
import SwiftData

final class ExerciseHistoryService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Pre-fill values for new sets

    func lastKnownValues(for exercise: Exercise) -> (reps: Int?, load: Double?) {
        let exerciseId = exercise.id
        var descriptor = FetchDescriptor<WorkoutSet>(
            predicate: #Predicate<WorkoutSet> {
                $0.exercise?.id == exerciseId &&
                $0.isCompleted == true
            },
            sortBy: [SortDescriptor(\WorkoutSet.completedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 20

        guard let sets = try? modelContext.fetch(descriptor) else {
            return (nil, nil)
        }

        // Filter in memory: only from completed sessions
        guard let lastSet = sets.first(where: { $0.session?.status == .completed }) else {
            return (nil, nil)
        }
        return (lastSet.reps, lastSet.load)
    }

    func lastKnownValues(for exercise: Exercise, setNumber: Int) -> (reps: Int?, load: Double?) {
        let exerciseId = exercise.id
        var descriptor = FetchDescriptor<WorkoutSet>(
            predicate: #Predicate<WorkoutSet> {
                $0.exercise?.id == exerciseId &&
                $0.isCompleted == true &&
                $0.setNumber == setNumber
            },
            sortBy: [SortDescriptor(\WorkoutSet.completedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 20

        if let sets = try? modelContext.fetch(descriptor),
           let matchingSet = sets.first(where: { $0.session?.status == .completed }) {
            return (matchingSet.reps, matchingSet.load)
        }
        return lastKnownValues(for: exercise)
    }

    // MARK: - Full history for an exercise

    struct HistoryEntry: Identifiable {
        let id: UUID
        let date: Date
        let templateName: String?
        let sets: [SetRecord]

        struct SetRecord: Identifiable {
            let id: UUID
            let setNumber: Int
            let reps: Int?
            let load: Double?
        }
    }

    // MARK: - Previous performance per set (for "Previous" column like Strong)

    /// Returns a dictionary: setNumber -> formatted string like "8 × 40 kg"
    func previousSetPerformances(for exercise: Exercise) -> [Int: String] {
        let entries = history(for: exercise)
        guard let lastSession = entries.first else { return [:] }

        var result: [Int: String] = [:]
        for setRecord in lastSession.sets {
            let repsStr = setRecord.reps.map { "\($0)" } ?? "–"
            let loadStr = setRecord.load.map { load -> String in
                if load == load.rounded() {
                    return "\(Int(load)) kg"
                }
                return String(format: "%.1f kg", load)
            } ?? "– kg"
            result[setRecord.setNumber] = "\(repsStr) × \(loadStr)"
        }
        return result
    }

    func history(for exercise: Exercise) -> [HistoryEntry] {
        let exerciseId = exercise.id
        let descriptor = FetchDescriptor<WorkoutSet>(
            predicate: #Predicate<WorkoutSet> {
                $0.exercise?.id == exerciseId &&
                $0.isCompleted == true
            },
            sortBy: [SortDescriptor(\WorkoutSet.completedAt, order: .reverse)]
        )

        guard let allSets = try? modelContext.fetch(descriptor) else { return [] }

        // Filter in memory: only from completed sessions
        let completedSets = allSets.filter { $0.session?.status == .completed }

        // Group by session
        var sessionMap: [UUID: (session: WorkoutSession, sets: [WorkoutSet])] = [:]
        var sessionOrder: [UUID] = []

        for set in completedSets {
            guard let session = set.session else { continue }
            if sessionMap[session.id] == nil {
                sessionMap[session.id] = (session: session, sets: [])
                sessionOrder.append(session.id)
            }
            sessionMap[session.id]?.sets.append(set)
        }

        return sessionOrder.compactMap { sessionId -> HistoryEntry? in
            guard let entry = sessionMap[sessionId] else { return nil }
            let sortedSets = entry.sets.sorted { $0.setNumber < $1.setNumber }
            return HistoryEntry(
                id: sessionId,
                date: entry.session.startedAt,
                templateName: entry.session.sourceTemplateName,
                sets: sortedSets.map { set in
                    HistoryEntry.SetRecord(
                        id: set.id,
                        setNumber: set.setNumber,
                        reps: set.reps,
                        load: set.load
                    )
                }
            )
        }
    }
}
