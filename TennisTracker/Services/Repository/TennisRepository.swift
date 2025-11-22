import Foundation

final class TennisRepository: TennisRepositoryProtocol {
    private let apiService: TennisAPIServiceProtocol

    init(apiService: TennisAPIServiceProtocol) {
        self.apiService = apiService
    }

    func getEvents() async throws -> [EventType] {
        let response = try await apiService.getEvents()
        return response.result.map { DTOMapper.map($0) }
    }

    func getFixtures(
        dateStart: String?,
        dateStop: String?,
        eventTypeKey: String?,
        tournamentKey: String?,
        tournamentSeason: String?,
        matchKey: String?,
        playerKey: String?,
        timezone: String?
    ) async throws -> [Match] {
        let response = try await apiService.getFixtures(
            dateStart: dateStart,
            dateStop: dateStop,
            eventTypeKey: eventTypeKey,
            tournamentKey: tournamentKey,
            tournamentSeason: tournamentSeason,
            matchKey: matchKey,
            playerKey: playerKey,
            timezone: timezone
        )
        if let error = response.error, error == "1" {
            return []
        }
        if let success = response.success, success != 1 {
            return []
        }
        guard let result = response.result else {
            return []
        }
        return result.map { DTOMapper.map($0) }
    }

    func getLivescore(
        eventTypeKey: String?,
        tournamentKey: String?,
        matchKey: String?,
        playerKey: String?,
        timezone: String?
    ) async throws -> [Match] {
        let response = try await apiService.getLivescore(
            eventTypeKey: eventTypeKey,
            tournamentKey: tournamentKey,
            matchKey: matchKey,
            playerKey: playerKey,
            timezone: timezone
        )
        if let error = response.error, error == "1" {
            return []
        }
        if let success = response.success, success != 1 {
            return []
        }
        guard let result = response.result else {
            return []
        }

        if result.isEmpty {
            return []
        }

        return result.map { DTOMapper.map($0) }
    }

    func getPlayers(playerKey: String?) async throws -> [Player] {
        let response = try await apiService.getPlayers(playerKey: playerKey)
        guard let result = response.result else {
            return []
        }
        return result.map { DTOMapper.map($0) }
    }

    func getStandings(eventType: String?) async throws -> [PlayerRanking] {
        let response = try await apiService.getStandings(eventType: eventType)
        if let error = response.error, error == "1" {
            return []
        }
        if let success = response.success, success != 1 {
            return []
        }
        guard let result = response.result else {
            return []
        }

        return result.compactMap { DTOMapper.map($0) }
    }
}
