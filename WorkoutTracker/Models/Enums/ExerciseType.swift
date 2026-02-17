import Foundation

enum ExerciseType: String, Codable, CaseIterable, Identifiable {
    case poidsLibre = "Poids libre"
    case barreLibre = "Barre libre"
    case smithMachine = "Smith Machine"
    case machine = "Machine"
    case poidsDuCorps = "Poids du corps"

    var id: String { rawValue }
}
