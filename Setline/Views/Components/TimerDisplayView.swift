import SwiftUI

struct TimerDisplayView: View {
    let seconds: Int

    var body: some View {
        Text(formatted)
            .font(.system(size: 48, weight: .bold, design: .monospaced))
            .contentTransition(.numericText(countsDown: true))
    }

    private var formatted: String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
