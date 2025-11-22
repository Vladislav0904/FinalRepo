import Foundation

struct PlayersResponseDTO: Decodable {
    let success: Int?
    let error: String?
    let result: [PlayerDTO]?

    enum CodingKeys: String, CodingKey {
        case success
        case error
        case result
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decodeIfPresent(Int.self, forKey: .success)
        error = try container.decodeIfPresent(String.self, forKey: .error)
        result = try container.decodeIfPresent([PlayerDTO].self, forKey: .result)
    }
}

struct PlayerDTO: Decodable {
    let playerKey: String
    let playerName: String
    let playerFullName: String?
    let playerCountry: String?
    let playerCountryCode: String?
    let playerBday: String?
    let playerLogo: String?
    let stats: [PlayerStatDTO]?

    enum CodingKeys: String, CodingKey {
        case playerKey
        case playerName
        case playerFullName
        case playerCountry
        case playerCountryCode
        case playerBday
        case playerLogo
        case stats
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let intValue = try? container.decode(Int.self, forKey: .playerKey) {
            playerKey = String(intValue)
        } else {
            playerKey = try container.decode(String.self, forKey: .playerKey)
        }

        playerName = try container.decode(String.self, forKey: .playerName)
        playerFullName = try container.decodeIfPresent(String.self, forKey: .playerFullName)
        playerCountry = try container.decodeIfPresent(String.self, forKey: .playerCountry)
        playerCountryCode = try container.decodeIfPresent(String.self, forKey: .playerCountryCode)
        playerBday = try container.decodeIfPresent(String.self, forKey: .playerBday)
        playerLogo = try container.decodeIfPresent(String.self, forKey: .playerLogo)
        stats = try container.decodeIfPresent([PlayerStatDTO].self, forKey: .stats)
    }
}

struct PlayerStatDTO: Decodable {
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
        case matchesWon = "matches_won"
        case matchesLost = "matches_lost"
        case hardWon = "hard_won"
        case hardLost = "hard_lost"
        case clayWon = "clay_won"
        case clayLost = "clay_lost"
        case grassWon = "grass_won"
        case grassLost = "grass_lost"
    }
}
