import SwiftUI

struct IntegerTextField: View {
    let placeholder: String
    @Binding var value: Int?
    @FocusState private var isFocused: Bool

    var body: some View {
        TextField(placeholder, value: $value, format: .number)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .focused($isFocused)
            .frame(width: 60)
            .padding(.vertical, 6)
            .padding(.horizontal, 4)
            .background(Color(.systemGray6))
            .cornerRadius(6)
    }
}

struct DecimalTextField: View {
    let placeholder: String
    @Binding var value: Double?
    @FocusState private var isFocused: Bool

    var body: some View {
        TextField(placeholder, value: $value, format: .number.precision(.fractionLength(0...1)))
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.center)
            .focused($isFocused)
            .frame(width: 70)
            .padding(.vertical, 6)
            .padding(.horizontal, 4)
            .background(Color(.systemGray6))
            .cornerRadius(6)
    }
}
