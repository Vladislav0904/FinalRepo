import Foundation

enum RankingType: String, CaseIterable {
    case atp = "atp"
    case wta = "wta"

    var displayName: String {
        switch self {
        case .atp: return "ATP"
        case .wta: return "WTA"
        }
    }
}
