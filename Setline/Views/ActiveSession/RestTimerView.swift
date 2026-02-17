import SwiftUI

struct RestTimerView: View {
    let restTimerService: RestTimerService

    var body: some View {
        if restTimerService.isActive {
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Repos")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let next = restTimerService.nextSetInfo {
                            Text(next.exerciseName)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    Text(formatTime(restTimerService.remainingSeconds))
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .contentTransition(.numericText(countsDown: true))

                    Spacer()

                    Button {
                        restTimerService.endRest()
                    } label: {
                        Text("Passer")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
