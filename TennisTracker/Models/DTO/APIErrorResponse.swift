import Foundation

struct APIErrorResponse: Decodable, Sendable {
    let error: String?
    let result: [APIError]?
}
