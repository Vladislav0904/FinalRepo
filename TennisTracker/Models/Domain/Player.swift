import Foundation

struct Player: Codable {
    let key: String
    let name: String
    let fullName: String?
    let country: String?
    let countryCode: String?
    let birthday: String?
    let logoURL: String?
    let stats: [PlayerStat]?
}
