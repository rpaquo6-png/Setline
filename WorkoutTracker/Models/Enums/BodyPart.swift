import Foundation

enum BodyPart: String, Codable, CaseIterable, Identifiable {
    case bras = "Bras"
    case dos = "Dos"
    case jambes = "Jambes"
    case pectoraux = "Pectoraux"
    case epaules = "Épaules"
    case abdos = "Abdos"
    case fessiers = "Fessiers"

    var id: String { rawValue }
}
