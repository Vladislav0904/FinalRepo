import Foundation

struct APIError: Decodable, Sendable {
    let param: String?
    let msg: String?
    let cod: Int?
}
