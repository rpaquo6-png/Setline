import Foundation
import SwiftData

@Observable
final class ExerciseListViewModel {
    var exercises: [Exercise] = []
    var searchText: String = ""
    var filterBodyPart: BodyPart? = nil

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    var filteredExercises: [Exercise] {
        exercises.filter { exercise in
            let matchesSearch = searchText.isEmpty ||
                exercise.name.localizedCaseInsensitiveContains(searchText)
            let matchesFilter = filterBodyPart == nil || exercise.bodyPart == filterBodyPart
            return matchesSearch && matchesFilter
        }
    }

    func loadExercises() {
        let descriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.name)]
        )
        exercises = (try? modelContext.fetch(descriptor)) ?? []
    }

    func createExercise(name: String, bodyPart: BodyPart, exerciseType: ExerciseType) {
        let exercise = Exercise(name: name, bodyPart: bodyPart, exerciseType: exerciseType)
        modelContext.insert(exercise)
        loadExercises()
    }

    func updateExercise(_ exercise: Exercise, name: String, bodyPart: BodyPart, exerciseType: ExerciseType) {
        exercise.name = name
        exercise.bodyPart = bodyPart
        exercise.exerciseType = exerciseType
        loadExercises()
    }

    func deleteExercise(_ exercise: Exercise) {
        modelContext.delete(exercise)
        loadExercises()
    }

    func exerciseNameExists(_ name: String, excluding: Exercise? = nil) -> Bool {
        exercises.contains { exercise in
            exercise.name.localizedCaseInsensitiveCompare(name) == .orderedSame &&
            exercise.id != excluding?.id
        }
    }
}
