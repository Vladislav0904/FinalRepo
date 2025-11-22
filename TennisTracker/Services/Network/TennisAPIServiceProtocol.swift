import Foundation

protocol TennisAPIServiceProtocol {
    func getEvents() async throws -> EventsResponseDTO
    func getFixtures(
        dateStart: String?,
        dateStop: String?,
        eventTypeKey: String?,
        tournamentKey: String?,
        tournamentSeason: String?,
        matchKey: String?,
        playerKey: String?,
        timezone: String?
    ) async throws -> FixturesResponseDTO
    func getLivescore(
        eventTypeKey: String?,
        tournamentKey: String?,
        matchKey: String?,
        playerKey: String?,
        timezone: String?
    ) async throws -> LivescoreResponseDTO
    func getPlayers(
        playerKey: String?
    ) async throws -> PlayersResponseDTO
    func getStandings(
        eventType: String?
    ) async throws -> StandingsResponseDTO
}
