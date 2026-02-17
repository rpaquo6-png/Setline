import AppIntents
import ActivityKit

struct EndRestIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Terminer le repos"
    static let description: IntentDescription = IntentDescription("Termine le repos et passe à la série suivante")

    func perform() async throws -> some IntentResult {
        // Signal the main app via App Group UserDefaults
        let defaults = UserDefaults(suiteName: "group.com.setlineclaude.app")
        defaults?.set(true, forKey: "endRestRequested")
        defaults?.synchronize()

        // End all active Live Activities for this app
        for activity in Activity<WorkoutActivityAttributes>.activities {
            let finalState = WorkoutActivityAttributes.ContentState(
                remainingSeconds: 0,
                totalSeconds: 0,
                suggestedReps: nil,
                suggestedLoad: nil
            )
            await activity.end(
                ActivityContent(state: finalState, staleDate: nil),
                dismissalPolicy: .immediate
            )
        }

        return .result()
    }
}
