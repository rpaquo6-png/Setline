import SwiftUI

struct TemplateExerciseRow: View {
    @Bindable var templateExercise: TemplateExercise

    @State private var setsText: String = ""
    @State private var restText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(templateExercise.exercise?.name ?? "Exercice inconnu")
                .font(.body.weight(.medium))

            HStack(spacing: 20) {
                HStack(spacing: 6) {
                    Text("Séries")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("3", text: $setsText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 40)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                        .onChange(of: setsText) { _, newValue in
                            if let val = Int(newValue), val > 0 {
                                templateExercise.plannedSetsCount = val
                            }
                        }
                }

                HStack(spacing: 6) {
                    Text("Repos")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("90", text: $restText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 50)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                        .onChange(of: restText) { _, newValue in
                            if let val = Int(newValue), val > 0 {
                                templateExercise.restSeconds = val
                            }
                        }
                    Text("s")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            setsText = "\(templateExercise.plannedSetsCount)"
            restText = "\(templateExercise.restSeconds)"
        }
    }
}
