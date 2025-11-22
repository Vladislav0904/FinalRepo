import Foundation

struct PointByPointDTO: Decodable {
    let setNumber: String?
    let numberGame: String?
    let playerServed: String?
    let serveWinner: String?
    let serveLost: String?
    let score: String?
    let points: [PointDTO]?

    enum CodingKeys: String, CodingKey {
        case setNumber = "set_number"
        case numberGame = "number_game"
        case playerServed = "player_served"
        case serveWinner = "serve_winner"
        case serveLost = "serve_lost"
        case score
        case points
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        setNumber = try container.decodeIfPresent(String.self, forKey: .setNumber)
        numberGame = try container.decodeIfPresent(String.self, forKey: .numberGame)
        playerServed = try container.decodeIfPresent(String.self, forKey: .playerServed)
        serveWinner = try container.decodeIfPresent(String.self, forKey: .serveWinner)
        serveLost = try container.decodeIfPresent(String.self, forKey: .serveLost)
        score = try container.decodeIfPresent(String.self, forKey: .score)
        points = try container.decodeIfPresent([PointDTO].self, forKey: .points)
    }
}

struct PointDTO: Decodable {
    let numberPoint: String?
    let score: String?
    let breakPoint: String?
    let setPoint: String?
    let matchPoint: String?

    enum CodingKeys: String, CodingKey {
        case numberPoint = "number_point"
        case score
        case breakPoint = "break_point"
        case setPoint = "set_point"
        case matchPoint = "match_point"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        numberPoint = try container.decodeIfPresent(String.self, forKey: .numberPoint)
        score = try container.decodeIfPresent(String.self, forKey: .score)
        breakPoint = try container.decodeIfPresent(String.self, forKey: .breakPoint)
        setPoint = try container.decodeIfPresent(String.self, forKey: .setPoint)
        matchPoint = try container.decodeIfPresent(String.self, forKey: .matchPoint)
    }
}
