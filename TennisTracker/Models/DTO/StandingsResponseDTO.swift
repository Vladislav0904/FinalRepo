import Foundation

struct StandingsResponseDTO: Decodable {
    let success: Int?
    let error: String?
    let result: [StandingDTO]?

    enum CodingKeys: String, CodingKey {
        case success
        case error
        case result
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decodeIfPresent(Int.self, forKey: .success)
        error = try container.decodeIfPresent(String.self, forKey: .error)
        result = try container.decodeIfPresent([StandingDTO].self, forKey: .result)
    }
}

struct StandingDTO: Decodable {
    let playerKey: String?
    let playerName: String
    let playerCountry: String?
    let playerCountryCode: String?
    let playerLogo: String?
    let rank: String?
    let points: String?
    let tournamentPlayed: String?
    let league: String?
    let movement: String?

    enum CodingKeys: String, CodingKey {
        case playerKey
        case playerName
        case playerCountry
        case playerCountryCode
        case playerLogo
        case rank
        case place
        case points
        case tournamentPlayed
        case league
        case movement
        case player
        case country
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let stringValue = try? container.decode(String.self, forKey: .playerKey) {
            playerKey = stringValue
        } else if let intValue = try? container.decode(Int.self, forKey: .playerKey) {
            playerKey = String(intValue)
        } else if let doubleValue = try? container.decode(Double.self, forKey: .playerKey) {
            playerKey = String(Int(doubleValue))
        } else {

            playerKey = nil
        }

        do {
            if let playerNameValue = try container.decodeIfPresent(String.self, forKey: .playerName), !playerNameValue.isEmpty {
                playerName = playerNameValue
            } else if let playerValue = try container.decodeIfPresent(String.self, forKey: .player), !playerValue.isEmpty {
                playerName = playerValue
            } else {
                playerName = ""
            }
        } catch {
            playerName = ""
        }

        if let playerCountryValue = try? container.decodeIfPresent(String.self, forKey: .playerCountry) {
            playerCountry = playerCountryValue
        } else if let countryValue = try? container.decodeIfPresent(String.self, forKey: .country) {
            playerCountry = countryValue
        } else {
            playerCountry = nil
        }

        playerCountryCode = try container.decodeIfPresent(String.self, forKey: .playerCountryCode)
        playerLogo = try container.decodeIfPresent(String.self, forKey: .playerLogo)

        if let rankValue = try? container.decodeIfPresent(String.self, forKey: .rank) {
            rank = rankValue
        } else if let placeValue = try? container.decodeIfPresent(String.self, forKey: .place) {
            rank = placeValue
        } else {
            rank = nil
        }

        points = try container.decodeIfPresent(String.self, forKey: .points)
        tournamentPlayed = try container.decodeIfPresent(String.self, forKey: .tournamentPlayed)
        league = try container.decodeIfPresent(String.self, forKey: .league)
        movement = try container.decodeIfPresent(String.self, forKey: .movement)
    }
}
