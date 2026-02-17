import ActivityKit
import Foundation

struct WorkoutActivityAttributes: ActivityAttributes {
    let exerciseName: String
    let setNumber: Int

    struct ContentState: Codable, Hashable {
        let remainingSeconds: Int
        let totalSeconds: Int
        let suggestedReps: Int?
        let suggestedLoad: Double?
    }
}
