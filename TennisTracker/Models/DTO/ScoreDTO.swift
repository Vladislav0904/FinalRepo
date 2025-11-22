import Foundation

struct ScoreDTO: Decodable {
    let scoreFirst: String?
    let scoreSecond: String?
    let scoreSet: String?

    enum CodingKeys: String, CodingKey {
        case scoreFirst = "score_first"
        case scoreSecond = "score_second"
        case scoreSet = "score_set"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        scoreFirst = try container.decodeIfPresent(String.self, forKey: .scoreFirst)
        scoreSecond = try container.decodeIfPresent(String.self, forKey: .scoreSecond)
        scoreSet = try container.decodeIfPresent(String.self, forKey: .scoreSet)
    }
}
