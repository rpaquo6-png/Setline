import Foundation
import SwiftData

@MainActor
@Observable
final class ActiveSessionViewModel {
    var session: WorkoutSession
    var exerciseGroups: [ExerciseGroup] = []

    let restTimerService: RestTimerService

    private let modelContext: ModelContext
    private let historyService: ExerciseHistoryService

    struct ExerciseGroup: Identifiable {
        let id: UUID
        let exercise: Exercise
        var orderIndex: Int
        var sets: [WorkoutSet]
        var restSeconds: Int
        var previousPerformance: [Int: String] // setNumber -> "8 × 40 kg"
        var lastSessionVolume: Double?
        var volumeChangePercent: Double? // % change vs last session
    }

    init(session: WorkoutSession, modelContext: ModelContext, restTimerService: RestTimerService) {
        self.session = session
        self.modelContext = modelContext
        self.restTimerService = restTimerService
        self.historyService = ExerciseHistoryService(modelContext: modelContext)
        rebuildGroups()
    }

    func rebuildGroups() {
        let allSets = session.sets.sorted {
            if $0.exerciseOrderIndex != $1.exerciseOrderIndex {
                return $0.exerciseOrderIndex < $1.exerciseOrderIndex
            }
            return $0.setNumber < $1.setNumber
        }

        var groups: [UUID: ExerciseGroup] = [:]
        var orderedIds: [UUID] = []

        for set in allSets {
            guard let exercise = set.exercise else { continue }
            if groups[exercise.id] != nil {
                groups[exercise.id]!.sets.append(set)
            } else {
                // Compute previous performance for this exercise
                let previous = historyService.previousSetPerformances(for: exercise)

                let lastVolume = historyService.lastSessionVolume(for: exercise)

                groups[exercise.id] = ExerciseGroup(
                    id: exercise.id,
                    exercise: exercise,
                    orderIndex: set.exerciseOrderIndex,
                    sets: [set],
                    restSeconds: session.restSeconds(for: exercise.id),
                    previousPerformance: previous,
                    lastSessionVolume: lastVolume
                )
                orderedIds.append(exercise.id)
            }
        }

        // Compute volume change % now that all sets are collected per group
        for id in orderedIds {
            guard var group = groups[id] else { continue }
            if let lastVolume = group.lastSessionVolume, lastVolume > 0 {
                let multiplier: Double = group.exercise.isUnilateral ? 2 : 1
                let currentVolume = group.sets.reduce(0.0) { sum, set in
                    sum + Double(set.reps ?? 0) * (set.load ?? 0) * multiplier
                }
                group.volumeChangePercent = ((currentVolume - lastVolume) / lastVolume) * 100
            }
            groups[id] = group
        }

        exerciseGroups = orderedIds.compactMap { groups[$0] }
    }

    func addExercise(_ exercise: Exercise) {
        let nextOrderIndex = (exerciseGroups.map(\.orderIndex).max() ?? -1) + 1
        let (prefillReps, prefillLoad) = historyService.lastKnownValues(for: exercise)

        let workoutSet = WorkoutSet(
            exercise: exercise,
            exerciseOrderIndex: nextOrderIndex,
            setNumber: 1,
            reps: prefillReps,
            load: prefillLoad
        )
        workoutSet.session = session
        modelContext.insert(workoutSet)
        rebuildGroups()
    }

    func addSet(for exerciseId: UUID) {
        guard let groupIndex = exerciseGroups.firstIndex(where: { $0.id == exerciseId }),
              let exercise = exerciseGroups[groupIndex].sets.first?.exercise else { return }

        let group = exerciseGroups[groupIndex]
        let nextSetNumber = (group.sets.map(\.setNumber).max() ?? 0) + 1

        let lastCompletedInSession = group.sets
            .filter { $0.isCompleted }
            .sorted { $0.setNumber < $1.setNumber }
            .last

        let reps: Int?
        let load: Double?

        if let lastCompleted = lastCompletedInSession {
            reps = lastCompleted.reps
            load = lastCompleted.load
        } else {
            let (histReps, histLoad) = historyService.lastKnownValues(for: exercise, setNumber: nextSetNumber)
            reps = histReps
            load = histLoad
        }

        let workoutSet = WorkoutSet(
            exercise: exercise,
            exerciseOrderIndex: group.orderIndex,
            setNumber: nextSetNumber,
            reps: reps,
            load: load
        )
        workoutSet.session = session
        modelContext.insert(workoutSet)
        rebuildGroups()
    }

