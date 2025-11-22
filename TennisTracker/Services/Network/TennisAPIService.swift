import Foundation

final class TennisAPIService: TennisAPIServiceProtocol {
    private let networkService: NetworkServiceProtocol

    init() {
        self.networkService = NetworkService(apiKey: APIConstants.apiKey)
    }

    func getEvents() async throws -> EventsResponseDTO {
        let parameters: [String: Any] = [
            APIConstants.Parameters.method: APIConstants.Methods.getEvents
        ]

        return try await networkService.request(
            endpoint: "/tennis/",
            parameters: parameters,
            responseType: EventsResponseDTO.self
        )
    }

    func getFixtures(
        dateStart: String? = nil,
        dateStop: String? = nil,
        eventTypeKey: String? = nil,
        tournamentKey: String? = nil,
        tournamentSeason: String? = nil,
        matchKey: String? = nil,
        playerKey: String? = nil,
        timezone: String? = nil
    ) async throws -> FixturesResponseDTO {
        var parameters: [String: Any] = [
            APIConstants.Parameters.method: APIConstants.Methods.getFixtures
        ]

        if let dateStart = dateStart {
            parameters[APIConstants.Parameters.dateStart] = dateStart
        }
        if let dateStop = dateStop {
            parameters[APIConstants.Parameters.dateStop] = dateStop
        }
        if let eventTypeKey = eventTypeKey {
            parameters[APIConstants.Parameters.eventTypeKey] = eventTypeKey
        }
        if let tournamentKey = tournamentKey {
            parameters[APIConstants.Parameters.tournamentKey] = tournamentKey
        }
        if let tournamentSeason = tournamentSeason {
            parameters[APIConstants.Parameters.tournamentSeason] = tournamentSeason
        }
        if let matchKey = matchKey {
            parameters[APIConstants.Parameters.matchKey] = matchKey
        }
        if let playerKey = playerKey {
            parameters[APIConstants.Parameters.playerKey] = playerKey
        }
        if let timezone = timezone {
            parameters[APIConstants.Parameters.timezone] = timezone
        }

        return try await networkService.request(
            endpoint: "/tennis/",
            parameters: parameters,
            responseType: FixturesResponseDTO.self
        )
    }

    func getLivescore(
        eventTypeKey: String? = nil,
        tournamentKey: String? = nil,
        matchKey: String? = nil,
        playerKey: String? = nil,
        timezone: String? = nil
    ) async throws -> LivescoreResponseDTO {
        var parameters: [String: Any] = [
            APIConstants.Parameters.method: APIConstants.Methods.getLivescore
        ]

        if let eventTypeKey = eventTypeKey {
            parameters[APIConstants.Parameters.eventTypeKey] = eventTypeKey
        }
        if let tournamentKey = tournamentKey {
            parameters[APIConstants.Parameters.tournamentKey] = tournamentKey
        }
        if let matchKey = matchKey {
            parameters[APIConstants.Parameters.matchKey] = matchKey
        }
        if let playerKey = playerKey {
            parameters[APIConstants.Parameters.playerKey] = playerKey
        }
        if let timezone = timezone {
            parameters[APIConstants.Parameters.timezone] = timezone
        }

        return try await networkService.request(
            endpoint: "/tennis/",
            parameters: parameters,
            responseType: LivescoreResponseDTO.self
        )
    }

    func getPlayers(
        playerKey: String? = nil
    ) async throws -> PlayersResponseDTO {
        var parameters: [String: Any] = [
            APIConstants.Parameters.method: APIConstants.Methods.getPlayers
        ]

        if let playerKey = playerKey {
            parameters[APIConstants.Parameters.playerKey] = playerKey
        }

        return try await networkService.request(
            endpoint: "/tennis/",
            parameters: parameters,
            responseType: PlayersResponseDTO.self
        )
    }

    func getStandings(
        eventType: String? = nil
    ) async throws -> StandingsResponseDTO {
        var parameters: [String: Any] = [
            APIConstants.Parameters.method: APIConstants.Methods.getStandings
        ]

        if let eventType = eventType {
            parameters[APIConstants.Parameters.eventType] = eventType
        }

        return try await networkService.request(
            endpoint: "/tennis/",
            parameters: parameters,
            responseType: StandingsResponseDTO.self
        )
    }
}
