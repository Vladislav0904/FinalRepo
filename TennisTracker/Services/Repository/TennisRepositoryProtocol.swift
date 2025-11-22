import Foundation

protocol TennisRepositoryProtocol {
    func getEvents() async throws -> [EventType]

    func getFixtures(
        dateStart: String?,
        dateStop: String?,
        eventTypeKey: String?,
        tournamentKey: String?,
        tournamentSeason: String?,
        matchKey: String?,
        playerKey: String?,
        timezone: String?
    ) async throws -> [Match]

    func getLivescore(
        eventTypeKey: String?,
        tournamentKey: String?,
        matchKey: String?,
        playerKey: String?,
        timezone: String?
    ) async throws -> [Match]

    func getPlayers(playerKey: String?) async throws -> [Player]

    func getStandings(eventType: String?) async throws -> [PlayerRanking]
}
