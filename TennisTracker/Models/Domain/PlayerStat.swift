import Foundation

struct PlayerStat: Codable {
    let season: String?
    let type: String?
    let rank: String?
    let titles: String?
    let matchesWon: String?
    let matchesLost: String?
    let hardWon: String?
    let hardLost: String?
    let clayWon: String?
    let clayLost: String?
    let grassWon: String?
    let grassLost: String?

    enum CodingKeys: String, CodingKey {
        case season
        case type
        case rank
        case titles
        case matchesWon
        case matchesLost
        case hardWon
        case hardLost
        case clayWon
        case clayLost
        case grassWon
        case grassLost
    }
}
