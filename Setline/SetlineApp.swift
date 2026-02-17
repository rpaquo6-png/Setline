import SwiftUI
import SwiftData

@main
struct SetlineApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for:
                Exercise.self,
                Template.self,
                TemplateExercise.self,
                WorkoutSession.self,
                WorkoutSet.self
            )
            // Seed default exercises on first launch
            let context = modelContainer.mainContext
            DefaultExerciseLibrary.seedIfNeeded(modelContext: context)
            DefaultExerciseLibrary.migrateUnilateral(modelContext: context)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