    func deleteSet(_ set: WorkoutSet) {
        modelContext.delete(set)
        rebuildGroups()
    }

    func toggleSetCompletion(_ set: WorkoutSet) {
        if set.isCompleted {
            set.isCompleted = false
            set.completedAt = nil
        } else {
            set.isCompleted = true
            set.completedAt = Date()

            guard let exercise = set.exercise else { return }
            let restSecs = session.restSeconds(for: exercise.id)

            let nextSet = findNextSet(after: set)
            let nextSetInfo: RestTimerService.NextSetInfo?

            if let next = nextSet, let nextExercise = next.exercise {
                nextSetInfo = RestTimerService.NextSetInfo(
                    exerciseName: nextExercise.name,
                    setNumber: next.setNumber,
                    suggestedReps: next.reps,
                    suggestedLoad: next.load
                )
            } else {
                nextSetInfo = nil
            }

            restTimerService.startRest(seconds: restSecs, nextSet: nextSetInfo)
        }
        rebuildGroups()
    }

    func removeExercise(_ exerciseId: UUID) {
        guard let group = exerciseGroups.first(where: { $0.id == exerciseId }) else { return }

        // Delete all sets for this exercise
        for set in group.sets {
            modelContext.delete(set)
        }

        rebuildGroups()
    }

    func substituteExercise(exerciseId: UUID, newExercise: Exercise) {
        guard let group = exerciseGroups.first(where: { $0.id == exerciseId }) else { return }

        // Reassign the exercise on every set (keeps order, setNumber, reps, load, completion)
        for set in group.sets {
            set.exercise = newExercise
        }

        // Transfer rest seconds from old exercise to new one
        let restSecs = session.restSeconds(for: exerciseId)
        session.setRestSeconds(restSecs, for: newExercise.id)

        rebuildGroups()
    }

    func updateRestSeconds(for exerciseId: UUID, seconds: Int) {
        session.setRestSeconds(seconds, for: exerciseId)
        rebuildGroups()
    }

    func moveExercise(from source: IndexSet, to destination: Int) {
        var groups = exerciseGroups
        groups.move(fromOffsets: source, toOffset: destination)

        // Update order indices on the persisted WorkoutSet objects
        for (newIndex, group) in groups.enumerated() {
            for set in group.sets {
                set.exerciseOrderIndex = newIndex
            }
        }

        // Update the local groups with corrected orderIndex values
        // instead of rebuildGroups() which re-reads from session.sets
        // and may not yet reflect the changes
        exerciseGroups = groups.enumerated().map { newIndex, group in
            var updated = group
            updated.orderIndex = newIndex
            return updated
        }
    }

    func finishWorkout() {
        restTimerService.endRest()

        // Delete uncompleted sets
        let uncompleted = session.sets.filter { !$0.isCompleted }
        for set in uncompleted {
            modelContext.delete(set)
        }

        session.status = .completed
        session.isFinished = true
        session.endedAt = Date()

        // Force save to persist the status change immediately
        do {
            try modelContext.save()
        } catch {
            print("[finishWorkout] Save failed: \(error)")
        }
    }

    func cancelWorkout() {
        restTimerService.endRest()

        // Delete all sets
        for set in session.sets {
            modelContext.delete(set)
        }

        // Delete the session itself
        modelContext.delete(session)

        do {
            try modelContext.save()
        } catch {
            print("[cancelWorkout] Save failed: \(error)")
        }
    }

    private func findNextSet(after currentSet: WorkoutSet) -> WorkoutSet? {
        let allSets = session.sets
            .filter { !$0.isCompleted }
            .sorted {
                if $0.exerciseOrderIndex != $1.exerciseOrderIndex {
                    return $0.exerciseOrderIndex < $1.exerciseOrderIndex
                }
                return $0.setNumber < $1.setNumber
            }

        guard let currentIndex = allSets.firstIndex(where: { $0.id == currentSet.id }) else {
            return allSets.first
        }

        let nextIndex = allSets.index(after: currentIndex)
        return nextIndex < allSets.endIndex ? allSets[nextIndex] : allSets.first
    }
}
