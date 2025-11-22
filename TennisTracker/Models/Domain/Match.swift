import Foundation

struct Match {
    let key: String
    let date: String
    let time: String
    let firstPlayer: PlayerInfo
    let secondPlayer: PlayerInfo
    let finalResult: String?
    let gameResult: String?
    let serve: String?
    let winner: String?
    let status: String
    let eventType: String
    let tournament: TournamentInfo
    let round: String?
    let season: String
    let isLive: Bool
    let isQualification: Bool
    let scores: [Score]
    let sets: [TennisSet]
}
