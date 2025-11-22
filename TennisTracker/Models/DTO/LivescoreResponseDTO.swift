import Foundation

struct LivescoreResponseDTO: Decodable {
    let success: Int?
    let error: String?
    let result: [LiveMatchDTO]?

    enum CodingKeys: String, CodingKey {
        case success
        case error
        case result
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decodeIfPresent(Int.self, forKey: .success)
        error = try container.decodeIfPresent(String.self, forKey: .error)
        result = try container.decodeIfPresent([LiveMatchDTO].self, forKey: .result)
    }
}

struct LiveMatchDTO: Decodable {
    let eventKey: String
    let eventDate: String
    let eventTime: String
    let eventFirstPlayer: String?
    let firstPlayerKey: String
    let eventSecondPlayer: String?
    let secondPlayerKey: String
    let eventGameResult: String?
    let eventServe: String?
    let eventWinner: String?
    let eventStatus: String
    let eventTypeType: String
    let tournamentName: String
    let tournamentKey: String
    let tournamentRound: String?
    let tournamentSeason: String
    let eventLive: String
    let eventFirstPlayerLogo: String?
    let eventSecondPlayerLogo: String?
    let eventQualification: String?
    let scores: [ScoreDTO]?
    let pointByPoint: [PointByPointDTO]?

    enum CodingKeys: String, CodingKey {
        case eventKey
        case eventDate
        case eventTime
        case eventFirstPlayer
        case firstPlayerKey
        case eventSecondPlayer
        case secondPlayerKey
        case eventGameResult
        case eventServe
        case eventWinner
        case eventStatus
        case eventTypeType
        case tournamentName
        case tournamentKey
        case tournamentRound
        case tournamentSeason
        case eventLive
        case eventFirstPlayerLogo
        case eventSecondPlayerLogo
        case eventQualification
        case scores
        case pointByPoint = "pointbypoint"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let intValue = try? container.decode(Int.self, forKey: .eventKey) {
            eventKey = String(intValue)
        } else {
            eventKey = try container.decode(String.self, forKey: .eventKey)
        }

        if let intValue = try? container.decode(Int.self, forKey: .firstPlayerKey) {
            firstPlayerKey = String(intValue)
        } else {
            firstPlayerKey = try container.decode(String.self, forKey: .firstPlayerKey)
        }

        if let intValue = try? container.decode(Int.self, forKey: .secondPlayerKey) {
            secondPlayerKey = String(intValue)
        } else {
            secondPlayerKey = try container.decode(String.self, forKey: .secondPlayerKey)
        }

        if let intValue = try? container.decode(Int.self, forKey: .tournamentKey) {
            tournamentKey = String(intValue)
        } else {
            tournamentKey = try container.decode(String.self, forKey: .tournamentKey)
        }

        eventDate = try container.decode(String.self, forKey: .eventDate)
        eventTime = try container.decode(String.self, forKey: .eventTime)
        eventFirstPlayer = try container.decodeIfPresent(String.self, forKey: .eventFirstPlayer)
        eventSecondPlayer = try container.decodeIfPresent(String.self, forKey: .eventSecondPlayer)
        eventGameResult = try container.decodeIfPresent(String.self, forKey: .eventGameResult)
        eventServe = try container.decodeIfPresent(String.self, forKey: .eventServe)
        eventWinner = try container.decodeIfPresent(String.self, forKey: .eventWinner)
        eventStatus = try container.decode(String.self, forKey: .eventStatus)
        eventTypeType = try container.decode(String.self, forKey: .eventTypeType)
        tournamentName = try container.decode(String.self, forKey: .tournamentName)
        tournamentRound = try container.decodeIfPresent(String.self, forKey: .tournamentRound)
        tournamentSeason = try container.decode(String.self, forKey: .tournamentSeason)
        eventLive = try container.decode(String.self, forKey: .eventLive)
        eventFirstPlayerLogo = try container.decodeIfPresent(String.self, forKey: .eventFirstPlayerLogo)
        eventSecondPlayerLogo = try container.decodeIfPresent(String.self, forKey: .eventSecondPlayerLogo)
        eventQualification = try container.decodeIfPresent(String.self, forKey: .eventQualification)
        scores = try container.decodeIfPresent([ScoreDTO].self, forKey: .scores)
        pointByPoint = try container.decodeIfPresent([PointByPointDTO].self, forKey: .pointByPoint)
    }
}
