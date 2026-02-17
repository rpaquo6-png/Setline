import Foundation
import ActivityKit
import UIKit

@MainActor
@Observable
final class RestTimerService {
    var isActive: Bool = false
    var remainingSeconds: Int = 0
    var totalSeconds: Int = 0
    var nextSetInfo: NextSetInfo?

    struct NextSetInfo: Sendable {
        let exerciseName: String
        let setNumber: Int
        let suggestedReps: Int?
        let suggestedLoad: Double?
    }

    private var timer: Timer?
    private var restEndTime: Date?
    private var currentActivity: Activity<WorkoutActivityAttributes>?
    private let appGroupId = "group.com.setlineclaude.app"

    func startRest(seconds: Int, nextSet: NextSetInfo?) {
        endRest()

        self.totalSeconds = seconds
        self.remainingSeconds = seconds
        self.nextSetInfo = nextSet
        self.isActive = true
        self.restEndTime = Date().addingTimeInterval(TimeInterval(seconds))

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }

        startLiveActivity()
    }

    func endRest() {
        timer?.invalidate()
        timer = nil
        isActive = false
        remainingSeconds = 0
        restEndTime = nil
        endLiveActivity()
    }

    private func tick() {
        guard let endTime = restEndTime else {
            endRest()
            return
        }

        let remaining = Int(ceil(endTime.timeIntervalSinceNow))
        if remaining <= 0 {
            endRest()
            triggerHaptic()
            return
        }

        remainingSeconds = remaining
        updateLiveActivity()
        checkEndRestRequested()
    }

    private func checkEndRestRequested() {
        guard let defaults = UserDefaults(suiteName: appGroupId) else { return }
        if defaults.bool(forKey: "endRestRequested") {
            defaults.set(false, forKey: "endRestRequested")
            defaults.synchronize()
            endRest()
        }
    }

    private func triggerHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    // MARK: - Live Activity

    private func startLiveActivity() {
        let authInfo = ActivityAuthorizationInfo()
        print("[LiveActivity] areActivitiesEnabled: \(authInfo.areActivitiesEnabled)")
        guard authInfo.areActivitiesEnabled else {
            print("[LiveActivity] Live Activities are disabled in Settings")
            return
        }

        let attributes = WorkoutActivityAttributes(
            exerciseName: nextSetInfo?.exerciseName ?? "",
            setNumber: nextSetInfo?.setNumber ?? 0
        )
        let state = WorkoutActivityAttributes.ContentState(
            remainingSeconds: remainingSeconds,
            totalSeconds: totalSeconds,
            suggestedReps: nextSetInfo?.suggestedReps,
            suggestedLoad: nextSetInfo?.suggestedLoad
        )

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: nil),
                pushType: nil
            )
            print("[LiveActivity] Started successfully, id: \(currentActivity?.id ?? "nil")")
        } catch {
            print("[LiveActivity] Failed to start: \(error)")
        }
    }

    private func updateLiveActivity() {
        guard let activity = currentActivity else { return }
        let state = WorkoutActivityAttributes.ContentState(
            remainingSeconds: remainingSeconds,
            totalSeconds: totalSeconds,
            suggestedReps: nextSetInfo?.suggestedReps,
            suggestedLoad: nextSetInfo?.suggestedLoad
        )
        let activityToUpdate = activity
        let stateToSend = state
        Task {
            await activityToUpdate.update(ActivityContent(state: stateToSend, staleDate: nil))
        }
    }

    private func endLiveActivity() {
        guard let activity = currentActivity else { return }
        let totalSecs = totalSeconds
        let activityToEnd = activity
        Task {
            let finalState = WorkoutActivityAttributes.ContentState(
                remainingSeconds: 0,
                totalSeconds: totalSecs,
                suggestedReps: nil,
                suggestedLoad: nil
            )
            await activityToEnd.end(
                ActivityContent(state: finalState, staleDate: nil),
                dismissalPolicy: .immediate
            )
        }
        currentActivity = nil
    }
}
