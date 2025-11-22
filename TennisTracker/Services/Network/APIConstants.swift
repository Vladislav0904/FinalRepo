import Foundation

nonisolated enum APIConstants {
    static let baseURL = "https://api.api-tennis.com"
    static let defaultTimeout: TimeInterval = 60
    static let defaultConnectTimeout: TimeInterval = 10
    static let dateFormat = "yyyy-MM-dd"
    static let apiKey = "06f45cb03c567a7cebaccafc836adc20e472ffcffffcb8ca31f2f30b9203589f"

    enum Methods {
        static let getEvents = "get_events"
        static let getFixtures = "get_fixtures"
        static let getLivescore = "get_livescore"
        static let getStandings = "get_standings"
        static let getPlayers = "get_players"
    }

    enum Parameters {
        static let method = "method"
        static let apiKey = "APIkey"
        static let dateStart = "date_start"
        static let dateStop = "date_stop"
        static let eventTypeKey = "event_type_key"
        static let eventType = "event_type"
        static let tournamentKey = "tournament_key"
        static let tournamentSeason = "tournament_season"
        static let matchKey = "match_key"
        static let playerKey = "player_key"
        static let timezone = "timezone"
    }
}
