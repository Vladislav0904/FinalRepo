import Foundation

struct TennisSet: Equatable {
    let number: String
    let firstPlayerGames: Int
    let secondPlayerGames: Int
    let games: [Game]
    let isCompleted: Bool

    static func == (lhs: TennisSet, rhs: TennisSet) -> Bool {
        lhs.number == rhs.number
    }
}
