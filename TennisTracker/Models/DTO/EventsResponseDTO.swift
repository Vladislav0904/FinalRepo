import Foundation

struct EventsResponseDTO: Decodable {
    let success: Int?
    let error: String?
    let result: [EventTypeDTO]

    enum CodingKeys: String, CodingKey {
        case success
        case error
        case result
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decodeIfPresent(Int.self, forKey: .success)
        error = try container.decodeIfPresent(String.self, forKey: .error)
        result = try container.decode([EventTypeDTO].self, forKey: .result)
    }
}

struct EventTypeDTO: Decodable {
    let eventTypeKey: String
    let eventTypeType: String

    enum CodingKeys: String, CodingKey {
        case eventTypeKey
        case eventTypeType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let intValue = try? container.decode(Int.self, forKey: .eventTypeKey) {
            eventTypeKey = String(intValue)
        } else {
            eventTypeKey = try container.decode(String.self, forKey: .eventTypeKey)
        }

        eventTypeType = try container.decode(String.self, forKey: .eventTypeType)
    }
}
