import SwiftUI
import WidgetKit
import ActivityKit

struct WorkoutLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            // Lock Screen / Banner presentation
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Repos")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatTime(context.state.remainingSeconds))
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText(countsDown: true))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Prochaine série")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(context.attributes.exerciseName)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    if let reps = context.state.suggestedReps {
                        HStack(spacing: 2) {
                            Text("\(reps) reps")
                            if let load = context.state.suggestedLoad, load > 0 {
                                Text("× \(String(format: "%.1f", load)) kg")
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }

                Button(intent: EndRestIntent()) {
                    Image(systemName: "forward.fill")
                        .font(.title3)
                        .padding(8)
                }
                .tint(.orange)
            }
            .padding()
            .activityBackgroundTint(.black.opacity(0.85))

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Repos")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(formatTime(context.state.remainingSeconds))
                            .font(.title2.bold().monospacedDigit())
                            .contentTransition(.numericText(countsDown: true))
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Button(intent: EndRestIntent()) {
                        Text("Passer")
                            .font(.caption.bold())
                    }
                    .tint(.orange)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.attributes.exerciseName)
                            .font(.caption)
                        Text("— Série \(context.attributes.setNumber)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } compactLeading: {
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .foregroundStyle(.orange)
                    Text(formatTime(context.state.remainingSeconds))
                        .font(.caption.monospacedDigit().bold())
                        .contentTransition(.numericText(countsDown: true))
                }
            } compactTrailing: {
                Text(context.attributes.exerciseName)
                    .font(.caption2)
                    .lineLimit(1)
                    .frame(maxWidth: 60)
            } minimal: {
                Text(formatTime(context.state.remainingSeconds))
                    .font(.caption2.monospacedDigit())
                    .contentTransition(.numericText(countsDown: true))
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
